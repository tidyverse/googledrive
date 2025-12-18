# Move Drive files to or from trash

Move Drive files to or from trash

## Usage

``` r
drive_trash(file, verbose = deprecated())

drive_untrash(file, verbose = deprecated())
```

## Arguments

- file:

  Something that identifies the file(s) of interest on your Google
  Drive. Can be a character vector of names/paths, a character vector of
  file ids or URLs marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

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
a tibble with one row per file.

## Examples

``` r
# Create a file and put it in the trash.
file <- drive_example_remote("chicken.txt") |>
  drive_cp("chicken-trash.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-trash.txt <id: 1OCymn8PMx1zIBU_MOY0SJDAHdQ6yXfbl>
drive_trash("chicken-trash.txt")
#> File trashed:
#> • chicken-trash.txt <id: 1OCymn8PMx1zIBU_MOY0SJDAHdQ6yXfbl>

# Confirm it's in the trash
drive_find(trashed = TRUE)
#> # A dribble: 90 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 chicken-trash.txt    1OCymn8… <named list [44]>
#>  2 name-squatter-rename 1qE94_S… <named list [41]>
#>  3 name-squatter-mv     13Ml4hk… <named list [41]>
#>  4 name-squatter-upload 1HE9Akx… <named list [41]>
#>  5 name-squatter-rename 1VBOUdl… <named list [41]>
#>  6 name-squatter-mv     1cjkrM4… <named list [41]>
#>  7 name-squatter-upload 19fXTbH… <named list [41]>
#>  8 name-squatter-rename 1pZXeo3… <named list [41]>
#>  9 name-squatter-mv     138c8X1… <named list [41]>
#> 10 name-squatter-upload 1tteVJU… <named list [41]>
#> # ℹ 80 more rows

# Remove it from the trash and confirm
drive_untrash("chicken-trash.txt")
#> File untrashed:
#> • chicken-trash.txt <id: 1OCymn8PMx1zIBU_MOY0SJDAHdQ6yXfbl>
drive_find(trashed = TRUE)
#> # A dribble: 89 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 name-squatter-rename 1qE94_S… <named list [41]>
#>  2 name-squatter-mv     13Ml4hk… <named list [41]>
#>  3 name-squatter-upload 1HE9Akx… <named list [41]>
#>  4 name-squatter-rename 1VBOUdl… <named list [41]>
#>  5 name-squatter-mv     1cjkrM4… <named list [41]>
#>  6 name-squatter-upload 19fXTbH… <named list [41]>
#>  7 name-squatter-rename 1pZXeo3… <named list [41]>
#>  8 name-squatter-mv     138c8X1… <named list [41]>
#>  9 name-squatter-upload 1tteVJU… <named list [41]>
#> 10 name-squatter-rename 1ezOnue… <named list [41]>
#> # ℹ 79 more rows

# Clean up
drive_rm("chicken-trash.txt")
#> File deleted:
#> • chicken-trash.txt <id: 1OCymn8PMx1zIBU_MOY0SJDAHdQ6yXfbl>
```
