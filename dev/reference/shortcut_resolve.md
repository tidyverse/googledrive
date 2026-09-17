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
#>   <id: 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE>

# Create a shortcut
sc1 <- file |>
  shortcut_create(name = "shortcut-1")
#> Created Drive file:
#> • shortcut-1 <id: 1eBO3VCh5qkrb4C7ScsYrsSPEo9OvEjbV>
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Create a second shortcut by copying the first
sc1 <- sc1 |>
  drive_cp(name = "shortcut-2")
#> Original file:
#> • shortcut-1 <id: 1eBO3VCh5qkrb4C7ScsYrsSPEo9OvEjbV>
#> Copied to file:
#> • shortcut-2 <id: 1HinSaj7n9kK6yeBd-c_NEgTWDyPtdj-N>

# Get the shortcuts
(sc_dat <- drive_find("-[12]$", type = "shortcut"))
#> # A dribble: 2 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 shortcut-2 1HinSaj7n9kK6yeBd-c_NEgTWDyPtdj-N <named list [35]>
#> 2 shortcut-1 1eBO3VCh5qkrb4C7ScsYrsSPEo9OvEjbV <named list [35]>

# Resolve them
(resolved <- shortcut_resolve(sc_dat))
#> ℹ Resolved 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1HinSaj7n9kK6yeBd-c_NEgTWDyPtdj-N> ->
#>   chicken-sheet-for-shortcut
#>   <id: 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE>
#> • shortcut-1 <id: 1eBO3VCh5qkrb4C7ScsYrsSPEo9OvEjbV> ->
#>   chicken-sheet-for-shortcut
#>   <id: 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE>
#> # A dribble: 2 × 5
#>   name                id       name_shortcut id_shortcut drive_resource
#>   <chr>               <drv_id> <chr>         <drv_id>    <list>        
#> 1 chicken-sheet-for-… 19avAs4… shortcut-2    1HinSaj…    <named list>  
#> 2 chicken-sheet-for-… 19avAs4… shortcut-1    1eBO3VC…    <named list>  

resolved$id
#> <drive_id[2]>
#> [1] 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE
#> [2] 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE
file$id
#> <drive_id[1]>
#> [1] 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE

# Delete the target file
drive_rm(file)
#> File deleted:
#> • chicken-sheet-for-shortcut
#>   <id: 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE>

# (Try to) resolve the shortcuts again
shortcut_resolve(sc_dat)
#> ℹ Resolved 0 of 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1HinSaj7n9kK6yeBd-c_NEgTWDyPtdj-N> -> NA
#>   <id: 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE>
#> • shortcut-1 <id: 1eBO3VCh5qkrb4C7ScsYrsSPEo9OvEjbV> -> NA
#>   <id: 19avAs4nDMLDWQxiqtHbU-3R5GcUr0KPaTXNFt82XTtE>
#> # A dribble: 2 × 5
#>   name  id       name_shortcut id_shortcut drive_resource  
#>   <chr> <drv_id> <chr>         <drv_id>    <list>          
#> 1 NA    19avAs4… shortcut-2    1HinSaj…    <named list [3]>
#> 2 NA    19avAs4… shortcut-1    1eBO3VC…    <named list [3]>
# No error, but resolution is unsuccessful due to non-existent target

# Clean up
drive_rm(sc_dat)
#> Files deleted:
#> • shortcut-2 <id: 1HinSaj7n9kK6yeBd-c_NEgTWDyPtdj-N>
#> • shortcut-1 <id: 1eBO3VCh5qkrb4C7ScsYrsSPEo9OvEjbV>
```
