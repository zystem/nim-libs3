#[
Upstream header notice (preserved verbatim):
/** **************************************************************************
 * @file libs3.h
 * @details
 * Copyright 2008 Bryan Ischo <bryan@ischo.com>
 *
 * This file is part of libs3.
 *
 * libs3 is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, version 3 or above of the License.  You can also
 * redistribute and/or modify it under the terms of the GNU General Public
 * License, version 2 or above of the License.
 *
 * In addition, as a special exception, the copyright holders give
 * permission to link the code of this library and its programs with the
 * OpenSSL library, and distribute linked combinations including the two.
 *
 * libs3 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * version 3 along with libs3, in a file named COPYING.  If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * You should also have received a copy of the GNU General Public License
 * version 2 along with libs3, in a file named COPYING-GPLv2.  If not, see
 * <http://www.gnu.org/licenses/>.
 *
 ************************************************************************** **/
]#
## See libs3/NOTICE.txt for provenance and third-party license terms.
## Low-level bindings for bji/libs3 4.1. Requires libs3.h and -ls3.
## Generated with tools/generate_bindings.py; C owns callback arguments.
import std/posix
{.passL: "-ls3".}

const
  S3_MAX_HOSTNAME_SIZE* = 255
  S3_DEFAULT_HOSTNAME* = "s3.amazonaws.com"
  S3_MAX_BUCKET_NAME_SIZE* = 255
  S3_MAX_KEY_SIZE* = 1024
  S3_MAX_METADATA_SIZE* = 2048
  S3_METADATA_HEADER_NAME_PREFIX* = "x-amz-meta-"
  S3_MAX_ACL_GRANT_COUNT* = 100
  S3_MAX_GRANTEE_EMAIL_ADDRESS_SIZE* = 128
  S3_MAX_GRANTEE_USER_ID_SIZE* = 128
  S3_MAX_GRANTEE_DISPLAY_NAME_SIZE* = 128
  S3_INIT_WINSOCK* = 1
  S3_INIT_VERIFY_PEER* = 2
  S3_INIT_ALL* = S3_INIT_WINSOCK
  S3_DEFAULT_REGION* = "us-east-1"

