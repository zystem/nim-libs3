import std/os
import libs3

proc main() =
  initializeS3()
  defer: deinitializeS3()
  let client = newS3Client(
    getEnv("S3_BUCKET"), getEnv("AWS_ACCESS_KEY_ID"),
    getEnv("AWS_SECRET_ACCESS_KEY"),
    hostName = getEnv("S3_HOST", "s3.amazonaws.com"),
    region = getEnv("AWS_REGION", "us-east-1"),
    securityToken = getEnv("AWS_SESSION_TOKEN"))
  discard client.putObject("nim-example.txt", "Hello from Nim!", "text/plain")
  echo client.getObject("nim-example.txt")
  echo client.headObject("nim-example.txt").contentLength
  var marker = ""
  while true:
    let page = client.listObjects(marker = marker)
    for item in page.objects: echo item.key
    if not page.isTruncated: break
    marker = page.nextMarker
  client.deleteObject("nim-example.txt")

main()
