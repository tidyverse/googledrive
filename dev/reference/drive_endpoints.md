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
#>  $ drive.operations.get:List of 8
#>   ..$ id            : chr "drive.operations.get"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "drive/v3/operations/{name}"
#>   ..$ parameters    :List of 12
#>   ..$ scopes        : chr "drive, drive.file, drive.meet.readonly, drive.readonly"
#>   ..$ description   : chr "Gets the latest state of a long-running operation. Clients can use this method to poll the operation result at "| __truncated__
#>   ..$ response      : chr "Operation"
#>   ..$ parameterOrder: chr "name"
#>  $ drive.about.get     :List of 8
#>   ..$ id            : chr "drive.about.get"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "drive/v3/about"
#>   ..$ parameters    :List of 11
#>   ..$ scopes        : chr "drive, drive.appdata, drive.file, drive.metadata, drive.metadata.readonly, drive.photos.readonly, drive.readonly"
#>   ..$ description   : chr "Gets information about the user, the user's Drive, and system capabilities. For more information, see [Return u"| __truncated__
#>   ..$ response      : chr "About"
#>   ..$ parameterOrder: list()
#>  $ drive.apps.get      :List of 8
#>   ..$ id            : chr "drive.apps.get"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "drive/v3/apps/{appId}"
#>   ..$ parameters    :List of 12
#>   ..$ scopes        : chr "drive, drive.appdata, drive.apps.readonly, drive.file, drive.metadata, drive.metadata.readonly, drive.readonly"
#>   ..$ description   : chr "Gets a specific app. For more information, see [Return user info](https://developers.google.com/workspace/drive"| __truncated__
#>   ..$ response      : chr "App"
#>   ..$ parameterOrder: chr "appId"
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
#> $parameters$fileId
#> $parameters$fileId$description
#> [1] "The ID of the file."
#> 
#> $parameters$fileId$location
#> [1] "path"
#> 
#> $parameters$fileId$required
#> [1] TRUE
#> 
#> $parameters$fileId$type
#> [1] "string"
#> 
#> 
#> $parameters$supportsAllDrives
#> $parameters$supportsAllDrives$description
#> [1] "Whether the requesting application supports both My Drives and shared drives."
#> 
#> $parameters$supportsAllDrives$default
#> [1] "false"
#> 
#> $parameters$supportsAllDrives$location
#> [1] "query"
#> 
#> $parameters$supportsAllDrives$type
#> [1] "boolean"
#> 
#> 
#> $parameters$supportsTeamDrives
#> $parameters$supportsTeamDrives$description
#> [1] "Deprecated: Use `supportsAllDrives` instead."
#> 
#> $parameters$supportsTeamDrives$default
#> [1] "false"
#> 
#> $parameters$supportsTeamDrives$location
#> [1] "query"
#> 
#> $parameters$supportsTeamDrives$deprecated
#> [1] TRUE
#> 
#> $parameters$supportsTeamDrives$type
#> [1] "boolean"
#> 
#> 
#> $parameters$enforceSingleParent
#> $parameters$enforceSingleParent$description
#> [1] "Deprecated: If an item isn't in a shared drive and its last parent is deleted but the item itself isn't, the item will be placed under its owner's root."
#> 
#> $parameters$enforceSingleParent$default
#> [1] "false"
#> 
#> $parameters$enforceSingleParent$location
#> [1] "query"
#> 
#> $parameters$enforceSingleParent$deprecated
#> [1] TRUE
#> 
#> $parameters$enforceSingleParent$type
#> [1] "boolean"
#> 
#> 
#> $parameters$access_token
#> $parameters$access_token$type
#> [1] "string"
#> 
#> $parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $parameters$access_token$location
#> [1] "query"
#> 
#> 
#> $parameters$alt
#> $parameters$alt$type
#> [1] "string"
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
#> $parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> $parameters$alt$location
#> [1] "query"
#> 
#> 
#> $parameters$callback
#> $parameters$callback$type
#> [1] "string"
#> 
#> $parameters$callback$description
#> [1] "JSONP"
#> 
#> $parameters$callback$location
#> [1] "query"
#> 
#> 
#> $parameters$fields
#> $parameters$fields$type
#> [1] "string"
#> 
#> $parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $parameters$fields$location
#> [1] "query"
#> 
#> 
#> $parameters$key
#> $parameters$key$type
#> [1] "string"
#> 
#> $parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> $parameters$key$location
#> [1] "query"
#> 
#> 
#> $parameters$oauth_token
#> $parameters$oauth_token$type
#> [1] "string"
#> 
#> $parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> $parameters$oauth_token$location
#> [1] "query"
#> 
#> 
#> $parameters$prettyPrint
#> $parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $parameters$prettyPrint$default
#> [1] "true"
#> 
#> $parameters$prettyPrint$location
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
#> $parameters$upload_protocol
#> $parameters$upload_protocol$type
#> [1] "string"
#> 
#> $parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> $parameters$upload_protocol$location
#> [1] "query"
#> 
#> 
#> $parameters$uploadType
#> $parameters$uploadType$type
#> [1] "string"
#> 
#> $parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $parameters$uploadType$location
#> [1] "query"
#> 
#> 
#> $parameters$`$.xgafv`
#> $parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> $parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $parameters$`$.xgafv`$location
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
#> [1] "drive.apps.list"
#> 
#> $httpMethod
#> [1] "GET"
#> 
#> $path
#> drive/v3/apps
#> 
#> $parameters
#> $parameters$appFilterExtensions
#> $parameters$appFilterExtensions$description
#> [1] "A comma-separated list of file extensions to limit returned results. All results within the given app query scope which can open any of the given file extensions are included in the response. If `appFilterMimeTypes` are provided as well, the result is a union of the two resulting app lists."
#> 
#> $parameters$appFilterExtensions$default
#> [1] ""
#> 
#> $parameters$appFilterExtensions$location
#> [1] "query"
#> 
#> $parameters$appFilterExtensions$type
#> [1] "string"
#> 
#> 
#> $parameters$appFilterMimeTypes
#> $parameters$appFilterMimeTypes$description
#> [1] "A comma-separated list of file extensions to limit returned results. All results within the given app query scope which can open any of the given MIME types will be included in the response. If `appFilterExtensions` are provided as well, the result is a union of the two resulting app lists."
#> 
#> $parameters$appFilterMimeTypes$default
#> [1] ""
#> 
#> $parameters$appFilterMimeTypes$location
#> [1] "query"
#> 
#> $parameters$appFilterMimeTypes$type
#> [1] "string"
#> 
#> 
#> $parameters$languageCode
#> $parameters$languageCode$description
#> [1] "A language or locale code, as defined by BCP 47, with some extensions from Unicode's LDML format (http://www.unicode.org/reports/tr35/)."
#> 
#> $parameters$languageCode$location
#> [1] "query"
#> 
#> $parameters$languageCode$type
#> [1] "string"
#> 
#> 
#> $parameters$access_token
#> $parameters$access_token$type
#> [1] "string"
#> 
#> $parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $parameters$access_token$location
#> [1] "query"
#> 
#> 
#> $parameters$alt
#> $parameters$alt$type
#> [1] "string"
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
#> $parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> $parameters$alt$location
#> [1] "query"
#> 
#> 
#> $parameters$callback
#> $parameters$callback$type
#> [1] "string"
#> 
#> $parameters$callback$description
#> [1] "JSONP"
#> 
#> $parameters$callback$location
#> [1] "query"
#> 
#> 
#> $parameters$fields
#> $parameters$fields$type
#> [1] "string"
#> 
#> $parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $parameters$fields$location
#> [1] "query"
#> 
#> 
#> $parameters$key
#> $parameters$key$type
#> [1] "string"
#> 
#> $parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> $parameters$key$location
#> [1] "query"
#> 
#> 
#> $parameters$oauth_token
#> $parameters$oauth_token$type
#> [1] "string"
#> 
#> $parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> $parameters$oauth_token$location
#> [1] "query"
#> 
#> 
#> $parameters$prettyPrint
#> $parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $parameters$prettyPrint$default
#> [1] "true"
#> 
#> $parameters$prettyPrint$location
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
#> $parameters$upload_protocol
#> $parameters$upload_protocol$type
#> [1] "string"
#> 
#> $parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> $parameters$upload_protocol$location
#> [1] "query"
#> 
#> 
#> $parameters$uploadType
#> $parameters$uploadType$type
#> [1] "string"
#> 
#> $parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $parameters$uploadType$location
#> [1] "query"
#> 
#> 
#> $parameters$`$.xgafv`
#> $parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> $parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> 
#> 
#> $scopes
#> [1] "drive.apps.readonly"
#> 
#> $description
#> [1] "Lists a user's installed apps. For more information, see [Return user info](https://developers.google.com/workspace/drive/api/guides/user-info)."
#> 
#> $response
#> [1] "AppList"
#> 
#> $parameterOrder
#> list()
#> 
```
