# Resolve shortcuts to their targets

Retrieves the metadata for the Drive file that a shortcut refers to,
i.e. the shortcut's target. The returned
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
has the usual columns (`name`, `id`, `drive_resource`), which refer to
the target. It will also include the columns `name_shortcut` and
`id_shortcut`, which refer to the original shortcut. There are 3
possible scenarios:

1.  `file` is a shortcut and user can
    [`drive_get()`](https://googledrive.tidyverse.org/dev/reference/drive_get.md)
    the target. All is simple and well.

2.  `file` is a shortcut, but
    [`drive_get()`](https://googledrive.tidyverse.org/dev/reference/drive_get.md)
    fails for the target. This can happen if the user can see the
    shortcut, but does not have read access to the target. It can also
    happen if the target has been trashed or deleted. In such cases, all
    of the target's metadata, except for `id`, will be missing. Call
    [`drive_get()`](https://googledrive.tidyverse.org/dev/reference/drive_get.md)
    on a problematic `id` to see the specific error.

3.  `file` is not a shortcut. `name_shortcut` and `id_shortcut` will
    both be `NA`.

## Usage

``` r
shortcut_resolve(file)
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
a tibble with one row per file. Extra columns `name_shortcut` and
`id_shortcut` refer to the original shortcut.

## Examples

``` r
# Create a file to make a shortcut to
file <- drive_example_remote("chicken_sheet") |>
  drive_cp(name = "chicken-sheet-for-shortcut")
#> Original file:
#> • chicken_sheet <id: 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU>
#> Copied to file:
#> • chicken-sheet-for-shortcut
#>   <id: 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js>

# Create a shortcut
sc1 <- file |>
  shortcut_create(name = "shortcut-1")
#> Created Drive file:
#> • shortcut-1 <id: 1HcLOUpzM2NSIYeDeJEd3iAbsuU52I02m>
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Create a second shortcut by copying the first
sc1 <- sc1 |>
  drive_cp(name = "shortcut-2")
#> Original file:
#> • shortcut-1 <id: 1HcLOUpzM2NSIYeDeJEd3iAbsuU52I02m>
#> Copied to file:
#> • shortcut-2 <id: 1ZF6pZ4JsvJHlvwfEoookr_ytZ-Jca2Xs>

# Get the shortcuts
(sc_dat <- drive_find("-[12]$", type = "shortcut"))
#> # A dribble: 2 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 shortcut-2 1ZF6pZ4JsvJHlvwfEoookr_ytZ-Jca2Xs <named list [34]>
#> 2 shortcut-1 1HcLOUpzM2NSIYeDeJEd3iAbsuU52I02m <named list [34]>

# Resolve them
(resolved <- shortcut_resolve(sc_dat))
#> ℹ Resolved 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1ZF6pZ4JsvJHlvwfEoookr_ytZ-Jca2Xs> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js>
#> • shortcut-1 <id: 1HcLOUpzM2NSIYeDeJEd3iAbsuU52I02m> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js>
#> # A dribble: 2 × 5
#>   name                id       name_shortcut id_shortcut drive_resource
#>   <chr>               <drv_id> <chr>         <drv_id>    <list>        
#> 1 chicken-sheet-for-… 1-NAKoO… shortcut-2    1ZF6pZ4…    <named list>  
#> 2 chicken-sheet-for-… 1-NAKoO… shortcut-1    1HcLOUp…    <named list>  

resolved$id
#> <drive_id[2]>
#> [1] 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js
#> [2] 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js
file$id
#> <drive_id[1]>
#> [1] 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js

# Delete the target file
drive_rm(file)
#> File deleted:
#> • chicken-sheet-for-shortcut
#>   <id: 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js>

# (Try to) resolve the shortcuts again
shortcut_resolve(sc_dat)
#> ℹ Resolved 0 of 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1ZF6pZ4JsvJHlvwfEoookr_ytZ-Jca2Xs> -> NA
#>   <id: 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js>
#> • shortcut-1 <id: 1HcLOUpzM2NSIYeDeJEd3iAbsuU52I02m> -> NA
#>   <id: 1-NAKoO2PJ7wmjGBsdRWtUB37FYPAuLbvx4Tpk_OL8js>
#> # A dribble: 2 × 5
#>   name  id       name_shortcut id_shortcut drive_resource  
#>   <chr> <drv_id> <chr>         <drv_id>    <list>          
#> 1 NA    1-NAKoO… shortcut-2    1ZF6pZ4…    <named list [3]>
#> 2 NA    1-NAKoO… shortcut-1    1HcLOUp…    <named list [3]>
# No error, but resolution is unsuccessful due to non-existent target

# Clean up
drive_rm(sc_dat)
#> Files deleted:
#> • shortcut-2 <id: 1ZF6pZ4JsvJHlvwfEoookr_ytZ-Jca2Xs>
#> • shortcut-1 <id: 1HcLOUpzM2NSIYeDeJEd3iAbsuU52I02m>
```
