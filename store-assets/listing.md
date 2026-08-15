# Chrome Web Store listing

## Product details

**Name:** OnFire Extensions Manager

**Summary:** OnFire fork of One Click Extension Manager with folders, popups, toggles, and uninstall controls.

**Category:** Tools

**Language:** English (United States)

**Detailed description:**

Manage your installed browser extensions from one fast, local interface.

OnFire Extensions Manager lets you search and filter extensions, organize them into folders, pin favorites, enable or disable them, open their toolbar popups, and uninstall them with the browser's confirmation prompt.

Features:

- Search and filter installed extensions
- Organize extensions into custom folders
- Pin frequently used extensions
- Enable or disable one extension or a filtered group
- Open an extension's toolbar popup with the optional native helper
- Remove an extension only after explicit confirmation
- Use the toolbar popup interface

OnFire has no ads, analytics, tracking, or remote code. Extension metadata and preferences are handled locally and are not sent to the developer or third parties.

## Privacy practices

**Single purpose:** Give users one local interface to view, organize, enable, disable, open, and uninstall installed browser extensions.

**`management` justification:** Required to list installed extensions and perform enable, disable, launch, and uninstall actions that the user explicitly requests. OnFire cannot provide its core extension-management purpose without this permission.

**`storage` justification:** Stores folders, pinned extension IDs, interface settings, and dismissed help tips in `chrome.storage.local`. On upgrade, a legacy `chrome.storage.sync` value is copied to local storage and removed so preferences remain available without continued browser sync.

**`nativeMessaging` justification:** Used only when the user separately installs the optional local helper. Chrome does not expose an extension API for opening another extension's toolbar popup, so the helper performs that user-requested local UI action. The native host manifest restricts access to the installed OnFire extension ID. No network server is used.

**Remote code:** No. All executable code is included in the extension package.

**Data handling:** OnFire locally reads browser-provided metadata about installed extensions and locally stores the user's folders and preferences. It does not transmit this information to the developer or any third party; it has no analytics, advertising, sale of data, or human access to user data.

**Limited Use:** The use of information received from Chrome APIs adheres to the Chrome Web Store User Data Policy, including the Limited Use requirements.

## URLs

- Homepage: <https://github.com/onfire7777/one-click-extensions-manager-V2>
- Support: <https://github.com/onfire7777/one-click-extensions-manager-V2/issues>
- Privacy policy: <https://github.com/onfire7777/one-click-extensions-manager-V2/blob/main/privacy-policy.md>

## Required graphic assets

- Store icon: `source/onfire-logo.png` (128x128 PNG)
- Screenshot: `store-assets/screenshot-main-640x400.png`
- Small promo tile: `store-assets/promo-small-440x280.png`
