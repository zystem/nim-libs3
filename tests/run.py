"""Exercise the real libs3 transport without credentials or external services."""
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, parse_qs

objects = {}
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def reply(self, code, body=b'', content_type='application/xml', length=None):
        self.send_response(code)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body) if length is None else length))
        self.send_header('ETag', '"fixture-etag"')
        self.send_header('x-amz-meta-fixture', 'yes')
        self.end_headers()
        if self.command != 'HEAD':
            self.wfile.write(body)

    def do_PUT(self):
        objects[urlsplit(self.path).path] = (
            self.rfile.read(int(self.headers['Content-Length'])),
            self.headers['Content-Type'])
        self.reply(200)

    def do_GET(self):
        path = urlsplit(self.path)
        if path.path.rstrip('/') == '/test-bucket':
            query = parse_qs(path.query)
            if 'marker' in query:
                xml = '<ListBucketResult><IsTruncated>false</IsTruncated></ListBucketResult>'
            else:
                xml = '''<ListBucketResult><IsTruncated>true</IsTruncated>
                <Contents><Key>object</Key><Size>10</Size><ETag>etag</ETag>
                <LastModified>2026-01-01T00:00:00.000Z</LastModified></Contents>
                </ListBucketResult>'''
            self.reply(200, xml.encode())
        elif path.path in objects:
            body, kind = objects[path.path]
            if self.headers.get('Range'):
                start, end = self.headers['Range'].removeprefix('bytes=').split('-')
                body = body[int(start):int(end)+1 if end else None]
                self.reply(206, body, kind)
            else:
                self.reply(200, body, kind)
        else:
            self.reply(404, b'<Error><Code>NoSuchKey</Code><Message>fixture missing</Message></Error>')

    def do_HEAD(self):
        body, kind = objects[urlsplit(self.path).path]
        self.reply(200, content_type=kind, length=len(body))

    def do_DELETE(self):
        objects.pop(urlsplit(self.path).path, None)
        self.reply(204)

root = Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix='nim-libs3-test-') as tmp:
    binary = str(Path(tmp) / 'integration')
    subprocess.run(['nim', 'c', '--path:src', '--nimcache:' + tmp + '/cache',
                    '-o:' + binary, *shlex.split(os.environ.get('NIM_S3_FLAGS', '')),
                    'tests/integration.nim'], cwd=root, check=True)
    server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    env = dict(os.environ, S3_TEST_HOST=f'127.0.0.1:{server.server_port}',
               no_proxy='127.0.0.1', NO_PROXY='127.0.0.1')
    try:
        subprocess.run([binary], env=env, check=True)
    finally:
        server.shutdown()
        server.server_close()
