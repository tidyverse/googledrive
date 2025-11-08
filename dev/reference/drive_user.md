# Get info on current user

Reveals information about the user associated with the current token.
This is a thin wrapper around
[`drive_about()`](https://googledrive.tidyverse.org/dev/reference/drive_about.md)
that just extracts the most useful information (the information on
current user) and prints it nicely.

## Usage

``` r
drive_user(verbose = deprecated())
```

## Arguments

- verbose:

  **\[deprecated\]** This logical argument to individual googledrive
  functions is deprecated. To globally suppress googledrive messaging,
  use `options(googledrive_quiet = TRUE)` (the default behaviour is to
  emit informational messages). To suppress messaging in a more limited
  way, use the helpers
  [`local_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md)
  or
  [`with_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md).

## Value

A list of class `drive_user`.

## See also

Wraps the `about.get` endpoint:

- <https://developers.google.com/drive/api/v3/reference/about/get>

## Examples

``` r
drive_user()
#> Logged in as:
#> • displayName: googledrive-docs@gargle-169921.iam.gserviceaccount.com
#> • emailAddress: googledrive-docs@gargle-169921.iam.gserviceaccount.com

# more info is returned than is printed
user <- drive_user()
str(user)
#> List of 6
#>  $ kind        : chr "drive#user"
#>  $ displayName : chr "googledrive-docs@gargle-169921.iam.gserviceaccount.com"
#>  $ photoLink   : chr "https://lh3.googleusercontent.com/a/ACg8ocIG4HCyGaPbQ53NSBY6jFcH8mA_4VFotnEVUPuC5yFoGqwE8Q=s64"
#>  $ me          : logi TRUE
#>  $ permissionId: chr "09204227840243713330"
#>  $ emailAddress: chr "googledrive-docs@gargle-169921.iam.gserviceaccount.com"
#>  - attr(*, "class")= chr [1:2] "drive_user" "list"
```
