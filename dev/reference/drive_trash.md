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
#> • chicken-trash.txt <id: 1LGjqFi6eOWRohbZje82jEmXRIF6XCsMQ>
drive_trash("chicken-trash.txt")
#> File trashed:
#> • chicken-trash.txt <id: 1LGjqFi6eOWRohbZje82jEmXRIF6XCsMQ>

# Confirm it's in the trash
drive_find(trashed = TRUE)
#> # A dribble: 113 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 chicken-trash.txt    1LGjqFi… <named list [45]>
#>  2 name-squatter-rename 1ZY7fDa… <named list [42]>
#>  3 name-squatter-mv     1mp_JqS… <named list [42]>
#>  4 name-squatter-upload 1a3nKiW… <named list [42]>
#>  5 name-squatter-rename 1m2Q4Rc… <named list [42]>
#>  6 name-squatter-mv     1jAMdns… <named list [42]>
#>  7 name-squatter-upload 17WoJPy… <named list [42]>
#>  8 name-squatter-rename 1QvSeOb… <named list [42]>
#>  9 name-squatter-mv     1oDIXLR… <named list [42]>
#> 10 name-squatter-upload 1nXVz0S… <named list [42]>
#> # ℹ 103 more rows

# Remove it from the trash and confirm
drive_untrash("chicken-trash.txt")
#> File untrashed:
#> • chicken-trash.txt <id: 1LGjqFi6eOWRohbZje82jEmXRIF6XCsMQ>
drive_find(trashed = TRUE)
#> # A dribble: 112 × 3
#>    name                 id       drive_resource   
#>    <chr>                <drv_id> <list>           
#>  1 name-squatter-rename 1ZY7fDa… <named list [42]>
#>  2 name-squatter-mv     1mp_JqS… <named list [42]>
#>  3 name-squatter-upload 1a3nKiW… <named list [42]>
#>  4 name-squatter-rename 1m2Q4Rc… <named list [42]>
#>  5 name-squatter-mv     1jAMdns… <named list [42]>
#>  6 name-squatter-upload 17WoJPy… <named list [42]>
#>  7 name-squatter-rename 1QvSeOb… <named list [42]>
#>  8 name-squatter-mv     1oDIXLR… <named list [42]>
#>  9 name-squatter-upload 1nXVz0S… <named list [42]>
#> 10 name-squatter-rename 1XAT0Wo… <named list [42]>
#> # ℹ 102 more rows

# Clean up
drive_rm("chicken-trash.txt")
#> File deleted:
#> • chicken-trash.txt <id: 1LGjqFi6eOWRohbZje82jEmXRIF6XCsMQ>
```
