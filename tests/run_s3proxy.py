"""Run against an external S3Proxy or manage a disposable Compose project."""
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import time
import urllib.error
import urllib.request
import uuid

root = Path(__file__).resolve().parent.parent
compose = ['docker', 'compose', '-f', str(root / 'tests/compose.yaml'),
           '-p', 'nim-libs3-' + uuid.uuid4().hex[:12]]

def wait_ready(host):
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    deadline = time.monotonic() + 90
    while time.monotonic() < deadline:
        try:
            with opener.open('http://' + host + '/', timeout=2):
                return
        except urllib.error.HTTPError as error:
            if error.code in (403, 400):  # An unsigned S3 request reaches the server.
                return
        except (urllib.error.URLError, TimeoutError, ConnectionError):
            pass
        time.sleep(0.5)
    raise RuntimeError('S3Proxy did not become ready within 90 seconds')

with tempfile.TemporaryDirectory(prefix='nim-libs3-s3proxy-') as tmp:
    binary = str(Path(tmp) / 's3proxy_integration')
    subprocess.run(['nim', 'c', '--path:src', '--nimcache:' + tmp + '/cache',
                    '-o:' + binary, *shlex.split(os.environ.get('NIM_S3_FLAGS', '')),
                    'tests/s3proxy_integration.nim'], cwd=root, check=True)
    external_host = os.environ.get("S3_TEST_HOST")
    try:
        if external_host:
            host = external_host
        else:
            subprocess.run(compose + ['up', '-d'], check=True, timeout=300)
            host = subprocess.check_output(compose + ['port', 's3proxy', '80'],
                                           text=True, timeout=30).strip()
        wait_ready(host)
        env = dict(os.environ, S3_TEST_HOST=host,
                   no_proxy=host.rsplit(':', 1)[0], NO_PROXY=host.rsplit(':', 1)[0])
        subprocess.run([binary], env=env, check=True, timeout=180)
    except BaseException:
        if not external_host:
            subprocess.run(compose + ['logs', '--no-color'], timeout=30, check=False)
        raise
    finally:
        if not external_host:
            subprocess.run(compose + ['down', '--volumes', '--remove-orphans'],
                           timeout=60, check=True)
