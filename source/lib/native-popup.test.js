import test, {afterEach} from 'node:test';
import assert from 'node:assert/strict';
import {
	openNativePopup,
	PopupHelperError,
	nativeHostName,
} from './native-popup.js';

afterEach(() => {
	delete globalThis.chrome;
});

function installChromeMock({nativeMessaging, runtimeMessaging}) {
	globalThis.chrome = {
		runtime: {
			id: 'manager-extension-id',
			lastError: undefined,
			sendNativeMessage(hostName, payload, callback) {
				nativeMessaging({hostName, payload, callback});
			},
			sendMessage(...arguments_) {
				runtimeMessaging({arguments_, callback: arguments_.at(-1)});
			},
		},
	};
}

test('uses direct native messaging before fallbacks', async () => {
	installChromeMock({
		nativeMessaging({hostName, payload, callback}) {
			assert.equal(hostName, nativeHostName);
			assert.equal(payload.type, 'open-extension-popup');
			callback({ok: true, detail: 'native'});
		},
		runtimeMessaging() {
			assert.fail(
				'runtime messaging should not run after native messaging success',
			);
		},
	});
	assert.deepEqual(
		await openNativePopup({
			extensionId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
			extensionName: 'Example',
			extensionAliases: ['Example Full Name'],
		}),
		{ok: true, detail: 'native'},
	);
});

test('uses the background bridge when direct native messaging fails', async () => {
	installChromeMock({
		nativeMessaging({callback}) {
			chrome.runtime.lastError = {message: 'native missing'};
			callback();
			chrome.runtime.lastError = undefined;
		},
		runtimeMessaging({callback}) {
			callback({ok: true, detail: 'background'});
		},
	});

	assert.deepEqual(
		await openNativePopup({
			extensionId: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
			extensionName: 'Fallback',
			extensionAliases: ['Fallback Long Name'],
		}),
		{ok: true, detail: 'background'},
	);
});

test('reports structured failures when every transport fails', async () => {
	installChromeMock({
		nativeMessaging({callback}) {
			chrome.runtime.lastError = {message: 'native missing'};
			callback();
			chrome.runtime.lastError = undefined;
		},
		runtimeMessaging({callback}) {
			chrome.runtime.lastError = {message: 'background unavailable'};
			callback();
			chrome.runtime.lastError = undefined;
		},
	});
	await assert.rejects(
		openNativePopup({
			extensionId: 'cccccccccccccccccccccccccccccccc',
			extensionName: 'Broken',
		}),
		error => {
			assert.ok(error instanceof PopupHelperError);
			assert.equal(error.details.length, 3);
			assert.match(error.details.join('\n'), /native missing/v);
			return true;
		},
	);
});
