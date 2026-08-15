# Privacy Policy

Effective date: August 14, 2026

OnFire Extensions Manager helps you view, organize, enable, disable, open, and uninstall browser extensions. This policy explains the data the extension handles to provide those features.

## Data the extension handles

The extension reads information supplied by the browser about installed extensions, including names, identifiers, icons, enabled state, and available management actions. It also stores your OnFire preferences and organization data, such as folders and interface settings, in the browser's local extension storage.

This information stays on your device. OnFire does not operate a remote server, use analytics or advertising SDKs, sell data, or transmit extension data to third parties.

## Optional native helper

If you install the optional OnFire native helper, the extension communicates with that helper only on your device through Chrome's authenticated native-messaging channel. The helper is used to open a selected extension's popup. Its native-messaging manifest restricts access to the configured OnFire extension ID, and it does not send data to an external service.

## Permissions

- `management` is used to list and manage extensions at your request.
- `storage` is used to save OnFire folders and preferences locally.
- `nativeMessaging` is used only for the optional local popup helper.

OnFire's use of information received from Chrome APIs complies with the Chrome Web Store User Data Policy, including its Limited Use requirements.

## Retention and deletion

Local settings remain until you clear the extension's data or uninstall OnFire. The optional native helper can be uninstalled separately.

## Contact

Questions or privacy requests can be submitted at <https://github.com/onfire7777/one-click-extensions-manager-V2/issues>.
