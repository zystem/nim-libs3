## Synchronous, binary-safe convenience API for libs3.
## Call initializeS3 once before using clients, and deinitializeS3 after all work.
import libs3/raw
export raw

type
  S3Error* = object of CatchableError
    status*: S3Status
  S3Client* = object
    hostName, bucketName, accessKeyId, secretAccessKey, securityToken, region: string
    protocol: S3Protocol
    uriStyle: S3UriStyle
    timeoutMs: cint
  ObjectInfo* = object
    contentType*, eTag*: string
    contentLength*: uint64
    lastModified*: int64
    metadata*: seq[tuple[name, value: string]]
  ObjectEntry* = object
    key*, eTag*: string
    size*: uint64
    lastModified*: int64
  ObjectPage* = object
    objects*: seq[ObjectEntry]
    commonPrefixes*: seq[string]
    isTruncated*: bool
    nextMarker*: string
  Request = object
    status: S3Status
    message, body: string
    offset: int
    info: ObjectInfo
    page: ObjectPage

proc check(status: S3Status; message = "") =
  if status != S3StatusOK:
    let error = newException(S3Error, $S3_get_status_name(status) &
      (if message.len > 0: ": " & message else: ""))
    error.status = status
    raise error

proc initializeS3*(userAgent = "nim-libs3") =
  ## Process-wide initialization; serialize with all other libs3 lifecycle calls.
  check S3_initialize(userAgent.cstring, S3_INIT_ALL or S3_INIT_VERIFY_PEER, nil)

proc deinitializeS3*() =
  ## Call only after all requests have finished, including raw API requests.
  S3_deinitialize()

proc noNul(value: string) =
  if '\0' in value:
    raise newException(ValueError, "S3 string arguments cannot contain NUL")

proc newS3Client*(bucketName, accessKeyId, secretAccessKey: string;
                  hostName = S3_DEFAULT_HOSTNAME; region = S3_DEFAULT_REGION;
                  securityToken = ""; protocol = S3ProtocolHTTPS;
                  uriStyle = S3UriStylePath; timeoutMs = 30_000): S3Client =
  ## hostName is a hostname[:port], without scheme or path. Credentials are copied.
  for value in [bucketName, accessKeyId, secretAccessKey, hostName, region, securityToken]:
    noNul(value)
  if bucketName.len == 0 or hostName.len == 0 or region.len == 0:
    raise newException(ValueError, "Bucket, host and region must be nonempty")
  if timeoutMs <= 0 or timeoutMs > int(high(cint)):
    raise newException(ValueError, "timeoutMs must fit a positive C int")
  result = S3Client(bucketName: bucketName, accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey, hostName: hostName, region: region,
    securityToken: securityToken, protocol: protocol, uriStyle: uriStyle,
    timeoutMs: cint(timeoutMs))

proc optional(value: string): cstring =
  if value.len == 0: nil else: value.cstring

proc context(c: S3Client): S3BucketContext =
  S3BucketContext(hostName: c.hostName.cstring, bucketName: c.bucketName.cstring,
    protocol: c.protocol, uriStyle: c.uriStyle, accessKeyId: c.accessKeyId.cstring,
    secretAccessKey: c.secretAccessKey.cstring, securityToken: optional(c.securityToken),
    authRegion: c.region.cstring)

proc complete(status: S3Status; details: ptr S3ErrorDetails; data: pointer) {.cdecl, raises: [].} =
  let r = cast[ptr Request](data)
  r.status = status
  if details != nil: r.message = $details.message

proc properties(p: ptr S3ResponseProperties; data: pointer): S3Status {.cdecl, raises: [].} =
  let r = cast[ptr Request](data)
  r.info = ObjectInfo(contentType: $p.contentType, eTag: $p.eTag,
    contentLength: p.contentLength, lastModified: p.lastModified)
  let metadata = cast[ptr UncheckedArray[S3NameValue]](p.metaData)
  for i in 0 ..< int(p.metaDataCount):
    r.info.metadata.add(($metadata[i].name, $metadata[i].value))
  S3StatusOK

proc receive(size: cint; buffer: cstring; data: pointer): S3Status {.cdecl, raises: [].} =
  let r = cast[ptr Request](data)
  let start = r.body.len
  r.body.setLen(start + int(size))
  if size > 0: copyMem(addr r.body[start], buffer, int(size))
  S3StatusOK

