version = "0.1.1"
author = "libs3 contributors"
description = "Nim bindings and synchronous client for bji/libs3 4.1"
# MIT covers original wrapper code; see src/libs3/NOTICE.txt for upstream terms.
license = "MIT"
srcDir = "src"
installExt = @["nim", "txt"]
requires "nim >= 1.6.0"

task test, "Run local HTTP integration tests (requires libs3)":
  exec "python3 tests/run.py"

task testS3Proxy, "Run integration tests against a disposable S3Proxy container":
  exec "python3 tests/run_s3proxy.py"
