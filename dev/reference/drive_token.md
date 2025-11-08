# Produce configured token

For internal use or for those programming around the Drive API. Returns
a token pre-processed with
[`httr::config()`](https://httr.r-lib.org/reference/config.html). Most
users do not need to handle tokens "by hand" or, even if they need some
control,
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md)
is what they need. If there is no current token,
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md)
is called to either load from cache or initiate OAuth2.0 flow. If auth
has been deactivated via
[`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md),
`drive_token()` returns `NULL`.

## Usage

``` r
drive_token()
```

## Value

A `request` object (an S3 class provided by
[httr](https://httr.r-lib.org/reference/httr-package.html)).

## See also

Other low-level API functions:
[`drive_has_token()`](https://googledrive.tidyverse.org/dev/reference/drive_has_token.md),
[`request_generate()`](https://googledrive.tidyverse.org/dev/reference/request_generate.md),
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
