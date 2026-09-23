import std/[os, unittest, strutils]
import libs3

proc main() =
  initializeS3()
  defer: deinitializeS3()
  let client = newS3Client("test-bucket", "test-access", "test-secret",
    hostName = getEnv("S3_TEST_HOST"), protocol = S3ProtocolHTTP)

  suite "libs3 against a local HTTP fixture":
    test "binary and empty object round trips":
      for body in ["", "abc\0def\xff", repeat('x', 100_000)]:
        discard client.putObject("object", body, "application/test")
        check client.getObject("object") == body
        let info = client.headObject("object")
        check info.contentLength == uint64(body.len)
        check info.contentType == "application/test"
        check info.metadata == @[("fixture", "yes")]
    test "range request":
      discard client.putObject("object", "0123456789")
      check client.getObject("object", 2, 3) == "234"
    test "listing and marker fallback":
      let page = client.listObjects(prefix = "obj", maxKeys = 1)
      check page.isTruncated
      check page.objects.len == 1
      check page.objects[0].key == "object"
      check page.objects[0].size == 10
      check page.nextMarker == "object"
      let last = client.listObjects(marker = page.nextMarker)
      check not last.isTruncated
      check last.objects.len == 0
    test "error details survive callbacks":
      client.deleteObject("object")
      try:
        discard client.getObject("object")
        check false
      except S3Error as e:
        check e.status == S3StatusErrorNoSuchKey
        check "fixture missing" in e.msg
    test "invalid inputs fail before calling C":
      expect ValueError: discard client.getObject("bad\0key")
      expect ValueError: discard client.listObjects(maxKeys = 0)
      expect ValueError: discard newS3Client("b", "a", "s", timeoutMs = -1)
    test "raw lifecycle, status and ACL layout":
      check $S3_get_status_name(S3StatusOK) == "OK"
      check S3_validate_bucket_name("valid-bucket", S3UriStylePath) == S3StatusOK
      var ctx: ptr S3RequestContext
      check S3_create_request_context(addr ctx) == S3StatusOK
      S3_destroy_request_context(ctx)
      var grant: S3AclGrant
      grant.grantee.canonicalUser.id[0] = 'a'
      check grant.grantee.canonicalUser.id[0] == 'a'

main()