proc send(size: cint; buffer: cstring; data: pointer): cint {.cdecl, raises: [].} =
  let r = cast[ptr Request](data)
  let count = min(int(size), r.body.len - r.offset)
  if count > 0: copyMem(buffer, addr r.body[r.offset], count)
  r.offset += count
  cint(count)

proc listCallback(truncated: cint; marker: cstring; count: cint;
                  contents: ptr S3ListBucketContent; prefixCount: cint;
                  prefixes: ptr cstring; data: pointer): S3Status {.cdecl, raises: [].} =
  let r = cast[ptr Request](data)
  r.page.isTruncated = truncated != 0
  r.page.nextMarker = $marker
  let entries = cast[ptr UncheckedArray[S3ListBucketContent]](contents)
  for i in 0 ..< int(count):
    let e = entries[i]
    r.page.objects.add ObjectEntry(key: $e.key, eTag: $e.eTag,
      size: e.size, lastModified: e.lastModified)
  let names = cast[ptr UncheckedArray[cstring]](prefixes)
  for i in 0 ..< int(prefixCount): r.page.commonPrefixes.add $names[i]
  S3StatusOK

proc handler(): S3ResponseHandler =
  S3ResponseHandler(propertiesCallback: properties, completeCallback: complete)

proc getObject*(client: S3Client; key: string; startByte = 0'u64;
                byteCount = 0'u64): string =
  ## Downloads into memory. byteCount = 0 means through the end of the object.
  noNul(key)
  var ctx = context(client)
  var r = Request(status: S3StatusInternalError)
  var h = S3GetObjectHandler(responseHandler: handler(), getObjectDataCallback: receive)
  S3_get_object(addr ctx, key.cstring, nil, startByte, byteCount, nil,
    client.timeoutMs, addr h, addr r)
  check(r.status, r.message)
  result = move(r.body)

proc putObject*(client: S3Client; key, body: string;
                contentType = "application/octet-stream";
                acl = S3CannedAclPrivate): ObjectInfo =
  noNul(key)
  noNul(contentType)
  var ctx = context(client)
  var r = Request(status: S3StatusInternalError, body: body)
  var p = S3PutProperties(contentType: contentType.cstring, expires: -1, cannedAcl: acl)
  var h = S3PutObjectHandler(responseHandler: handler(), putObjectDataCallback: send)
  S3_put_object(addr ctx, key.cstring, uint64(body.len), addr p, nil,
    client.timeoutMs, addr h, addr r)
  check(r.status, r.message)
  result = move(r.info)

proc headObject*(client: S3Client; key: string): ObjectInfo =
  noNul(key)
  var ctx = context(client)
  var r = Request(status: S3StatusInternalError)
  var h = handler()
  S3_head_object(addr ctx, key.cstring, nil, client.timeoutMs, addr h, addr r)
  check(r.status, r.message)
  result = move(r.info)

proc deleteObject*(client: S3Client; key: string) =
  noNul(key)
  var ctx = context(client)
  var r = Request(status: S3StatusInternalError)
  var h = handler()
  S3_delete_object(addr ctx, key.cstring, nil, client.timeoutMs, addr h, addr r)
  check(r.status, r.message)

proc listObjects*(client: S3Client; prefix = ""; marker = "";
                  delimiter = ""; maxKeys = 1000): ObjectPage =
  ## Returns one page. Supply nextMarker for subsequent pages when truncated.
  for value in [prefix, marker, delimiter]: noNul(value)
  if maxKeys < 1 or maxKeys > 1000:
    raise newException(ValueError, "maxKeys must be between 1 and 1000")
  var ctx = context(client)
  var r = Request(status: S3StatusInternalError)
  var h = S3ListBucketHandler(responseHandler: handler(), listBucketCallback: listCallback)
  S3_list_bucket(addr ctx, optional(prefix), optional(marker), optional(delimiter),
    cint(maxKeys), nil, client.timeoutMs, addr h, addr r)
  check(r.status, r.message)
  if r.page.isTruncated and r.page.nextMarker.len == 0 and r.page.objects.len > 0:
    r.page.nextMarker = r.page.objects[^1].key
  result = move(r.page)
