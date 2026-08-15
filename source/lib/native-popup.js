export const nativeHostName = 'com.ocem.popuphost';

export class PopupHelperError extends Error {
	constructor(message, details = []) {
		super(message);
		this.name = 'PopupHelperError';
		this.details = details;
	}
}

function getLastErrorMessage() {
	return chrome.runtime.lastError?.message;
}

function sendRuntimeMessage(payload, external = false) {
	return new Promise((resolve, reject) => {
		const callback = response => {
			const error = getLastErrorMessage();
			if (error) {
				reject(new Error(error));
				return;
			}

			resolve(response);
		};

		if (external) {
			chrome.runtime.sendMessage(chrome.runtime.id, payload, callback);
			return;
		}

		chrome.runtime.sendMessage(payload, callback);
	});
}

function sendNativeMessage(payload) {
	return new Promise((resolve, reject) => {
		chrome.runtime.sendNativeMessage(nativeHostName, payload, response => {
			const error = getLastErrorMessage();
			if (error) {
				reject(new Error(error));
				return;
			}

			resolve(response);
		});
	});
}

function assertOkResponse(response, transport) {
	if (response?.ok) {
		return response;
	}

	throw new Error(
		response?.error || `${transport} returned an invalid response.`,
	);
}

function describeError(error) {
	if (error?.cause?.message) {
		return `${error.message} ${error.cause.message}`;
	}

	return error?.message || String(error);
}

export async function openNativePopup({
	extensionId,
	extensionName,
	extensionAliases = [],
}) {
	const payload = {
		type: 'open-extension-popup',
		extensionId,
		extensionName,
		extensionAliases,
	};

	const attempts = [
		['native messaging', () => sendNativeMessage(payload)],
		['background bridge', () => sendRuntimeMessage(payload)],
		['external background bridge', () => sendRuntimeMessage(payload, true)],
	];
	const failures = [];

	for (const [transport, run] of attempts) {
		try {
			// eslint-disable-next-line no-await-in-loop -- Ordered fallbacks; only try the next transport after a concrete failure.
			return assertOkResponse(await run(), transport);
		} catch (error) {
			failures.push(`${transport}: ${describeError(error)}`);
		}
	}

	throw new PopupHelperError(
		'Native popup helper is not installed or is not responding.',
		failures,
	);
}
