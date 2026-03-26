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
#> • chicken-trash.txt <id: 1KJKf3dDrGABcH2BbZBjWqFffHKtzKU7b>
drive_trash("chicken-trash.txt")
#> File trashed:
#> • chicken-trash.txt <id: 1KJKf3dDrGABcH2BbZBjWqFffHKtzKU7b>

# Confirm it's in the trash
drive_find(trashed = TRUE)
#> # A dribble: 91 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 chicken-trash.txt    1KJKf3d… <named list [43]>
#>  2 name-squatter-rename 1w3FGFM… <named list [41]>
#>  3 name-squatter-mv     1mc0ttA… <named list [41]>
#>  4 name-squatter-upload 1ji94Kb… <named list [41]>
#>  5 name-squatter-rename 1pyb6HZ… <named list [41]>
#>  6 name-squatter-mv     1KOQW5s… <named list [41]>
#>  7 name-squatter-upload 1kPkPJo… <named list [41]>
#>  8 name-squatter-rename 1NTJSv7… <named list [41]>
#>  9 name-squatter-mv     10AY2eX… <named list [41]>
#> 10 name-squatter-upload 1u1zV36… <named list [41]>
#> # ℹ 81 more rows

# Remove it from the trash and confirm
drive_untrash("chicken-trash.txt")
#> File untrashed:
#> • chicken-trash.txt <id: 1KJKf3dDrGABcH2BbZBjWqFffHKtzKU7b>
drive_find(trashed = TRUE)
#> # A dribble: 90 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 name-squatter-rename 1w3FGFM… <named list [41]>
#>  2 name-squatter-mv     1mc0ttA… <named list [41]>
#>  3 name-squatter-upload 1ji94Kb… <named list [41]>
#>  4 name-squatter-rename 1pyb6HZ… <named list [41]>
#>  5 name-squatter-mv     1KOQW5s… <named list [41]>
#>  6 name-squatter-upload 1kPkPJo… <named list [41]>
#>  7 name-squatter-rename 1NTJSv7… <named list [41]>
#>  8 name-squatter-mv     10AY2eX… <named list [41]>
#>  9 name-squatter-upload 1u1zV36… <named list [41]>
#> 10 name-squatter-rename 1XLBeKi… <named list [41]>
#> # ℹ 80 more rows

# Clean up
drive_rm("chicken-trash.txt")
#> File deleted:
#> • chicken-trash.txt <id: 1KJKf3dDrGABcH2BbZBjWqFffHKtzKU7b>
```
