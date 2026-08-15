param(
	[ValidateSet('brave', 'chrome', 'edge', 'chromium')]
	[string] $Browser = 'brave'
)

$installDir = Join-Path $env:LOCALAPPDATA 'OnFire Extensions Manager\native-helper'
$configPath = Join-Path $installDir 'native-host-config.json'
$manifestPath = Join-Path $installDir 'com.ocem.popuphost.json'
$registryPaths = @{
	brave = 'HKCU:\Software\BraveSoftware\Brave-Browser\NativeMessagingHosts\com.ocem.popuphost'
	chrome = 'HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.ocem.popuphost'
	edge = 'HKCU:\Software\Microsoft\Edge\NativeMessagingHosts\com.ocem.popuphost'
	chromium = 'HKCU:\Software\Chromium\NativeMessagingHosts\com.ocem.popuphost'
}

function Write-Check {
	param([bool] $Ok, [string] $Message)
	if ($Ok) { Write-Host "[OK] $Message" } else { Write-Host "[FAIL] $Message" }
}

Write-Check ([bool](Get-Command node -ErrorAction SilentlyContinue)) 'Node.js is available'
Write-Check (Test-Path (Join-Path $installDir 'native-host.mjs')) "Native host script exists: $installDir"
Write-Check (Test-Path (Join-Path $installDir 'native-host.exe')) 'Native host launcher exists'
Write-Check (Test-Path $manifestPath) 'Native messaging manifest exists'
Write-Check (Test-Path $configPath) 'Native host config exists'
Write-Check (Test-Path $registryPaths[$Browser]) "Native messaging registry key exists for $Browser"

if (Test-Path $configPath) {
	try {
		$config = Get-Content -Raw $configPath | ConvertFrom-Json
		Write-Check ($config.extensionId -match '^[a-p]{32}$') "Configured extension id: $($config.extensionId)"
	} catch {
		Write-Host "[FAIL] Native host config is invalid JSON: $($_.Exception.Message)"
	}
}

$processNames = @{
	brave = @('brave')
	chrome = @('chrome')
	edge = @('msedge')
	chromium = @('chromium')
}[$Browser]
$browserProcess = $processNames | ForEach-Object {
	Get-Process -Name $_ -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }
} | Select-Object -First 1
Write-Check ([bool] $browserProcess) "Running browser window found for $Browser"
