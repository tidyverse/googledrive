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
#>   <id: 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214>

# Create a shortcut
sc1 <- file |>
  shortcut_create(name = "shortcut-1")
#> Created Drive file:
#> • shortcut-1 <id: 1i2ZhjpW3y7l8_MMM9NShHZvKx9OlmgT2>
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Create a second shortcut by copying the first
sc1 <- sc1 |>
  drive_cp(name = "shortcut-2")
#> Original file:
#> • shortcut-1 <id: 1i2ZhjpW3y7l8_MMM9NShHZvKx9OlmgT2>
#> Copied to file:
#> • shortcut-2 <id: 1f859odq7Fvsy_OZrRoSOole8z8nxG6S8>

# Get the shortcuts
(sc_dat <- drive_find("-[12]$", type = "shortcut"))
#> # A dribble: 2 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 shortcut-2 1f859odq7Fvsy_OZrRoSOole8z8nxG6S8 <named list [34]>
#> 2 shortcut-1 1i2ZhjpW3y7l8_MMM9NShHZvKx9OlmgT2 <named list [34]>

# Resolve them
(resolved <- shortcut_resolve(sc_dat))
#> ℹ Resolved 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1f859odq7Fvsy_OZrRoSOole8z8nxG6S8> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214>
#> • shortcut-1 <id: 1i2ZhjpW3y7l8_MMM9NShHZvKx9OlmgT2> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214>
#> # A dribble: 2 × 5
#>   name                id       name_shortcut id_shortcut drive_resource
#>   <chr>               <drv_id> <chr>         <drv_id>    <list>        
#> 1 chicken-sheet-for-… 1nFhcid… shortcut-2    1f859od…    <named list>  
#> 2 chicken-sheet-for-… 1nFhcid… shortcut-1    1i2Zhjp…    <named list>  

resolved$id
#> <drive_id[2]>
#> [1] 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214
#> [2] 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214
file$id
#> <drive_id[1]>
#> [1] 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214

# Delete the target file
drive_rm(file)
#> File deleted:
#> • chicken-sheet-for-shortcut
#>   <id: 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214>

# (Try to) resolve the shortcuts again
shortcut_resolve(sc_dat)
#> ℹ Resolved 0 of 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1f859odq7Fvsy_OZrRoSOole8z8nxG6S8> -> NA
#>   <id: 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214>
#> • shortcut-1 <id: 1i2ZhjpW3y7l8_MMM9NShHZvKx9OlmgT2> -> NA
#>   <id: 1nFhcid7va7bp2Ou8pql86jVt2Us4KzyR8Y7Aeq-6214>
#> # A dribble: 2 × 5
#>   name  id       name_shortcut id_shortcut drive_resource  
#>   <chr> <drv_id> <chr>         <drv_id>    <list>          
#> 1 NA    1nFhcid… shortcut-2    1f859od…    <named list [3]>
#> 2 NA    1nFhcid… shortcut-1    1i2Zhjp…    <named list [3]>
# No error, but resolution is unsuccessful due to non-existent target

# Clean up
drive_rm(sc_dat)
#> Files deleted:
#> • shortcut-2 <id: 1f859odq7Fvsy_OZrRoSOole8z8nxG6S8>
#> • shortcut-1 <id: 1i2ZhjpW3y7l8_MMM9NShHZvKx9OlmgT2>
```
