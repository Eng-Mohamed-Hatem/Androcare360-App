const net = require('net');

function checkPort(host, port, timeoutMs = 1000) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    let settled = false;

    const finish = (result) => {
      if (settled) {
        return;
      }
      settled = true;
      socket.destroy();
      resolve(result);
    };

    socket.setTimeout(timeoutMs);
    socket.once('connect', () => finish(true));
    socket.once('timeout', () => finish(false));
    socket.once('error', () => finish(false));
    socket.connect(port, host);
  });
}

async function main() {
  const checks = [
    {
      label: 'Firestore emulator',
      host: '127.0.0.1',
      port: 8080,
    },
    {
      label: 'Auth emulator',
      host: '127.0.0.1',
      port: 9099,
    },
  ];

  const results = await Promise.all(
    checks.map(async (check) => ({
      ...check,
      ok: await checkPort(check.host, check.port),
    }))
  );

  const failures = results.filter((result) => !result.ok);

  if (failures.length > 0) {
    const details = failures
      .map((failure) => `${failure.label} on ${failure.host}:${failure.port}`)
      .join(', ');
    process.stderr.write(
      `Firebase emulators are not running: ${details}. Start them before running emulator-backed Functions tests.\n`
    );
    process.exit(1);
  }

  process.stdout.write('Firebase emulators are reachable.\n');
}

main().catch((error) => {
  process.stderr.write(`Failed to check emulator ports: ${error.message}\n`);
  process.exit(1);
});
