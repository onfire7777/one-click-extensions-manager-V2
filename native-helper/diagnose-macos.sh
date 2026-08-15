#!/usr/bin/env bash
set -euo pipefail

browser="${1:-brave}"
case "$browser" in
	brave)
		manifest="$HOME/Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/com.ocem.popuphost.json"
		;;
	chrome)
		manifest="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.ocem.popuphost.json"
		;;
	*)
		echo "[FAIL] Unsupported browser: $browser"
		exit 2
		;;
esac

helper_dir="$HOME/.local/share/one-click-extensions-manager/native-helper"

[[ -f "$manifest" ]] && echo "[OK] Native manifest exists: $manifest" || echo "[FAIL] Missing native manifest: $manifest"
[[ -x "$helper_dir/native-host" ]] && echo "[OK] Native host executable exists" || echo "[FAIL] Missing native host executable"
[[ -x "$helper_dir/native-clicker" ]] && echo "[OK] Native clicker executable exists" || echo "[FAIL] Missing native clicker executable"
[[ -f "$helper_dir/native-host-config.json" ]] && echo "[OK] Native host config exists" || echo "[FAIL] Missing native host config"

if [[ -x "$helper_dir/native-clicker" ]]; then
	if "$helper_dir/native-clicker" --check >/dev/null 2>&1; then
		echo "[OK] Native clicker has Accessibility access"
	else
		echo "[FAIL] Native clicker needs Accessibility access. Run: \"$helper_dir/native-clicker\" --prompt"
	fi
fi

if [[ -x "$helper_dir/native-host" ]]; then
	if "$helper_dir/native-host" --check >/dev/null 2>&1; then
		echo "[OK] Native host has Accessibility access"
	else
		echo "[FAIL] Native host needs Accessibility access. Run: \"$helper_dir/native-host\" --prompt"
	fi
fi
if [[ -f "$helper_dir/native-host-config.json" ]]; then
	HELPER_CONFIG="$helper_dir/native-host-config.json" node <<'NODE' || true
const fs = require('node:fs');
const config = JSON.parse(fs.readFileSync(process.env.HELPER_CONFIG, 'utf8'));
if (config.browserProfilePath) {
	const securePreferences = `${config.browserProfilePath}/Secure Preferences`;
	console.log(
		fs.existsSync(securePreferences)
			? `[OK] Browser profile preferences found: ${securePreferences}`
			: `[WARN] Browser profile preferences missing: ${securePreferences}`,
	);
}
NODE
fi
