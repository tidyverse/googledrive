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
#>  $ drive.comments.update:List of 9
#>   ..$ id            : chr "drive.comments.update"
#>   ..$ httpMethod    : chr "PATCH"
#>   ..$ path          : 'fs_path' chr "drive/v3/files/{fileId}/comments/{commentId}"
#>   ..$ parameters    :List of 27
#>   ..$ scopes        : chr "drive, drive.file"
#>   ..$ description   : chr "Updates a comment with patch semantics. For more information, see [Manage comments and replies](https://develop"| __truncated__
#>   ..$ request       : chr "Comment"
#>   ..$ response      : chr "Comment"
#>   ..$ parameterOrder: chr [1:2] "fileId" "commentId"
#>  $ drive.comments.delete:List of 7
#>   ..$ id            : chr "drive.comments.delete"
#>   ..$ httpMethod    : chr "DELETE"
#>   ..$ path          : 'fs_path' chr "drive/v3/files/{fileId}/comments/{commentId}"
#>   ..$ parameters    :List of 13
#>   ..$ scopes        : chr "drive, drive.file"
#>   ..$ description   : chr "Deletes a comment. For more information, see [Manage comments and replies](https://developers.google.com/worksp"| __truncated__
#>   ..$ parameterOrder: chr [1:2] "fileId" "commentId"
#>  $ drive.comments.create:List of 9
#>   ..$ id            : chr "drive.comments.create"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "drive/v3/files/{fileId}/comments"
#>   ..$ parameters    :List of 26
#>   ..$ scopes        : chr "drive, drive.file"
#>   ..$ description   : chr "Creates a comment on a file. For more information, see [Manage comments and replies](https://developers.google."| __truncated__
#>   ..$ request       : chr "Comment"
#>   ..$ response      : chr "Comment"
#>   ..$ parameterOrder: chr "fileId"
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
#> $parameters$supportsTeamDrives$default
#> [1] "false"
#> 
#> $parameters$supportsTeamDrives$type
#> [1] "boolean"
#> 
#> $parameters$supportsTeamDrives$deprecated
#> [1] TRUE
#> 
#> $parameters$supportsTeamDrives$location
#> [1] "query"
#> 
#> $parameters$supportsTeamDrives$description
#> [1] "Deprecated: Use `supportsAllDrives` instead."
#> 
#> 
#> $parameters$enforceSingleParent
#> $parameters$enforceSingleParent$location
#> [1] "query"
#> 
#> $parameters$enforceSingleParent$type
#> [1] "boolean"
#> 
#> $parameters$enforceSingleParent$description
#> [1] "Deprecated: If an item isn't in a shared drive and its last parent is deleted but the item itself isn't, the item will be placed under its owner's root."
#> 
#> $parameters$enforceSingleParent$default
#> [1] "false"
#> 
#> $parameters$enforceSingleParent$deprecated
#> [1] TRUE
#> 
#> 
#> $parameters$supportsAllDrives
#> $parameters$supportsAllDrives$location
#> [1] "query"
#> 
#> $parameters$supportsAllDrives$default
#> [1] "false"
#> 
#> $parameters$supportsAllDrives$type
#> [1] "boolean"
#> 
#> $parameters$supportsAllDrives$description
#> [1] "Whether the requesting application supports both My Drives and shared drives."
#> 
#> 
#> $parameters$fileId
#> $parameters$fileId$required
#> [1] TRUE
#> 
#> $parameters$fileId$location
#> [1] "path"
#> 
#> $parameters$fileId$type
#> [1] "string"
#> 
#> $parameters$fileId$description
#> [1] "The ID of the file."
#> 
#> 
#> $parameters$access_token
#> $parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $parameters$access_token$location
#> [1] "query"
#> 
#> $parameters$access_token$type
#> [1] "string"
#> 
#> 
#> $parameters$upload_protocol
#> $parameters$upload_protocol$location
#> [1] "query"
#> 
#> $parameters$upload_protocol$type
#> [1] "string"
#> 
#> $parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> 
#> $parameters$quotaUser
#> $parameters$quotaUser$description
#> [1] "Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters."
#> 
#> $parameters$quotaUser$location
#> [1] "query"
#> 
#> $parameters$quotaUser$type
#> [1] "string"
#> 
#> 
#> $parameters$`$.xgafv`
#> $parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> $parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> 
#> $parameters$key
#> $parameters$key$type
#> [1] "string"
#> 
#> $parameters$key$location
#> [1] "query"
#> 
#> $parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> 
#> $parameters$callback
#> $parameters$callback$type
#> [1] "string"
#> 
#> $parameters$callback$location
#> [1] "query"
#> 
#> $parameters$callback$description
#> [1] "JSONP"
#> 
#> 
#> $parameters$alt
#> $parameters$alt$location
#> [1] "query"
#> 
#> $parameters$alt$description
#> [1] "Data format for response."
#> 
#> $parameters$alt$default
#> [1] "json"
#> 
#> $parameters$alt$enum
#> [1] "json"  "media" "proto"
#> 
#> $parameters$alt$type
#> [1] "string"
#> 
#> $parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> 
#> $parameters$oauth_token
#> $parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> $parameters$oauth_token$location
#> [1] "query"
#> 
#> $parameters$oauth_token$type
#> [1] "string"
#> 
#> 
#> $parameters$fields
#> $parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $parameters$fields$location
#> [1] "query"
#> 
#> $parameters$fields$type
#> [1] "string"
#> 
#> 
#> $parameters$uploadType
#> $parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $parameters$uploadType$location
#> [1] "query"
#> 
#> $parameters$uploadType$type
#> [1] "string"
#> 
#> 
#> $parameters$prettyPrint
#> $parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $parameters$prettyPrint$default
#> [1] "true"
#> 
#> $parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $parameters$prettyPrint$location
#> [1] "query"
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
#> [1] "drive.comments.get"
#> 
#> $httpMethod
#> [1] "GET"
#> 
#> $path
#> drive/v3/files/{fileId}/comments/{commentId}
#> 
#> $parameters
#> $parameters$fileId
#> $parameters$fileId$required
#> [1] TRUE
#> 
#> $parameters$fileId$location
#> [1] "path"
#> 
#> $parameters$fileId$type
#> [1] "string"
#> 
#> $parameters$fileId$description
#> [1] "The ID of the file."
#> 
#> 
#> $parameters$commentId
#> $parameters$commentId$location
#> [1] "path"
#> 
#> $parameters$commentId$type
#> [1] "string"
#> 
#> $parameters$commentId$description
#> [1] "The ID of the comment."
#> 
#> $parameters$commentId$required
#> [1] TRUE
#> 
#> 
#> $parameters$includeDeleted
#> $parameters$includeDeleted$location
#> [1] "query"
#> 
#> $parameters$includeDeleted$description
#> [1] "Whether to return deleted comments. Deleted comments will not include their original content."
#> 
#> $parameters$includeDeleted$default
#> [1] "false"
#> 
#> $parameters$includeDeleted$type
#> [1] "boolean"
#> 
#> 
#> $parameters$access_token
#> $parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $parameters$access_token$location
#> [1] "query"
#> 
#> $parameters$access_token$type
#> [1] "string"
#> 
#> 
#> $parameters$upload_protocol
#> $parameters$upload_protocol$location
#> [1] "query"
#> 
#> $parameters$upload_protocol$type
#> [1] "string"
#> 
#> $parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> 
#> $parameters$quotaUser
#> $parameters$quotaUser$description
#> [1] "Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters."
#> 
#> $parameters$quotaUser$location
#> [1] "query"
#> 
#> $parameters$quotaUser$type
#> [1] "string"
#> 
#> 
#> $parameters$`$.xgafv`
#> $parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> $parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> 
#> $parameters$key
#> $parameters$key$type
#> [1] "string"
#> 
#> $parameters$key$location
#> [1] "query"
#> 
#> $parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> 
#> $parameters$callback
#> $parameters$callback$type
#> [1] "string"
#> 
#> $parameters$callback$location
#> [1] "query"
#> 
#> $parameters$callback$description
#> [1] "JSONP"
#> 
#> 
#> $parameters$alt
#> $parameters$alt$location
#> [1] "query"
#> 
#> $parameters$alt$description
#> [1] "Data format for response."
#> 
#> $parameters$alt$default
#> [1] "json"
#> 
#> $parameters$alt$enum
#> [1] "json"  "media" "proto"
#> 
#> $parameters$alt$type
#> [1] "string"
#> 
#> $parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> 
#> $parameters$oauth_token
#> $parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> $parameters$oauth_token$location
#> [1] "query"
#> 
#> $parameters$oauth_token$type
#> [1] "string"
#> 
#> 
#> $parameters$fields
#> $parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $parameters$fields$location
#> [1] "query"
#> 
#> $parameters$fields$type
#> [1] "string"
#> 
#> 
#> $parameters$uploadType
#> $parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $parameters$uploadType$location
#> [1] "query"
#> 
#> $parameters$uploadType$type
#> [1] "string"
#> 
#> 
#> $parameters$prettyPrint
#> $parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $parameters$prettyPrint$default
#> [1] "true"
#> 
#> $parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $parameters$prettyPrint$location
#> [1] "query"
#> 
#> 
#> 
#> $scopes
#> [1] "drive, drive.file, drive.meet.readonly, drive.readonly"
#> 
#> $description
#> [1] "Gets a comment by ID. For more information, see [Manage comments and replies](https://developers.google.com/workspace/drive/api/guides/manage-comments). Required: The `fields` parameter must be set. To return the exact fields you need, see [Return specific fields](https://developers.google.com/workspace/drive/api/guides/fields-parameter)."
#> 
#> $response
#> [1] "Comment"
#> 
#> $parameterOrder
#> [1] "fileId"    "commentId"
#> 
```
