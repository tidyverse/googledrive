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
#>   <id: 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk>

# Create a shortcut
sc1 <- file |>
  shortcut_create(name = "shortcut-1")
#> Created Drive file:
#> • shortcut-1 <id: 1A-sTaR4ctzWYhR1xJm8Wr3YycoVMDT77>
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Create a second shortcut by copying the first
sc1 <- sc1 |>
  drive_cp(name = "shortcut-2")
#> Original file:
#> • shortcut-1 <id: 1A-sTaR4ctzWYhR1xJm8Wr3YycoVMDT77>
#> Copied to file:
#> • shortcut-2 <id: 1rmQ5Unsd23VXINO2z52ltnAOT-G5xz4d>

# Get the shortcuts
(sc_dat <- drive_find("-[12]$", type = "shortcut"))
#> # A dribble: 2 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 shortcut-2 1rmQ5Unsd23VXINO2z52ltnAOT-G5xz4d <named list [34]>
#> 2 shortcut-1 1A-sTaR4ctzWYhR1xJm8Wr3YycoVMDT77 <named list [34]>

# Resolve them
(resolved <- shortcut_resolve(sc_dat))
#> ℹ Resolved 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1rmQ5Unsd23VXINO2z52ltnAOT-G5xz4d> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk>
#> • shortcut-1 <id: 1A-sTaR4ctzWYhR1xJm8Wr3YycoVMDT77> ->
#>   chicken-sheet-for-shortcut
#>   <id: 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk>
#> # A dribble: 2 × 5
#>   name                id       name_shortcut id_shortcut drive_resource
#>   <chr>               <drv_id> <chr>         <drv_id>    <list>        
#> 1 chicken-sheet-for-… 1vdtKPr… shortcut-2    1rmQ5Un…    <named list>  
#> 2 chicken-sheet-for-… 1vdtKPr… shortcut-1    1A-sTaR…    <named list>  

resolved$id
#> <drive_id[2]>
#> [1] 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk
#> [2] 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk
file$id
#> <drive_id[1]>
#> [1] 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk

# Delete the target file
drive_rm(file)
#> File deleted:
#> • chicken-sheet-for-shortcut
#>   <id: 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk>

# (Try to) resolve the shortcuts again
shortcut_resolve(sc_dat)
#> ℹ Resolved 0 of 2 shortcuts found in 2 files:
#> • shortcut-2 <id: 1rmQ5Unsd23VXINO2z52ltnAOT-G5xz4d> -> NA
#>   <id: 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk>
#> • shortcut-1 <id: 1A-sTaR4ctzWYhR1xJm8Wr3YycoVMDT77> -> NA
#>   <id: 1vdtKPrYHJU5eyCKvbQ6zsh78XulS7eG1kTPbcnznluk>
#> # A dribble: 2 × 5
#>   name  id       name_shortcut id_shortcut drive_resource  
#>   <chr> <drv_id> <chr>         <drv_id>    <list>          
#> 1 NA    1vdtKPr… shortcut-2    1rmQ5Un…    <named list [3]>
#> 2 NA    1vdtKPr… shortcut-1    1A-sTaR…    <named list [3]>
# No error, but resolution is unsuccessful due to non-existent target

# Clean up
drive_rm(sc_dat)
#> Files deleted:
#> • shortcut-2 <id: 1rmQ5Unsd23VXINO2z52ltnAOT-G5xz4d>
#> • shortcut-1 <id: 1A-sTaR4ctzWYhR1xJm8Wr3YycoVMDT77>
```
