# Delete files from Drive

Caution: this will permanently delete your files! For a safer,
reversible option, see
[`drive_trash()`](https://googledrive.tidyverse.org/dev/reference/drive_trash.md).

## Usage

``` r
drive_rm(...)
```

## Arguments

- ...:

  One or more Drive files, specified in any valid way, i.e. as a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
  by name or path, or by file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md).
  Or any combination thereof. Elements are processed with
  [`as_dribble()`](https://googledrive.tidyverse.org/dev/reference/as_dribble.md)
  and row-bound prior to deletion.

## Value

Logical vector, indicating whether the delete succeeded.

## See also

Wraps the `files.delete` endpoint:

- <https://developers.google.com/drive/api/v3/reference/files/delete>

## Examples

``` r
# Target one of the official example files to copy (then remove)
(src_file <- drive_example_remote("chicken.txt"))
#> # A dribble: 1 × 3
#>   name        id                                drive_resource   
#>   <chr>       <drv_id>                          <list>           
#> 1 chicken.txt 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y <named list [41]>

# Create a copy, then remove it by name
src_file |>
  drive_cp(name = "chicken-rm.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-rm.txt <id: 1WfXTzE4a7RHysuY1llSaAmbXIzfVujwQ>
drive_rm("chicken-rm.txt")
#> File deleted:
#> • chicken-rm.txt <id: 1WfXTzE4a7RHysuY1llSaAmbXIzfVujwQ>

# Create several more copies
x1 <- src_file |>
  drive_cp(name = "chicken-abc.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-abc.txt <id: 1-sFoGG3dbW54dPBsbbhVBbx2s5-g87IT>
drive_cp(src_file, name = "chicken-def.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-def.txt <id: 1mJLbFVJvs6Li6G4cd-lboHEMcIWl24C9>
x2 <- src_file |>
  drive_cp(name = "chicken-ghi.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-ghi.txt <id: 1E-n_fgBsytzokl1bgUJT_S-EEV7_Pn9E>

# Remove the copies all at once, specified in different ways
drive_rm(x1, "chicken-def.txt", as_id(x2))
#> Files deleted:
#> • chicken-abc.txt <id: 1-sFoGG3dbW54dPBsbbhVBbx2s5-g87IT>
#> • chicken-def.txt <id: 1mJLbFVJvs6Li6G4cd-lboHEMcIWl24C9>
#> • chicken-ghi.txt <id: 1E-n_fgBsytzokl1bgUJT_S-EEV7_Pn9E>
```
