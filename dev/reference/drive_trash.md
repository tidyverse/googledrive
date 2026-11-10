# Move Drive files to or from trash

Move Drive files to or from trash

## Usage

``` r
drive_trash(file)

drive_untrash(file)
```

## Arguments

- file:

  Something that identifies the file(s) of interest on your Google
  Drive. Can be a character vector of names/paths, a character vector of
  file ids or URLs marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

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
#> • chicken-trash.txt <id: 1T25kYIWfQF2tXGxIKEy874Qk2fDEueQK>
drive_trash("chicken-trash.txt")
#> File trashed:
#> • chicken-trash.txt <id: 1T25kYIWfQF2tXGxIKEy874Qk2fDEueQK>

# Confirm it's in the trash
drive_find(trashed = TRUE)
#> # A dribble: 116 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 chicken-trash.txt    1T25kYI… <named list [45]>
#>  2 name-squatter-rename 1ImVHGD… <named list [42]>
#>  3 name-squatter-mv     1Ft6sQF… <named list [42]>
#>  4 name-squatter-upload 11HURgM… <named list [42]>
#>  5 name-squatter-rename 1X9jxxd… <named list [42]>
#>  6 name-squatter-mv     1wiE738… <named list [42]>
#>  7 name-squatter-upload 13aXEfV… <named list [42]>
#>  8 name-squatter-rename 1vnk_Zu… <named list [42]>
#>  9 name-squatter-mv     1njc6xm… <named list [42]>
#> 10 name-squatter-upload 1fA44AH… <named list [42]>
#> # ℹ 106 more rows

# Remove it from the trash and confirm
drive_untrash("chicken-trash.txt")
#> File untrashed:
#> • chicken-trash.txt <id: 1T25kYIWfQF2tXGxIKEy874Qk2fDEueQK>
drive_find(trashed = TRUE)
#> # A dribble: 115 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 name-squatter-rename 1ImVHGD… <named list [42]>
#>  2 name-squatter-mv     1Ft6sQF… <named list [42]>
#>  3 name-squatter-upload 11HURgM… <named list [42]>
#>  4 name-squatter-rename 1X9jxxd… <named list [42]>
#>  5 name-squatter-mv     1wiE738… <named list [42]>
#>  6 name-squatter-upload 13aXEfV… <named list [42]>
#>  7 name-squatter-rename 1vnk_Zu… <named list [42]>
#>  8 name-squatter-mv     1njc6xm… <named list [42]>
#>  9 name-squatter-upload 1fA44AH… <named list [42]>
#> 10 name-squatter-rename 18-kWJ7… <named list [42]>
#> # ℹ 105 more rows

# Clean up
drive_rm("chicken-trash.txt")
#> File deleted:
#> • chicken-trash.txt <id: 1T25kYIWfQF2tXGxIKEy874Qk2fDEueQK>
```
