# List Drive endpoints

The googledrive package stores a named list of Drive API v3 endpoints
(or "methods", using Google's vocabulary) internally and these functions
expose this data.

- `drive_endpoint()` returns one endpoint, i.e. it uses `[[`.

- `drive_endpoints()` returns a list of endpoints, i.e. it uses `[`.

The names of this list (or the `id` sub-elements) are the nicknames that
can be used to specify an endpoint in
[`request_generate()`](https://googledrive.tidyverse.org/dev/reference/request_generate.md).
For each endpoint, we store its nickname or `id`, the associated HTTP
verb, the `path`, and details about the parameters. This list is derived
programmatically from the Drive API v3 Discovery Document
(`https://www.googleapis.com/discovery/v1/apis/drive/v3/rest`) using the
approach described in the [Discovery Documents
section](https://gargle.r-lib.org/articles/request-helper-functions.html#discovery-documents)
of the gargle vignette [Request helper
functions](https://gargle.r-lib.org/articles/request-helper-functions.html).

## Usage

``` r
drive_endpoints(i = NULL)

drive_endpoint(i)
```

## Arguments

- i:

  The name(s) or integer index(ices) of the endpoints to return. `i` is
  optional for `drive_endpoints()` and, if not given, the entire list is
  returned.

## Value

One or more of the Drive API v3 endpoints that are used internally by
googledrive.

## Examples

``` r
str(head(drive_endpoints(), 3), max.level = 2)
#> List of 3
#>  $ drive.replies.list  :List of 8
#>   ..$ id            : chr "drive.replies.list"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "drive/v3/files/{fileId}/comments/{commentId}/replies"
#>   ..$ parameters    :List of 16
#>   ..$ scopes        : chr "drive, drive.file, drive.meet.readonly, drive.readonly"
#>   ..$ description   : chr "Lists a comment's replies. For more information, see [Manage comments and replies](https://developers.google.co"| __truncated__
#>   ..$ response      : chr "ReplyList"
#>   ..$ parameterOrder: chr [1:2] "fileId" "commentId"
#>  $ drive.replies.delete:List of 7
#>   ..$ id            : chr "drive.replies.delete"
#>   ..$ httpMethod    : chr "DELETE"
#>   ..$ path          : 'fs_path' chr "drive/v3/files/{fileId}/comments/{commentId}/replies/{replyId}"
#>   ..$ parameters    :List of 14
#>   ..$ scopes        : chr "drive, drive.file"
#>   ..$ description   : chr "Deletes a reply. For more information, see [Manage comments and replies](https://developers.google.com/workspac"| __truncated__
#>   ..$ parameterOrder: chr [1:3] "fileId" "commentId" "replyId"
#>  $ drive.replies.update:List of 9
#>   ..$ id            : chr "drive.replies.update"
#>   ..$ httpMethod    : chr "PATCH"
#>   ..$ path          : 'fs_path' chr "drive/v3/files/{fileId}/comments/{commentId}/replies/{replyId}"
#>   ..$ parameters    :List of 25
#>   ..$ scopes        : chr "drive, drive.file"
#>   ..$ description   : chr "Updates a reply with patch semantics. For more information, see [Manage comments and replies](https://developer"| __truncated__
#>   ..$ request       : chr "Reply"
#>   ..$ response      : chr "Reply"
#>   ..$ parameterOrder: chr [1:3] "fileId" "commentId" "replyId"
drive_endpoint("drive.files.delete")
#> $id
#> [1] "drive.files.delete"
#> 
#> $httpMethod
#> [1] "DELETE"
#> 
#> $path
#> drive/v3/files/{fileId}
#> 
#> $parameters
#> $parameters$supportsTeamDrives
#> $parameters$supportsTeamDrives$deprecated
#> [1] TRUE
#> 
#> $parameters$supportsTeamDrives$location
#> [1] "query"
#> 
#> $parameters$supportsTeamDrives$default
#> [1] "false"
#> 
#> $parameters$supportsTeamDrives$description
#> [1] "Deprecated: Use `supportsAllDrives` instead."
#> 
#> $parameters$supportsTeamDrives$type
#> [1] "boolean"
#> 
#> 
#> $parameters$fileId
#> $parameters$fileId$type
#> [1] "string"
#> 
#> $parameters$fileId$description
#> [1] "The ID of the file."
#> 
#> $parameters$fileId$location
#> [1] "path"
#> 
#> $parameters$fileId$required
#> [1] TRUE
#> 
#> 
#> $parameters$enforceSingleParent
#> $parameters$enforceSingleParent$default
#> [1] "false"
#> 
#> $parameters$enforceSingleParent$type
#> [1] "boolean"
#> 
#> $parameters$enforceSingleParent$location
#> [1] "query"
#> 
#> $parameters$enforceSingleParent$description
#> [1] "Deprecated: If an item isn't in a shared drive and its last parent is deleted but the item itself isn't, the item will be placed under its owner's root."
#> 
#> $parameters$enforceSingleParent$deprecated
#> [1] TRUE
#> 
#> 
#> $parameters$supportsAllDrives
#> $parameters$supportsAllDrives$type
#> [1] "boolean"
#> 
#> $parameters$supportsAllDrives$description
#> [1] "Whether the requesting application supports both My Drives and shared drives."
#> 
#> $parameters$supportsAllDrives$location
#> [1] "query"
#> 
#> $parameters$supportsAllDrives$default
#> [1] "false"
#> 
#> 
#> $parameters$upload_protocol
#> $parameters$upload_protocol$type
#> [1] "string"
#> 
#> $parameters$upload_protocol$location
#> [1] "query"
#> 
#> $parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> 
#> $parameters$prettyPrint
#> $parameters$prettyPrint$location
#> [1] "query"
#> 
#> $parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $parameters$prettyPrint$default
#> [1] "true"
#> 
#> 
#> $parameters$callback
#> $parameters$callback$location
#> [1] "query"
#> 
#> $parameters$callback$type
#> [1] "string"
#> 
#> $parameters$callback$description
#> [1] "JSONP"
#> 
#> 
#> $parameters$access_token
#> $parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $parameters$access_token$type
#> [1] "string"
#> 
#> $parameters$access_token$location
#> [1] "query"
#> 
#> 
#> $parameters$fields
#> $parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $parameters$fields$type
#> [1] "string"
#> 
#> $parameters$fields$location
#> [1] "query"
#> 
#> 
#> $parameters$`$.xgafv`
#> $parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> $parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> 
#> $parameters$alt
#> $parameters$alt$type
#> [1] "string"
#> 
#> $parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> $parameters$alt$default
#> [1] "json"
#> 
#> $parameters$alt$location
#> [1] "query"
#> 
#> $parameters$alt$enum
#> [1] "json"  "media" "proto"
#> 
#> $parameters$alt$description
#> [1] "Data format for response."
#> 
#> 
#> $parameters$key
#> $parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> $parameters$key$type
#> [1] "string"
#> 
#> $parameters$key$location
#> [1] "query"
#> 
#> 
#> $parameters$quotaUser
#> $parameters$quotaUser$type
#> [1] "string"
#> 
#> $parameters$quotaUser$description
#> [1] "Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters."
#> 
#> $parameters$quotaUser$location
#> [1] "query"
#> 
#> 
#> $parameters$oauth_token
#> $parameters$oauth_token$type
#> [1] "string"
#> 
#> $parameters$oauth_token$location
#> [1] "query"
#> 
#> $parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> 
#> $parameters$uploadType
#> $parameters$uploadType$location
#> [1] "query"
#> 
#> $parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $parameters$uploadType$type
#> [1] "string"
#> 
#> 
#> 
#> $scopes
#> [1] "drive, drive.appdata, drive.file"
#> 
#> $description
#> [1] "Permanently deletes a file owned by the user without moving it to the trash. For more information, see [Trash or delete files and folders](https://developers.google.com/workspace/drive/api/guides/delete). If the file belongs to a shared drive, the user must be an `organizer` on the parent folder. If the target is a folder, all descendants owned by the user are also deleted."
#> 
#> $parameterOrder
#> [1] "fileId"
#> 
drive_endpoint(4)
#> $id
#> [1] "drive.replies.get"
#> 
#> $httpMethod
#> [1] "GET"
#> 
#> $path
#> drive/v3/files/{fileId}/comments/{commentId}/replies/{replyId}
#> 
#> $parameters
#> $parameters$fileId
#> $parameters$fileId$description
#> [1] "The ID of the file."
#> 
#> $parameters$fileId$location
#> [1] "path"
#> 
#> $parameters$fileId$type
#> [1] "string"
#> 
#> $parameters$fileId$required
#> [1] TRUE
#> 
#> 
#> $parameters$includeDeleted
#> $parameters$includeDeleted$type
#> [1] "boolean"
#> 
#> $parameters$includeDeleted$description
#> [1] "Whether to return deleted replies. Deleted replies don't include their original content."
#> 
#> $parameters$includeDeleted$location
#> [1] "query"
#> 
#> $parameters$includeDeleted$default
#> [1] "false"
#> 
#> 
#> $parameters$commentId
#> $parameters$commentId$required
#> [1] TRUE
#> 
#> $parameters$commentId$type
#> [1] "string"
#> 
#> $parameters$commentId$description
#> [1] "The ID of the comment."
#> 
#> $parameters$commentId$location
#> [1] "path"
#> 
#> 
#> $parameters$replyId
#> $parameters$replyId$required
#> [1] TRUE
#> 
#> $parameters$replyId$location
#> [1] "path"
#> 
#> $parameters$replyId$description
#> [1] "The ID of the reply."
#> 
#> $parameters$replyId$type
#> [1] "string"
#> 
#> 
#> $parameters$upload_protocol
#> $parameters$upload_protocol$type
#> [1] "string"
#> 
#> $parameters$upload_protocol$location
#> [1] "query"
#> 
#> $parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> 
#> $parameters$prettyPrint
#> $parameters$prettyPrint$location
#> [1] "query"
#> 
#> $parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $parameters$prettyPrint$default
#> [1] "true"
#> 
#> 
#> $parameters$callback
#> $parameters$callback$location
#> [1] "query"
#> 
#> $parameters$callback$type
#> [1] "string"
#> 
#> $parameters$callback$description
#> [1] "JSONP"
#> 
#> 
#> $parameters$access_token
#> $parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $parameters$access_token$type
#> [1] "string"
#> 
#> $parameters$access_token$location
#> [1] "query"
#> 
#> 
#> $parameters$fields
#> $parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $parameters$fields$type
#> [1] "string"
#> 
#> $parameters$fields$location
#> [1] "query"
#> 
#> 
#> $parameters$`$.xgafv`
#> $parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> $parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> 
#> $parameters$alt
#> $parameters$alt$type
#> [1] "string"
#> 
#> $parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> $parameters$alt$default
#> [1] "json"
#> 
#> $parameters$alt$location
#> [1] "query"
#> 
#> $parameters$alt$enum
#> [1] "json"  "media" "proto"
#> 
#> $parameters$alt$description
#> [1] "Data format for response."
#> 
#> 
#> $parameters$key
#> $parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> $parameters$key$type
#> [1] "string"
#> 
#> $parameters$key$location
#> [1] "query"
#> 
#> 
#> $parameters$quotaUser
#> $parameters$quotaUser$type
#> [1] "string"
#> 
#> $parameters$quotaUser$description
#> [1] "Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters."
#> 
#> $parameters$quotaUser$location
#> [1] "query"
#> 
#> 
#> $parameters$oauth_token
#> $parameters$oauth_token$type
#> [1] "string"
#> 
#> $parameters$oauth_token$location
#> [1] "query"
#> 
#> $parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> 
#> $parameters$uploadType
#> $parameters$uploadType$location
#> [1] "query"
#> 
#> $parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $parameters$uploadType$type
#> [1] "string"
#> 
#> 
#> 
#> $scopes
#> [1] "drive, drive.file, drive.meet.readonly, drive.readonly"
#> 
#> $description
#> [1] "Gets a reply by ID. For more information, see [Manage comments and replies](https://developers.google.com/workspace/drive/api/guides/manage-comments)."
#> 
#> $response
#> [1] "Reply"
#> 
#> $parameterOrder
#> [1] "fileId"    "commentId" "replyId"  
#> 
```
