import std/[os, strutils, unittest]
import libs3

const
  identity = "local-identity"
  credential = "local-credential"
  bucket = "nim-libs3-integration"

proc completed(status: S3Status; details: ptr S3ErrorDetails;
               data: pointer) {.cdecl, raises: [].} =
  cast[ptr S3Status](data)[] = status

proc properties(properties: ptr S3ResponseProperties; data: pointer): S3Status {.cdecl, raises: [].} =
  S3StatusOK

proc main() =
  initializeS3()
  defer: deinitializeS3()
  let host = getEnv("S3_TEST_HOST")
  doAssert host.len > 0, "Run this suite with nimble testS3Proxy"
  let client = newS3Client(bucket, identity, credential,
    hostName = host, protocol = S3ProtocolHTTP)
  var status = S3StatusInternalError
  var handler = S3ResponseHandler(propertiesCallback: properties, completeCallback: completed)
  S3_create_bucket(S3ProtocolHTTP, identity, credential, nil, host.cstring,
    bucket, "us-east-1", S3CannedAclPrivate, nil, nil, 30_000,
    addr handler, addr status)
  doAssert status == S3StatusOK, "Cannot create test bucket: " & $S3_get_status_name(status)

  suite "libs3 against S3Proxy filesystem-nio2":
    test "signed binary, empty and multi-buffer uploads":
      for body in ["", "abc\0def\xff", repeat('x', 100_000)]:
        discard client.putObject("roundtrip", body, "application/test")
        check client.getObject("roundtrip") == body
        let info = client.headObject("roundtrip")
        check info.contentLength == uint64(body.len)
        check info.contentType == "application/test"
        check info.eTag.len > 0
      client.deleteObject("roundtrip")

    test "range and escaped object keys":
      let key = "folder/a space + percent%.bin"
      discard client.putObject(key, "0123456789")
      check client.getObject(key, 2, 3) == "234"
      check client.getObject(key, 7) == "789"
      client.deleteObject(key)

    test "real pagination, prefix and delimiter":
      let keys = @["pages/a", "pages/b", "pages/c"]
      for key in keys: discard client.putObject(key, key)
      discard client.putObject("other/key", "other")
      var found: seq[string]
      var marker = ""
      var finished = false
      for pageNumber in 0 ..< 5:
        let page = client.listObjects(prefix = "pages/", marker = marker, maxKeys = 1)
        check page.objects.len <= 1
        for entry in page.objects: found.add entry.key
        if not page.isTruncated:
          finished = true
          break
        require page.nextMarker.len > 0
        require page.nextMarker != marker
        marker = page.nextMarker
      check finished
      check found == keys
      let grouped = client.listObjects(delimiter = "/")
      check grouped.objects.len == 0
      check "pages/" in grouped.commonPrefixes
      check "other/" in grouped.commonPrefixes
      for key in keys: client.deleteObject(key)
      client.deleteObject("other/key")

    test "missing objects preserve service error codes":
      discard client.putObject("deleted", "value")
      client.deleteObject("deleted")
      try:
        discard client.getObject("deleted")
        check false
      except S3Error as error:
        check error.status == S3StatusErrorNoSuchKey
        check error.msg.len > 0

    test "incorrect credentials are rejected":
      discard client.putObject("private", "secret")
      let invalid = newS3Client(bucket, identity, "wrong-credential",
        hostName = host, protocol = S3ProtocolHTTP)
      try:
        discard invalid.getObject("private")
        check false
      except S3Error as error:
        check error.status in {S3StatusErrorSignatureDoesNotMatch,
          S3StatusErrorAccessDenied, S3StatusHttpErrorForbidden}
      client.deleteObject("private")

    test "empty bucket can be deleted through raw API":
      check client.listObjects().objects.len == 0
      status = S3StatusInternalError
      S3_delete_bucket(S3ProtocolHTTP, S3UriStylePath, identity, credential,
        nil, host.cstring, bucket, "us-east-1", nil, 30_000, addr handler, addr status)
      check status == S3StatusOK

main()
