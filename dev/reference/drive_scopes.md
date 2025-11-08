# Produce scopes specific to the Drive API

When called with no arguments, `drive_scopes()` returns a named
character vector of scopes associated with the Drive API. If
`drive_scopes(scopes =)` is given, an abbreviated entry such as
`"drive.readonly"` is expanded to a full scope
(`"https://www.googleapis.com/auth/drive.readonly"` in this case).
Unrecognized scopes are passed through unchanged.

## Usage

``` r
drive_scopes(scopes = NULL)
```

## Arguments

- scopes:

  One or more API scopes. Each scope can be specified in full or, for
  Drive API-specific scopes, in an abbreviated form that is recognized
  by `drive_scopes()`:

  - "drive" = "https://www.googleapis.com/auth/drive" (the default)

  - "full" = "https://www.googleapis.com/auth/drive" (same as "drive")

  - "drive.readonly" = "https://www.googleapis.com/auth/drive.readonly"

  - "drive.file" = "https://www.googleapis.com/auth/drive.file"

  - "drive.appdata" = "https://www.googleapis.com/auth/drive.appdata"

  - "drive.metadata" = "https://www.googleapis.com/auth/drive.metadata"

  - "drive.metadata.readonly" =
    "https://www.googleapis.com/auth/drive.metadata.readonly"

  - "drive.photos.readonly" =
    "https://www.googleapis.com/auth/drive.photos.readonly"

  - "drive.scripts" = "https://www.googleapis.com/auth/drive.scripts

  See <https://developers.google.com/drive/api/guides/api-specific-auth>
  for details on the permissions for each scope.

## Value

A character vector of scopes.

## See also

<https://developers.google.com/drive/api/guides/api-specific-auth> for
details on the permissions for each scope.

Other auth functions:
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md),
[`drive_auth_configure()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md),
[`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md)

## Examples

``` r
drive_scopes("full")
#> [1] "https://www.googleapis.com/auth/drive"
drive_scopes("drive.readonly")
#> [1] "https://www.googleapis.com/auth/drive.readonly"
drive_scopes()
#>                                                     drive 
#>                   "https://www.googleapis.com/auth/drive" 
#>                                                      full 
#>                   "https://www.googleapis.com/auth/drive" 
#>                                            drive.readonly 
#>          "https://www.googleapis.com/auth/drive.readonly" 
#>                                                drive.file 
#>              "https://www.googleapis.com/auth/drive.file" 
#>                                             drive.appdata 
#>           "https://www.googleapis.com/auth/drive.appdata" 
#>                                            drive.metadata 
#>          "https://www.googleapis.com/auth/drive.metadata" 
#>                                   drive.metadata.readonly 
#> "https://www.googleapis.com/auth/drive.metadata.readonly" 
#>                                     drive.photos.readonly 
#>   "https://www.googleapis.com/auth/drive.photos.readonly" 
#>                                             drive.scripts 
#>           "https://www.googleapis.com/auth/drive.scripts" 
```
