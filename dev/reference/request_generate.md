# Build a request for the Google Drive API

Build a request, using knowledge of the [Drive v3
API](https://developers.google.com/drive/api/v3/about-sdk) from its
Discovery Document
(`https://www.googleapis.com/discovery/v1/apis/drive/v3/rest`). Most
users should, instead, use higher-level wrappers that facilitate common
tasks, such as uploading or downloading Drive files. The functions here
are intended for internal use and for programming around the Drive API.

`request_generate()` lets you provide the bare minimum of input. It
takes a nickname for an endpoint and:

- Uses the API spec to look up the `path`, `method`, and base URL.

- Checks `params` for validity and completeness with respect to the
  endpoint. Separates parameters into those destined for the body, the
  query, and URL endpoint substitution (which is also enacted).

- Adds an API key to the query if and only if `token = NULL`.

- Adds `supportsAllDrives = TRUE` to the query if the endpoint requires.

## Usage

``` r
request_generate(
  endpoint = character(),
  params = list(),
  key = NULL,
  token = drive_token()
)
```

## Arguments

- endpoint:

  Character. Nickname for one of the selected Drive v3 API endpoints
  built into googledrive. Learn more in
  [`drive_endpoints()`](https://googledrive.tidyverse.org/dev/reference/drive_endpoints.md).

- params:

  Named list. Parameters destined for endpoint URL substitution, the
  query, or the body.

- key:

  API key. Needed for requests that don't contain a token. The need for
  an API key in the absence of a token is explained in Google's document
  "Credentials, access, security, and identity"
  (`https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279`).
  In order of precedence, these sources are consulted: the formal `key`
  argument, a `key` parameter in `params`, a user-configured API key
  fetched via
  [`drive_api_key()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md),
  a built-in key shipped with googledrive. See
  [`drive_auth_configure()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md)
  for details on a user-configured key.

- token:

  Drive token. Set to `NULL` to suppress the inclusion of a token. Note
  that, if auth has been de-activated via
  [`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md),
  [`drive_token()`](https://googledrive.tidyverse.org/dev/reference/drive_token.md)
  will actually return `NULL`.

## Value

[`list()`](https://rdrr.io/r/base/list.html)  
Components are `method`, `path`, `query`, `body`, `token`, and `url`,
suitable as input for
[`request_make()`](https://googledrive.tidyverse.org/dev/reference/request_make.md).

## See also

[`gargle::request_develop()`](https://gargle.r-lib.org/reference/request_develop.html),
[`gargle::request_build()`](https://gargle.r-lib.org/reference/request_develop.html)

Other low-level API functions:
[`drive_has_token()`](https://googledrive.tidyverse.org/dev/reference/drive_has_token.md),
[`drive_token()`](https://googledrive.tidyverse.org/dev/reference/drive_token.md),
[`request_make()`](https://googledrive.tidyverse.org/dev/reference/request_make.md)

## Examples

``` r
req <- request_generate(
  "drive.files.get",
  list(fileId = "abc"),
  token = drive_token()
)
req
#> $method
#> [1] "GET"
#> 
#> $url
#> [1] "https://www.googleapis.com/drive/v3/files/abc?supportsAllDrives=TRUE"
#> 
#> $body
#> named list()
#> 
#> $token
#> <request>
#> Auth token: TokenServiceAccount
#> 
```
