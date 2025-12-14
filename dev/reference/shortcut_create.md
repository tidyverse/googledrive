# Create a shortcut to a Drive file

Creates a shortcut to the target Drive `file`, which could be a folder.
A Drive shortcut functions like a symbolic or "soft" link and is
primarily useful for creating a specific Drive user experience in the
browser, i.e. to make a Drive file or folder appear in more than 1
place. Shortcuts are a relatively new feature in Drive; they were
introduced when Drive stopped allowing a file to have more than 1 parent
folder.

## Usage

``` r
shortcut_create(file, path = NULL, name = NULL, overwrite = NA)
```

## Arguments

- file:

  Something that identifies the file of interest on your Google Drive.
  Can be a name or path, a file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- path:

  Target destination for the new shortcut, i.e. a folder or a shared
  drive. Can be given as an actual path (character), a file id or URL
  marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).
  Defaults to your "My Drive" root folder. If `path` is a shortcut to a
  folder, it is automatically resolved to its target folder.

- name:

  Character, new shortcut name if not specified as part of `path`. This
  will force `path` to be interpreted as a folder, even if it is
  character and lacks a trailing slash. By default, the shortcut starts
  out with the same name as the target `file`. As a consequence, if you
  want to use `overwrite = TRUE` or `overwrite = FALSE`, you **must**
  explicitly specify the shortcut's `name`.

- overwrite:

  Logical, indicating whether to check for a pre-existing file at the
  targetted "filepath". The quotes around "filepath" refer to the fact
  that Drive does not impose a 1-to-1 relationship between filepaths and
  files, like a typical file system; read more about that in
  [`drive_get()`](https://googledrive.tidyverse.org/dev/reference/drive_get.md).

  - `NA` (default): Just do the operation, even if it results in
    multiple files with the same filepath.

  - `TRUE`: Check for a pre-existing file at the filepath. If there is
    zero or one, move a pre-existing file to the trash, then carry on.
    Note that the new file does not inherit any properties from the old
    one, such as sharing or publishing settings. It will have a new file
    ID. An error is thrown if two or more pre-existing files are found.

  - `FALSE`: Error if there is any pre-existing file at the filepath.

  Note that existence checks, based on filepath, are expensive
  operations, i.e. they require additional API calls.

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per file.

## See also

- <https://developers.google.com/drive/api/v3/shortcuts>

## Examples

``` r
# Target one of the official example files
(src_file <- drive_example_remote("chicken_sheet"))
#> # A dribble: 1 × 3
#>   name          id       drive_resource   
#>   <chr>         <drv_id> <list>           
#> 1 chicken_sheet 1SeFXkr… <named list [32]>

# Create a shortcut in the default location with the default name
sc1 <- shortcut_create(src_file)
#> Created Drive file:
#> • chicken_sheet <id: 1NJPzuEBZKzIpTxsLeTeD3at6Lcuwp8N3>
#> With MIME type:
#> • application/vnd.google-apps.shortcut
# This shortcut could now be moved, renamed, etc.

# Create a shortcut in the default location with a custom name
sc2 <- src_file |>
  shortcut_create(name = "chicken_sheet_second_shortcut")
#> Created Drive file:
#> • chicken_sheet_second_shortcut
#>   <id: 1SoulUkmcFTMCvyIQ4W2gfhFgHlmt9ZxP>
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Create a folder, then put a shortcut there, with default name
folder <- drive_mkdir("chicken_sheet_shortcut_folder")
#> Created Drive file:
#> • chicken_sheet_shortcut_folder
#>   <id: 1nWqpAKX_i9yPcsN2Ora7CHIHzolSIKhw>
#> With MIME type:
#> • application/vnd.google-apps.folder
sc3 <- src_file |>
  shortcut_create(folder)
#> Created Drive file:
#> • chicken_sheet <id: 1QDexduhtp3o9aLFFxf0CYSuYzv4Y_IE->
#> With MIME type:
#> • application/vnd.google-apps.shortcut

# Look at all these shortcuts
(dat <- drive_find("chicken_sheet", type = "shortcut"))
#> # A dribble: 3 × 3
#>   name                          id       drive_resource   
#>   <chr>                         <drv_id> <list>           
#> 1 chicken_sheet                 1QDexdu… <named list [34]>
#> 2 chicken_sheet_second_shortcut 1SoulUk… <named list [34]>
#> 3 chicken_sheet                 1NJPzuE… <named list [34]>

# Confirm the shortcuts all target the original file
dat <- dat |>
  drive_reveal("shortcut_details")
purrr::map_chr(dat$shortcut_details, "targetId")
#> [1] "1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU"
#> [2] "1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU"
#> [3] "1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU"
as_id(src_file)
#> <drive_id[1]>
#> [1] 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU

# Clean up
drive_rm(sc1, sc2, sc3, folder)
#> Files deleted:
#> • chicken_sheet <id: 1NJPzuEBZKzIpTxsLeTeD3at6Lcuwp8N3>
#> • chicken_sheet_second_shortcut
#>   <id: 1SoulUkmcFTMCvyIQ4W2gfhFgHlmt9ZxP>
#> • chicken_sheet <id: 1QDexduhtp3o9aLFFxf0CYSuYzv4Y_IE->
#> • chicken_sheet_shortcut_folder
#>   <id: 1nWqpAKX_i9yPcsN2Ora7CHIHzolSIKhw>
```
