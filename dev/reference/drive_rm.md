# Delete files from Drive

Caution: this will permanently delete your files! For a safer,
reversible option, see
[`drive_trash()`](https://googledrive.tidyverse.org/dev/reference/drive_trash.md).

## Usage

``` r
drive_rm(..., verbose = deprecated())
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
#> 1 chicken.txt 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y <named list [40]>

# Create a copy, then remove it by name
src_file |>
  drive_cp(name = "chicken-rm.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-rm.txt <id: 1fLohakau_K8qidbjpAvNPn0D0527RXwX>
drive_rm("chicken-rm.txt")
#> File deleted:
#> • chicken-rm.txt <id: 1fLohakau_K8qidbjpAvNPn0D0527RXwX>

# Create several more copies
x1 <- src_file |>
  drive_cp(name = "chicken-abc.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-abc.txt <id: 1YyXaSY019kBbGaTlmCUGbqSngvP3bzam>
drive_cp(src_file, name = "chicken-def.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-def.txt <id: 1sg9DnhLHQ9q9iTl2AoPlQe6Gz7jA13cL>
x2 <- src_file |>
  drive_cp(name = "chicken-ghi.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-ghi.txt <id: 1M8yBpHC1HOtIogSlQgVE_kAL2umeha6O>

# Remove the copies all at once, specified in different ways
drive_rm(x1, "chicken-def.txt", as_id(x2))
#> Files deleted:
#> • chicken-abc.txt <id: 1YyXaSY019kBbGaTlmCUGbqSngvP3bzam>
#> • chicken-def.txt <id: 1sg9DnhLHQ9q9iTl2AoPlQe6Gz7jA13cL>
#> • chicken-ghi.txt <id: 1M8yBpHC1HOtIogSlQgVE_kAL2umeha6O>
```