type
  S3Status* {.importc, header: "libs3.h", size: sizeof(cint).} = enum
    S3StatusOK
    S3StatusInternalError
    S3StatusOutOfMemory
    S3StatusInterrupted
    S3StatusInvalidBucketNameTooLong
    S3StatusInvalidBucketNameFirstCharacter
    S3StatusInvalidBucketNameCharacter
    S3StatusInvalidBucketNameCharacterSequence
    S3StatusInvalidBucketNameTooShort
    S3StatusInvalidBucketNameDotQuadNotation
    S3StatusQueryParamsTooLong
    S3StatusFailedToInitializeRequest
    S3StatusMetaDataHeadersTooLong
    S3StatusBadMetaData
    S3StatusBadContentType
    S3StatusContentTypeTooLong
    S3StatusBadMD5
    S3StatusMD5TooLong
    S3StatusBadCacheControl
    S3StatusCacheControlTooLong
    S3StatusBadContentDispositionFilename
    S3StatusContentDispositionFilenameTooLong
    S3StatusBadContentEncoding
    S3StatusContentEncodingTooLong
    S3StatusBadIfMatchETag
    S3StatusIfMatchETagTooLong
    S3StatusBadIfNotMatchETag
    S3StatusIfNotMatchETagTooLong
    S3StatusHeadersTooLong
    S3StatusKeyTooLong
    S3StatusUriTooLong
    S3StatusXmlParseFailure
    S3StatusEmailAddressTooLong
    S3StatusUserIdTooLong
    S3StatusUserDisplayNameTooLong
    S3StatusGroupUriTooLong
    S3StatusPermissionTooLong
    S3StatusTargetBucketTooLong
    S3StatusTargetPrefixTooLong
    S3StatusTooManyGrants
    S3StatusBadGrantee
    S3StatusBadPermission
    S3StatusXmlDocumentTooLarge
    S3StatusNameLookupError
    S3StatusFailedToConnect
    S3StatusServerFailedVerification
    S3StatusConnectionFailed
    S3StatusAbortedByCallback
    S3StatusNotSupported
    S3StatusErrorAccessDenied
    S3StatusErrorAccountProblem
    S3StatusErrorAmbiguousGrantByEmailAddress
    S3StatusErrorBadDigest
    S3StatusErrorBucketAlreadyExists
    S3StatusErrorBucketAlreadyOwnedByYou
    S3StatusErrorBucketNotEmpty
    S3StatusErrorCredentialsNotSupported
    S3StatusErrorCrossLocationLoggingProhibited
    S3StatusErrorEntityTooSmall
    S3StatusErrorEntityTooLarge
    S3StatusErrorExpiredToken
    S3StatusErrorIllegalVersioningConfigurationException
    S3StatusErrorIncompleteBody
    S3StatusErrorIncorrectNumberOfFilesInPostRequest
    S3StatusErrorInlineDataTooLarge
    S3StatusErrorInternalError
    S3StatusErrorInvalidAccessKeyId
    S3StatusErrorInvalidAddressingHeader
    S3StatusErrorInvalidArgument
    S3StatusErrorInvalidBucketName
    S3StatusErrorInvalidBucketState
    S3StatusErrorInvalidDigest
    S3StatusErrorInvalidEncryptionAlgorithmError
    S3StatusErrorInvalidLocationConstraint
    S3StatusErrorInvalidObjectState
    S3StatusErrorInvalidPart
    S3StatusErrorInvalidPartOrder
    S3StatusErrorInvalidPayer
    S3StatusErrorInvalidPolicyDocument
    S3StatusErrorInvalidRange
    S3StatusErrorInvalidRequest
    S3StatusErrorInvalidSecurity
    S3StatusErrorInvalidSOAPRequest
    S3StatusErrorInvalidStorageClass
    S3StatusErrorInvalidTargetBucketForLogging
    S3StatusErrorInvalidToken
    S3StatusErrorInvalidURI
    S3StatusErrorKeyTooLong
    S3StatusErrorMalformedACLError
    S3StatusErrorMalformedPOSTRequest
    S3StatusErrorMalformedXML
    S3StatusErrorMaxMessageLengthExceeded
    S3StatusErrorMaxPostPreDataLengthExceededError
    S3StatusErrorMetadataTooLarge
    S3StatusErrorMethodNotAllowed
    S3StatusErrorMissingAttachment
    S3StatusErrorMissingContentLength
    S3StatusErrorMissingRequestBodyError
    S3StatusErrorMissingSecurityElement
    S3StatusErrorMissingSecurityHeader
    S3StatusErrorNoLoggingStatusForKey
    S3StatusErrorNoSuchBucket
    S3StatusErrorNoSuchKey
    S3StatusErrorNoSuchLifecycleConfiguration
    S3StatusErrorNoSuchUpload
    S3StatusErrorNoSuchVersion
    S3StatusErrorNotImplemented
    S3StatusErrorNotSignedUp
    S3StatusErrorNoSuchBucketPolicy
    S3StatusErrorOperationAborted
    S3StatusErrorPermanentRedirect
    S3StatusErrorPreconditionFailed
    S3StatusErrorRedirect
    S3StatusErrorRestoreAlreadyInProgress
    S3StatusErrorRequestIsNotMultiPartContent
    S3StatusErrorRequestTimeout
    S3StatusErrorRequestTimeTooSkewed
    S3StatusErrorRequestTorrentOfBucketError
    S3StatusErrorSignatureDoesNotMatch
    S3StatusErrorServiceUnavailable
    S3StatusErrorSlowDown
    S3StatusErrorTemporaryRedirect
    S3StatusErrorTokenRefreshRequired
    S3StatusErrorTooManyBuckets
    S3StatusErrorUnexpectedContent
    S3StatusErrorUnresolvableGrantByEmailAddress
    S3StatusErrorUserKeyMustBeSpecified
    S3StatusErrorQuotaExceeded
    S3StatusErrorUnknown
    S3StatusHttpErrorMovedTemporarily
    S3StatusHttpErrorBadRequest
    S3StatusHttpErrorForbidden
    S3StatusHttpErrorNotFound
    S3StatusHttpErrorConflict
    S3StatusHttpErrorUnknown
  S3Protocol* {.importc, header: "libs3.h", size: sizeof(cint).} = enum
    S3ProtocolHTTPS                     = 0
    S3ProtocolHTTP                      = 1
  S3UriStyle* {.importc, header: "libs3.h", size: sizeof(cint).} = enum
    S3UriStyleVirtualHost               = 0
    S3UriStylePath                      = 1
  S3GranteeType* {.importc, header: "libs3.h", size: sizeof(cint).} = enum
    S3GranteeTypeAmazonCustomerByEmail  = 0
    S3GranteeTypeCanonicalUser          = 1
    S3GranteeTypeAllAwsUsers            = 2
    S3GranteeTypeAllUsers               = 3
    S3GranteeTypeLogDelivery            = 4
  S3Permission* {.importc, header: "libs3.h", size: sizeof(cint).} = enum
    S3PermissionRead                    = 0
    S3PermissionWrite                   = 1
    S3PermissionReadACP                 = 2
    S3PermissionWriteACP                = 3
    S3PermissionFullControl             = 4
  S3CannedAcl* {.importc, header: "libs3.h", size: sizeof(cint).} = enum
    S3CannedAclPrivate                  = 0
    S3CannedAclPublicRead               = 1
    S3CannedAclPublicReadWrite          = 2
    S3CannedAclAuthenticatedRead        = 3
    S3CannedAclBucketOwnerFullControl   = 4
  S3RequestContext* {.importc, header: "libs3.h", incompleteStruct.} = object
  S3EmailGrantee* {.bycopy.} = object
    emailAddress*: array[128, cchar]
  S3CanonicalGrantee* {.bycopy.} = object
    id*: array[128, cchar]
    displayName*: array[128, cchar]
  S3Grantee* {.union, bycopy.} = object
    amazonCustomerByEmail*: S3EmailGrantee
    canonicalUser*: S3CanonicalGrantee
  S3NameValue* {.importc, header: "libs3.h", bycopy.} = object
    `name`*: cstring
    `value`*: cstring
  S3ResponseProperties* {.importc, header: "libs3.h", bycopy.} = object
    `requestId`*: cstring
    `requestId2`*: cstring
    `contentType`*: cstring
    `contentLength`*: uint64
    `server`*: cstring
    `eTag`*: cstring
    `lastModified`*: int64
    `metaDataCount`*: cint
    `metaData`*: ptr S3NameValue
    `usesServerSideEncryption`*: cchar
  S3AclGrant* {.importc, header: "libs3.h", bycopy.} = object
    granteeType*: S3GranteeType
    grantee*: S3Grantee
    permission*: S3Permission
  S3BucketContext* {.importc, header: "libs3.h", bycopy.} = object
    `hostName`*: cstring
    `bucketName`*: cstring
    `protocol`*: S3Protocol
    `uriStyle`*: S3UriStyle
    `accessKeyId`*: cstring
    `secretAccessKey`*: cstring
    `securityToken`*: cstring
    `authRegion`*: cstring
  S3ListBucketContent* {.importc, header: "libs3.h", bycopy.} = object
    `key`*: cstring
    `lastModified`*: int64
    `eTag`*: cstring
    `size`*: uint64
    `ownerId`*: cstring
    `ownerDisplayName`*: cstring
  S3ListMultipartUpload* {.importc, header: "libs3.h", bycopy.} = object
    `key`*: cstring
    `uploadId`*: cstring
    `initiatorId`*: cstring
    `initiatorDisplayName`*: cstring
    `ownerId`*: cstring
    `ownerDisplayName`*: cstring
    `storageClass`*: cstring
    `initiated`*: int64
  S3ListPart* {.importc, header: "libs3.h", bycopy.} = object
    `eTag`*: cstring
    `lastModified`*: int64
    `partNumber`*: uint64
    `size`*: uint64
  S3PutProperties* {.importc, header: "libs3.h", bycopy.} = object
    `contentType`*: cstring
    `md5`*: cstring
    `cacheControl`*: cstring
    `contentDispositionFilename`*: cstring
    `contentEncoding`*: cstring
    `expires`*: int64
    `cannedAcl`*: S3CannedAcl
    `metaDataCount`*: cint
    `metaData`*: ptr S3NameValue
    `useServerSideEncryption`*: cchar
  S3GetConditions* {.importc, header: "libs3.h", bycopy.} = object
    `ifModifiedSince`*: int64
    `ifNotModifiedSince`*: int64
    `ifMatchETag`*: cstring
    `ifNotMatchETag`*: cstring
  S3ErrorDetails* {.importc, header: "libs3.h", bycopy.} = object
    `message`*: cstring
    `resource`*: cstring
    `furtherDetails`*: cstring
    `extraDetailsCount`*: cint
    `extraDetails`*: ptr S3NameValue
  S3ResponseHandler* {.importc, header: "libs3.h", bycopy.} = object
    `propertiesCallback`*: S3ResponsePropertiesCallback
    `completeCallback`*: S3ResponseCompleteCallback
  S3ListServiceHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `listServiceCallback`*: S3ListServiceCallback
  S3ListBucketHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `listBucketCallback`*: S3ListBucketCallback
  S3PutObjectHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `putObjectDataCallback`*: S3PutObjectDataCallback
  S3GetObjectHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `getObjectDataCallback`*: S3GetObjectDataCallback
  S3MultipartInitialHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `responseXmlCallback`*: S3MultipartInitialResponseCallback
  S3MultipartCommitHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `putObjectDataCallback`*: S3PutObjectDataCallback
    `responseXmlCallback`*: S3MultipartCommitResponseCallback
  S3ListMultipartUploadsHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `responseXmlCallback`*: S3ListMultipartUploadsResponseCallback
  S3ListPartsHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
    `responseXmlCallback`*: S3ListPartsResponseCallback
  S3AbortMultipartUploadHandler* {.importc, header: "libs3.h", bycopy.} = object
    `responseHandler`*: S3ResponseHandler
  S3ResponsePropertiesCallback* = proc (`properties`: ptr S3ResponseProperties; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3ResponseCompleteCallback* = proc (`status`: S3Status; `errorDetails`: ptr S3ErrorDetails; `callbackData`: pointer): void {.cdecl, raises: [].}
  S3ListServiceCallback* = proc (`ownerId`: cstring; `ownerDisplayName`: cstring; `bucketName`: cstring; `creationDateSeconds`: int64; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3ListBucketCallback* = proc (`isTruncated`: cint; `nextMarker`: cstring; `contentsCount`: cint; `contents`: ptr S3ListBucketContent; `commonPrefixesCount`: cint; `commonPrefixes`: ptr cstring; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3PutObjectDataCallback* = proc (`bufferSize`: cint; `buffer`: cstring; `callbackData`: pointer): cint {.cdecl, raises: [].}
  S3GetObjectDataCallback* = proc (`bufferSize`: cint; `buffer`: cstring; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3MultipartInitialResponseCallback* = proc (`upload_id`: cstring; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3ListMultipartUploadsResponseCallback* = proc (`isTruncated`: cint; `nextKeyMarker`: cstring; `nextUploadIdMarker`: cstring; `uploadsCount`: cint; `uploads`: ptr S3ListMultipartUpload; `commonPrefixesCount`: cint; `commonPrefixes`: ptr cstring; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3ListPartsResponseCallback* = proc (`isTruncated`: cint; `nextPartNumberMarker`: cstring; `initiatorId`: cstring; `initiatorDisplayName`: cstring; `ownerId`: cstring; `ownerDisplayName`: cstring; `storageClass`: cstring; `partsCount`: cint; `lastPartNumber`: cint; `parts`: ptr S3ListPart; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3MultipartCommitResponseCallback* = proc (`location`: cstring; `etag`: cstring; `callbackData`: pointer): S3Status {.cdecl, raises: [].}
  S3SetupCurlCallback* = proc (`curlMulti`: pointer; `curlEasy`: pointer; `setupData`: pointer): S3Status {.cdecl, raises: [].}
proc S3_initialize*(`userAgentInfo`: cstring; `flags`: cint; `defaultS3HostName`: cstring): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_deinitialize*(): void {.cdecl, importc, header: "libs3.h".}
proc S3_get_status_name*(`status`: S3Status): cstring {.cdecl, importc, header: "libs3.h".}
proc S3_validate_bucket_name*(`bucketName`: cstring; `uriStyle`: S3UriStyle): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_convert_acl*(`aclXml`: cstring; `ownerId`: cstring; `ownerDisplayName`: cstring; `aclGrantCountReturn`: ptr cint; `aclGrants`: ptr S3AclGrant): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_status_is_retryable*(`status`: S3Status): cint {.cdecl, importc, header: "libs3.h".}
proc S3_create_request_context*(`requestContextReturn`: ptr ptr S3RequestContext): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_create_request_context_ex*(`requestContextReturn`: ptr ptr S3RequestContext; `curlMulti`: pointer; `setupCurlCallback`: S3SetupCurlCallback; `setupCurlCallbackData`: pointer): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_destroy_request_context*(`requestContext`: ptr S3RequestContext): void {.cdecl, importc, header: "libs3.h".}
proc S3_runall_request_context*(`requestContext`: ptr S3RequestContext): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_runonce_request_context*(`requestContext`: ptr S3RequestContext; `requestsRemainingReturn`: ptr cint): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_process_request_context*(`requestContext`: ptr S3RequestContext): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_get_request_context_fdsets*(`requestContext`: ptr S3RequestContext; `readFdSet`: ptr TFdSet; `writeFdSet`: ptr TFdSet; `exceptFdSet`: ptr TFdSet; `maxFd`: ptr cint): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_get_request_context_timeout*(`requestContext`: ptr S3RequestContext): int64 {.cdecl, importc, header: "libs3.h".}
proc S3_set_request_context_verify_peer*(`requestContext`: ptr S3RequestContext; `verifyPeer`: cint): void {.cdecl, importc, header: "libs3.h".}
proc S3_generate_authenticated_query_string*(`buffer`: cstring; `bucketContext`: ptr S3BucketContext; `key`: cstring; `expires`: cint; `resource`: cstring; `httpMethod`: cstring): S3Status {.cdecl, importc, header: "libs3.h".}
proc S3_list_service*(`protocol`: S3Protocol; `accessKeyId`: cstring; `secretAccessKey`: cstring; `securityToken`: cstring; `hostName`: cstring; `authRegion`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ListServiceHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_test_bucket*(`protocol`: S3Protocol; `uriStyle`: S3UriStyle; `accessKeyId`: cstring; `secretAccessKey`: cstring; `securityToken`: cstring; `hostName`: cstring; `bucketName`: cstring; `authRegion`: cstring; `locationConstraintReturnSize`: cint; `locationConstraintReturn`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_create_bucket*(`protocol`: S3Protocol; `accessKeyId`: cstring; `secretAccessKey`: cstring; `securityToken`: cstring; `hostName`: cstring; `bucketName`: cstring; `authRegion`: cstring; `cannedAcl`: S3CannedAcl; `locationConstraint`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_delete_bucket*(`protocol`: S3Protocol; `uriStyle`: S3UriStyle; `accessKeyId`: cstring; `secretAccessKey`: cstring; `securityToken`: cstring; `hostName`: cstring; `bucketName`: cstring; `authRegion`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_list_bucket*(`bucketContext`: ptr S3BucketContext; `prefix`: cstring; `marker`: cstring; `delimiter`: cstring; `maxkeys`: cint; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ListBucketHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_put_object*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `contentLength`: uint64; `putProperties`: ptr S3PutProperties; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3PutObjectHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_copy_object*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `destinationBucket`: cstring; `destinationKey`: cstring; `putProperties`: ptr S3PutProperties; `lastModifiedReturn`: ptr int64; `eTagReturnSize`: cint; `eTagReturn`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_copy_object_range*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `destinationBucket`: cstring; `destinationKey`: cstring; `partNo`: cint; `uploadId`: cstring; `startOffset`: culong; `count`: culong; `putProperties`: ptr S3PutProperties; `lastModifiedReturn`: ptr int64; `eTagReturnSize`: cint; `eTagReturn`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_get_object*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `getConditions`: ptr S3GetConditions; `startByte`: uint64; `byteCount`: uint64; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3GetObjectHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_head_object*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_delete_object*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_get_acl*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `ownerId`: cstring; `ownerDisplayName`: cstring; `aclGrantCountReturn`: ptr cint; `aclGrants`: ptr S3AclGrant; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_set_acl*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `ownerId`: cstring; `ownerDisplayName`: cstring; `aclGrantCount`: cint; `aclGrants`: ptr S3AclGrant; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_get_lifecycle*(`bucketContext`: ptr S3BucketContext; `lifecycleXmlDocumentReturn`: cstring; `lifecycleXmlDocumentBufferSize`: cint; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_set_lifecycle*(`bucketContext`: ptr S3BucketContext; `lifecycleXmlDocument`: cstring; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_get_server_access_logging*(`bucketContext`: ptr S3BucketContext; `targetBucketReturn`: cstring; `targetPrefixReturn`: cstring; `aclGrantCountReturn`: ptr cint; `aclGrants`: ptr S3AclGrant; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_set_server_access_logging*(`bucketContext`: ptr S3BucketContext; `targetBucket`: cstring; `targetPrefix`: cstring; `aclGrantCount`: cint; `aclGrants`: ptr S3AclGrant; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ResponseHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_initiate_multipart*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `putProperties`: ptr S3PutProperties; `handler`: ptr S3MultipartInitialHandler; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_upload_part*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `putProperties`: ptr S3PutProperties; `handler`: ptr S3PutObjectHandler; `seq`: cint; `upload_id`: cstring; `partContentLength`: cint; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_complete_multipart_upload*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `handler`: ptr S3MultipartCommitHandler; `upload_id`: cstring; `contentLength`: cint; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_list_parts*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `partnumbermarker`: cstring; `uploadid`: cstring; `encodingtype`: cstring; `maxparts`: cint; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ListPartsHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
proc S3_abort_multipart_upload*(`bucketContext`: ptr S3BucketContext; `key`: cstring; `uploadId`: cstring; `timeoutMs`: cint; `handler`: ptr S3AbortMultipartUploadHandler): void {.cdecl, importc, header: "libs3.h".}
proc S3_list_multipart_uploads*(`bucketContext`: ptr S3BucketContext; `prefix`: cstring; `keymarker`: cstring; `uploadidmarker`: cstring; `encodingtype`: cstring; `delimiter`: cstring; `maxuploads`: cint; `requestContext`: ptr S3RequestContext; `timeoutMs`: cint; `handler`: ptr S3ListMultipartUploadsHandler; `callbackData`: pointer): void {.cdecl, importc, header: "libs3.h".}
