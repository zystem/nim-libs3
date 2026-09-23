# libs3 for Nim

A Nimble package with bindings to [bji/libs3](https://github.com/bji/libs3) **4.1**
and a synchronous Nim API. Targets Linux/POSIX, the C backend, and Nim >= 1.6.
Verified with Nim 2.2.4 and libs3 commit
`98f667b248a7288c1941582897343171cfdf441c`.
Older libs3 2.x releases and forks with incompatible APIs are not supported.

## Installation

First install libs3 4.1, including `libs3.h` and `libs3.so`.
Building upstream requires a C compiler, make, and the development packages for
libcurl, libxml2, and OpenSSL. See the upstream README for build instructions.
Nimble does not install the system C library automatically.

From this package's directory:

```sh
nimble install
```

Then use `import libs3` in your application. To build the example without installing:

```sh
nim c --path:src examples/basic.nim
```

For a custom libs3 installation prefix:

```sh
nim c --path:src --passC:-I/opt/libs3/include --passL:-L/opt/libs3/lib examples/basic.nim
LD_LIBRARY_PATH=/opt/libs3/lib ./examples/basic
```

## Example

```nim
import libs3

proc main() =
  initializeS3()
  defer: deinitializeS3()
  let client = newS3Client("my-bucket", "access-key", "secret-key",
    region = "eu-central-1", hostName = "s3.eu-central-1.amazonaws.com")
  discard client.putObject("hello.txt", "Hello!", "text/plain")
  echo client.getObject("hello.txt")
  echo client.headObject("hello.txt").contentLength
  client.deleteObject("hello.txt")

main()
```

[examples/basic.nim](examples/basic.nim) reads credentials from environment
variables and demonstrates listing every page. It creates and deletes
`nim-example.txt` in the selected bucket.

## API

- `initializeS3` / `deinitializeS3`: explicit process-wide library lifecycle.
  Initialize once before making requests and release after all requests finish.
  Do not call these functions concurrently with requests or from multiple threads.
- `newS3Client`: bucket, credentials, hostname, region, session token, protocol,
  URI style, and timeout (30 seconds by default).
- `putObject`: upload a string, including binary data and NUL bytes; returns response metadata.
- `getObject`: download into a string, including binary data; supports `startByte`
  and `byteCount` (0 means through the end of the object).
- `headObject`: size, Content-Type, ETag, modification time, and user metadata.
- `deleteObject`: delete an object.
- `listObjects`: one page containing `objects`, `commonPrefixes`, `isTruncated`,
  and `nextMarker`. Pass `nextMarker` as `marker` for the next call.
  Supports `prefix`, `delimiter`, and `maxKeys` (1–1000).
- `S3Error`: exception containing `status: S3Status` and the server's error message.

HTTPS and TLS certificate verification are enabled by default. For a local S3
service, explicitly select `protocol = S3ProtocolHTTP` and a hostname such as
`hostName = "localhost:9000"`. The hostname must not contain a scheme or path.
Path-style addressing is the default; select virtual-host-style with
`uriStyle = S3UriStyleVirtualHost`.
The client owns its Nim strings; C pointers remain valid throughout each
synchronous call. Callback data is copied before returning to C.

The high-level API keeps the entire object in memory and does not retry requests
automatically. For streaming, multipart, ACLs, bucket operations, server logging,
lifecycle rules, and asynchronous request contexts, use `import libs3/raw`.
It exposes all 39 upstream functions with their original `S3_*` names, types,
and callback handlers. Callbacks must use `{.cdecl, raises: [].}`.
For asynchronous calls, keep strings, handlers, and callbackData alive until the
request completes. Pointers supplied to callbacks belong to libs3 and remain valid
only during the callback.

## Tests

All tests require Python >= 3.9, Nim, and an installed libs3 4.1.
No AWS account or AWS credentials are needed.

### Local HTTP fixture

```sh
nimble test
```

Uses real libs3 against a small local HTTP fixture to test binary and empty
objects, ranges, metadata, pagination marker fallback, errors, and the raw API.
The fixture does not validate request signatures.

### S3Proxy

Install Docker with the Compose plugin and ensure the Docker daemon is running:

```sh
nimble testS3Proxy
```

The runner builds the tests, starts [S3Proxy](https://github.com/gaul/s3proxy),
waits for it to accept HTTP requests, and executes signed requests through libs3.
[tests/compose.yaml](tests/compose.yaml) uses:

```yaml
image: andrewgaul/s3proxy
environment:
  S3PROXY_IDENTITY: "local-identity"
  S3PROXY_CREDENTIAL: "local-credential"
  S3PROXY_AUTHORIZATION: "aws-v2-or-v4"
  JCLOUDS_PROVIDER: "filesystem-nio2"
```

Each run creates an isolated Compose project, publishes port 80 on a randomly
assigned localhost port, and stores data inside the disposable container.
The runner removes the project containers and volumes after success or failure,
and prints container logs on failure. The first run may download the image.

The suite covers bucket creation and deletion, empty and binary uploads, uploads
larger than one callback buffer, HEAD properties, byte ranges, escaped object keys,
real pagination, prefix and delimiter filtering, missing-object errors, and
rejection of incorrect credentials. It does not test real AWS or TLS.

Both test commands accept additional compiler flags through `NIM_S3_FLAGS`:

```sh
export NIM_S3_FLAGS='--passC:-I/opt/libs3/include --passL:-L/opt/libs3/lib'
export LD_LIBRARY_PATH=/opt/libs3/lib
nimble test
nimble testS3Proxy
```

## Continuous integration

The Woodpecker pipeline uses `nimlang/nim:2.2.4-alpine` on pushes, pull requests,
and tags. It builds the pinned libs3 revision from source, runs the local HTTP
and S3Proxy suites, and compiles the example in release mode. S3Proxy runs as a
Woodpecker service with the same credentials and filesystem provider as Compose.

To validate and execute the pipeline locally with Docker running:

```sh
woodpecker-cli lint --strict .woodpecker.yaml
woodpecker-cli exec --local --pipeline-event push .woodpecker.yaml
```

The S3Proxy runner accepts `S3_TEST_HOST=hostname:port` to use an existing service
instead of starting Compose. This mode does not create or remove containers;
use a disposable service because the tests create and delete a test bucket.

## Releases and publication

After the test step succeeds, version tags matching `v*` trigger the Woodpecker
publication step. The tag must match `libs3.nimble`. CI creates a GitHub release
and opens a pull request to `nim-lang/packages` for initial Nimble registration.
Registry availability depends on that pull request being merged by maintainers.
Later releases use Git tags and do not require a new registry entry.

The publication step uses `CI_NETRC_PASSWORD` supplied by Woodpecker (or
`GH_TOKEN` if configured). The token must allow releases in this repository,
forking `nim-lang/packages`, and creating the registry pull request.

## Updating the bindings

To regenerate the raw API:

```sh
python3 tools/generate_bindings.py /path/to/libs3/inc/libs3.h
```

The generator targets the libs3 4.1 header layout. Review the generated code and
rerun the tests when updating the upstream version.

## License

The original Nim wrapper and generator code are licensed under [MIT](LICENSE).
This grant does not relicense third-party material or the separate libs3 C library.

The verified upstream libs3 revision offers **LGPL-3.0-or-later**, alternatively
**GPL-2.0-or-later**, with an additional OpenSSL linking exception. Generated
`raw.nim` declarations retain the upstream header notice. See
[third-party notices](src/libs3/NOTICE.txt) and the
[original upstream license notice](src/libs3/licenses/UPSTREAM-LICENSE.txt).
The applicable license texts are included and installed with the package.

When distributing applications linked to libs3 under the LGPL option, comply
with its notice, license, and library replacement/relinking requirements.
Dynamic linking can satisfy the shared-library mechanism described in LGPLv3
section 4; static linking requires the corresponding relinking provisions.
The MIT license for the wrapper does not remove these obligations.
