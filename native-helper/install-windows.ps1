param(
	[Parameter(Mandatory = $true)]
	[string] $ExtensionId,
	[ValidateSet('brave', 'chrome', 'edge', 'chromium')]
	[string] $Browser = 'brave'
)

$ErrorActionPreference = 'Stop'
if ($ExtensionId -notmatch '^[a-p]{32}$') {
	Write-Error 'Usage: install-windows.ps1 -ExtensionId <32-character-extension-id> [-Browser brave|chrome|edge|chromium]'
	exit 2
}

$browserConfigs = @{
	brave = @{ DisplayName = 'Brave'; ProcessNames = @('brave'); RegistryPath = 'HKCU:\Software\BraveSoftware\Brave-Browser\NativeMessagingHosts\com.ocem.popuphost' }
	chrome = @{ DisplayName = 'Google Chrome'; ProcessNames = @('chrome'); RegistryPath = 'HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.ocem.popuphost' }
	edge = @{ DisplayName = 'Microsoft Edge'; ProcessNames = @('msedge'); RegistryPath = 'HKCU:\Software\Microsoft\Edge\NativeMessagingHosts\com.ocem.popuphost' }
	chromium = @{ DisplayName = 'Chromium'; ProcessNames = @('chromium'); RegistryPath = 'HKCU:\Software\Chromium\NativeMessagingHosts\com.ocem.popuphost' }
}

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
	Write-Error 'Node.js is required. Install Node.js, restart PowerShell, then run this installer again.'
	exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installDir = Join-Path $env:LOCALAPPDATA 'OnFire Extensions Manager\native-helper'
$manifestPath = Join-Path $installDir 'com.ocem.popuphost.json'
$launcherPath = Join-Path $installDir 'native-host.exe'
$browserConfig = $browserConfigs[$Browser]
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item -Force -Path (Join-Path $scriptDir 'native-host.mjs') -Destination (Join-Path $installDir 'native-host.mjs')
[System.IO.File]::WriteAllText((Join-Path $installDir 'node-path.txt'), $node.Source, $utf8NoBom)

$launcherSource = Get-Content -Raw (Join-Path $scriptDir 'native-host-launcher-windows.cs')
Remove-Item -Force $launcherPath -ErrorAction SilentlyContinue
Add-Type -TypeDefinition $launcherSource -Language CSharp -OutputAssembly $launcherPath -OutputType ConsoleApplication

$config = [ordered]@{
	extensionId = $ExtensionId
	browserDisplayName = $browserConfig.DisplayName
	browserProcessNames = $browserConfig.ProcessNames
}
[System.IO.File]::WriteAllText((Join-Path $installDir 'native-host-config.json'), ($config | ConvertTo-Json -Depth 4), $utf8NoBom)

$manifest = [ordered]@{
	name = 'com.ocem.popuphost'
	description = 'OnFire Extensions Manager popup opener'
	path = $launcherPath
	type = 'stdio'
	allowed_origins = @("chrome-extension://$ExtensionId/")
}
[System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 4), $utf8NoBom)

New-Item -Force -Path $browserConfig.RegistryPath | Out-Null
(Get-Item $browserConfig.RegistryPath).SetValue('', $manifestPath)

# Remove the deprecated unauthenticated HTTP bridge from older installations.
$taskName = 'OnFire Extensions Manager Popup Helper'
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
	Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
	Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
$pidPath = Join-Path $installDir 'http-host.pid'
if (Test-Path $pidPath) {
	$oldPid = Get-Content $pidPath -ErrorAction SilentlyContinue
	if ($oldPid -match '^[0-9]+$') {
		Stop-Process -Id ([int] $oldPid) -ErrorAction SilentlyContinue
	}
}
Remove-Item -Force $pidPath, (Join-Path $installDir 'native-http-host.mjs') -ErrorAction SilentlyContinue

Write-Host '[OK] Installed OnFire Extensions Manager native messaging helper for Windows.'
Write-Host "[OK] Native host manifest: $manifestPath"
Write-Host "[OK] Registry key: $($browserConfig.RegistryPath)"
