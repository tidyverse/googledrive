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
#>   <id: 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c>

# Create a shortcut
sc1 <- file |>
  shortcut_create(name = "shortcut-1")
#> Created Drive file:
#> • shortcut-1 <id: 17MKUvfq3feI9Rz-83iPShYKmm-_ts-kY>
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Create a second shortcut by copying the first
sc1 <- sc1 |>
  drive_cp(name = "shortcut-2")
#> Original file:
#> • shortcut-1 <id: 17MKUvfq3feI9Rz-83iPShYKmm-_ts-kY>
#> Copied to file:
#> • shortcut-2 <id: 1lh1oPgRl_ChmEdupDtussVfCn13SkBMS>

# Get the shortcuts
(sc_dat <- drive_find("-[12]$", type = "shortcut"))
#> # A dribble: 2 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 shortcut-2 1lh1oPgRl_ChmEdupDtussVfCn13SkBMS <named list [35]>
#> 2 shortcut-1 17MKUvfq3feI9Rz-83iPShYKmm-_ts-kY <named list [35]>

# Resolve them
(resolved <- shortcut_resolve(sc_dat))
#> ℹ Resolved 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1lh1oPgRl_ChmEdupDtussVfCn13SkBMS> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c>
#> • shortcut-1 <id: 17MKUvfq3feI9Rz-83iPShYKmm-_ts-kY> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c>
#> # A dribble: 2 × 5
#>   name                id       name_shortcut id_shortcut drive_resource
#>   <chr>               <drv_id> <chr>         <drv_id>    <list>        
#> 1 chicken-sheet-for-… 1RVhStC… shortcut-2    1lh1oPg…    <named list>  
#> 2 chicken-sheet-for-… 1RVhStC… shortcut-1    17MKUvf…    <named list>  

resolved$id
#> <drive_id[2]>
#> [1] 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c
#> [2] 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c
file$id
#> <drive_id[1]>
#> [1] 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c

# Delete the target file
drive_rm(file)
#> File deleted:
#> • chicken-sheet-for-shortcut
#>   <id: 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c>

# (Try to) resolve the shortcuts again
shortcut_resolve(sc_dat)
#> ℹ Resolved 0 of 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1lh1oPgRl_ChmEdupDtussVfCn13SkBMS> -> NA
#>   <id: 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c>
#> • shortcut-1 <id: 17MKUvfq3feI9Rz-83iPShYKmm-_ts-kY> -> NA
#>   <id: 1RVhStCZV_8lfQzLx5eogiriLkb74HpG-wBfKWOG5G0c>
#> # A dribble: 2 × 5
#>   name  id       name_shortcut id_shortcut drive_resource  
#>   <chr> <drv_id> <chr>         <drv_id>    <list>          
#> 1 NA    1RVhStC… shortcut-2    1lh1oPg…    <named list [3]>
#> 2 NA    1RVhStC… shortcut-1    17MKUvf…    <named list [3]>
# No error, but resolution is unsuccessful due to non-existent target

# Clean up
drive_rm(sc_dat)
#> Files deleted:
#> • shortcut-2 <id: 1lh1oPgRl_ChmEdupDtussVfCn13SkBMS>
#> • shortcut-1 <id: 17MKUvfq3feI9Rz-83iPShYKmm-_ts-kY>
```
