# OnFire Extensions Manager Native Popup Helper

Chrome and Brave do not expose an extension API that lets one extension directly
open another extension's action popup. This helper provides the practical
cross-platform path for OnFire Extensions Manager: the manager asks a local
helper to click the target extension in the browser toolbar or Extensions menu.
It deliberately does not open `chrome-extension://...` popup or options pages as
tabs/windows; if the browser toolbar/menu cannot be automated, the helper
returns a clear error instead.

## One-command setup

After loading the unpacked extension, copy this extension's ID from
`chrome://extensions`, then run:

```sh
npm run helper:install -- <extension-id> brave
```

Use `chrome` instead of `brave` for Google Chrome. Windows also supports `edge`
and `chromium`.

Diagnose:

```sh
npm run helper:diagnose -- brave
```

Uninstall:

```sh
npm run helper:uninstall
```

## Direct macOS commands

```sh
bash native-helper/install-macos.sh inbopcbofedcnafadmplaamkbffefmjo brave
```

Diagnose:

```sh
bash native-helper/diagnose-macos.sh brave
```

Uninstall:

```sh
bash native-helper/uninstall-macos.sh
```

The macOS installer writes:

- Native messaging manifest: `~/Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/com.ocem.popuphost.json`
- Helper files: `~/.local/share/one-click-extensions-manager/native-helper`
- Browser profile path used by diagnostics: `~/Library/Application Support/BraveSoftware/Brave-Browser/Default`

The helper directory intentionally keeps the legacy `one-click-extensions-manager`
path so existing native-host installs continue to work after upgrading this
fork.

## Direct Windows commands

From PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File native-helper/install-windows.ps1 -ExtensionId inbopcbofedcnafadmplaamkbffefmjo -Browser brave
powershell -ExecutionPolicy Bypass -File native-helper/diagnose-windows.ps1 -Browser brave
powershell -ExecutionPolicy Bypass -File native-helper/uninstall-windows.ps1
```

The Windows installer writes:

- Helper files: `%LOCALAPPDATA%\OnFire Extensions Manager\native-helper`
- Helper config: `%LOCALAPPDATA%\OnFire Extensions Manager\native-helper\native-host-config.json`
- Native messaging manifest: `%LOCALAPPDATA%\OnFire Extensions Manager\native-helper\com.ocem.popuphost.json`
- Per-user native messaging registry key for the selected browser

The native messaging manifest restricts access to the installed manager extension
ID. The helper is launched on demand by the browser and does not listen on a
network port or run continuously.

If macOS reports that `osascript` is not allowed assistive access, grant Accessibility permission to the app running the helper or reinstall the helper from a terminal/Codex session that already has Accessibility permission.
Normal popup requests check Accessibility access silently so Brave does not show a permission prompt on every click. If macOS reports that `native-host` or `native-clicker` needs Accessibility access, run the explicit prompt command once:

```sh
~/.local/share/one-click-extensions-manager/native-helper/native-host --prompt
~/.local/share/one-click-extensions-manager/native-helper/native-clicker --prompt
```

Then grant access in System Settings > Privacy & Security > Accessibility and retry the extension popup.
