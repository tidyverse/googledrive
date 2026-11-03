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
#> • chicken-trash.txt <id: 1v5EGPniHjPuYtdaXUgxfSjYOiVp9CwRH>
drive_trash("chicken-trash.txt")
#> File trashed:
#> • chicken-trash.txt <id: 1v5EGPniHjPuYtdaXUgxfSjYOiVp9CwRH>

# Confirm it's in the trash
drive_find(trashed = TRUE)
#> # A dribble: 116 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 chicken-trash.txt    1v5EGPn… <named list [44]>
#>  2 name-squatter-rename 1M-Kqmj… <named list [42]>
#>  3 name-squatter-mv     1Fwqx6w… <named list [42]>
#>  4 name-squatter-upload 1nje_6Y… <named list [42]>
#>  5 name-squatter-rename 1zPuhKq… <named list [42]>
#>  6 name-squatter-mv     1li7nMg… <named list [42]>
#>  7 name-squatter-upload 1SzOU5i… <named list [42]>
#>  8 name-squatter-rename 1Tbi97H… <named list [42]>
#>  9 name-squatter-mv     17_kYyz… <named list [42]>
#> 10 name-squatter-upload 1vQVL-R… <named list [42]>
#> # ℹ 106 more rows

# Remove it from the trash and confirm
drive_untrash("chicken-trash.txt")
#> File untrashed:
#> • chicken-trash.txt <id: 1v5EGPniHjPuYtdaXUgxfSjYOiVp9CwRH>
drive_find(trashed = TRUE)
#> # A dribble: 115 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 name-squatter-rename 1M-Kqmj… <named list [42]>
#>  2 name-squatter-mv     1Fwqx6w… <named list [42]>
#>  3 name-squatter-upload 1nje_6Y… <named list [42]>
#>  4 name-squatter-rename 1zPuhKq… <named list [42]>
#>  5 name-squatter-mv     1li7nMg… <named list [42]>
#>  6 name-squatter-upload 1SzOU5i… <named list [42]>
#>  7 name-squatter-rename 1Tbi97H… <named list [42]>
#>  8 name-squatter-mv     17_kYyz… <named list [42]>
#>  9 name-squatter-upload 1vQVL-R… <named list [42]>
#> 10 name-squatter-rename 1D3VvYt… <named list [42]>
#> # ℹ 105 more rows

# Clean up
drive_rm("chicken-trash.txt")
#> File deleted:
#> • chicken-trash.txt <id: 1v5EGPniHjPuYtdaXUgxfSjYOiVp9CwRH>
```
