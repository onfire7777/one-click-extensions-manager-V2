using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

internal static class NativeHostLauncher
{
	private static int Main()
	{
		var directory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
		if (directory == null)
		{
			throw new InvalidOperationException("Unable to locate the native host directory.");
		}

		var nodePath = File.ReadAllText(Path.Combine(directory, "node-path.txt")).Trim();
		var scriptPath = Path.Combine(directory, "native-host.mjs");
		var process = Process.Start(new ProcessStartInfo
		{
			FileName = nodePath,
			Arguments = "\"" + scriptPath + "\"",
			UseShellExecute = false,
			CreateNoWindow = true
		});
		if (process == null)
		{
			throw new InvalidOperationException("Unable to start Node.js.");
		}

		process.WaitForExit();
		return process.ExitCode;
	}
}
