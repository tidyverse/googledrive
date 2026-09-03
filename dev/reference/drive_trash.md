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
#> • chicken-trash.txt <id: 1hDClLE_6gyGZxj2npt4DwgLahr97uP5L>
drive_trash("chicken-trash.txt")
#> File trashed:
#> • chicken-trash.txt <id: 1hDClLE_6gyGZxj2npt4DwgLahr97uP5L>

# Confirm it's in the trash
drive_find(trashed = TRUE)
#> # A dribble: 135 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 chicken-trash.txt    1hDClLE… <named list [45]>
#>  2 name-squatter-rename 1gwynvr… <named list [42]>
#>  3 name-squatter-mv     1crQObi… <named list [42]>
#>  4 name-squatter-upload 1ObM5fZ… <named list [42]>
#>  5 name-squatter-rename 1sHffwS… <named list [42]>
#>  6 name-squatter-mv     1F2nPHD… <named list [42]>
#>  7 name-squatter-upload 1x6M3Di… <named list [42]>
#>  8 name-squatter-rename 1zhp0GF… <named list [42]>
#>  9 name-squatter-mv     1el5Kjc… <named list [42]>
#> 10 name-squatter-upload 1xzRvke… <named list [42]>
#> # ℹ 125 more rows

# Remove it from the trash and confirm
drive_untrash("chicken-trash.txt")
#> File untrashed:
#> • chicken-trash.txt <id: 1hDClLE_6gyGZxj2npt4DwgLahr97uP5L>
drive_find(trashed = TRUE)
#> # A dribble: 134 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 name-squatter-rename 1gwynvr… <named list [42]>
#>  2 name-squatter-mv     1crQObi… <named list [42]>
#>  3 name-squatter-upload 1ObM5fZ… <named list [42]>
#>  4 name-squatter-rename 1sHffwS… <named list [42]>
#>  5 name-squatter-mv     1F2nPHD… <named list [42]>
#>  6 name-squatter-upload 1x6M3Di… <named list [42]>
#>  7 name-squatter-rename 1zhp0GF… <named list [42]>
#>  8 name-squatter-mv     1el5Kjc… <named list [42]>
#>  9 name-squatter-upload 1xzRvke… <named list [42]>
#> 10 name-squatter-rename 1zXtHXo… <named list [42]>
#> # ℹ 124 more rows

# Clean up
drive_rm("chicken-trash.txt")
#> File deleted:
#> • chicken-trash.txt <id: 1hDClLE_6gyGZxj2npt4DwgLahr97uP5L>
```
