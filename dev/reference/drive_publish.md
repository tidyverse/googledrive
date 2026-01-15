# Publish native Google files

Publish (or un-publish) native Google files to the web. Native Google
files include Google Docs, Google Sheets, and Google Slides. The
returned
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
will have extra columns, `published` and `revisions_resource`. Read more
in
[`drive_reveal()`](https://googledrive.tidyverse.org/dev/reference/drive_reveal.md).

## Usage

``` r
drive_publish(file, ..., verbose = deprecated())

drive_unpublish(file, ..., verbose = deprecated())
```

## Arguments

- file:

  Something that identifies the file(s) of interest on your Google
  Drive. Can be a character vector of names/paths, a character vector of
  file ids or URLs marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- ...:

  Name-value pairs to add to the API request body (see API docs linked
  below for details). For `drive_publish()`, we include
  `publishAuto = TRUE` and `publishedOutsideDomain = TRUE`, if user does
  not specify other values.

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

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per file. There will be extra columns, `published`
and `revisions_resource`.

## See also

Wraps the `revisions.update` endpoint:

- <https://developers.google.com/drive/api/v3/reference/revisions/update>

## Examples

``` r
# Create a file to publish
file <- drive_example_remote("chicken_sheet") |>
  drive_cp()
#> Original file:
#> • chicken_sheet <id: 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU>
#> Copied to file:
#> • Copy of chicken_sheet
#>   <id: 14T2cOu1csf2zkqsRUpHptWoocvNWUPPyUd7zXOKF7x0>

# Publish file
file <- drive_publish(file)
#> File now published:
#> • Copy of chicken_sheet
#>   <id: 14T2cOu1csf2zkqsRUpHptWoocvNWUPPyUd7zXOKF7x0>
file$published
#> [1] TRUE

# Unpublish file
file <- drive_unpublish(file)
#> File now NOT published:
#> • Copy of chicken_sheet
#>   <id: 14T2cOu1csf2zkqsRUpHptWoocvNWUPPyUd7zXOKF7x0>
file$published
#> [1] FALSE

# Clean up
drive_rm(file)
#> File deleted:
#> • Copy of chicken_sheet
#>   <id: 14T2cOu1csf2zkqsRUpHptWoocvNWUPPyUd7zXOKF7x0>
```
