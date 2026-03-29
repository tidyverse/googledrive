# Move a Drive file

Move a Drive file to a different folder, give it a different name, or
both.

## Usage

``` r
drive_mv(
  file,
  path = NULL,
  name = NULL,
  overwrite = NA,
  verbose = deprecated()
)
```

## Arguments

- file:

  Something that identifies the file of interest on your Google Drive.
  Can be a name or path, a file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- path:

  Specifies target destination for the file on Google Drive. Can be an
  actual path (character), a file id marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

  If `path` is a shortcut to a folder, it is automatically resolved to
  its target folder.

  If `path` is given as a path (as opposed to a `dribble` or an id), it
  is best to explicitly indicate if it's a folder by including a
  trailing slash, since it cannot always be worked out from the context
  of the call. By default, the file stays in its current folder.

- name:

  Character, new file name if not specified as part of `path`. This will
  force `path` to be interpreted as a folder, even if it is character
  and lacks a trailing slash. By default, the file keeps its current
  name.

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

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per file.

## See also

Makes a metadata-only request to the `files.update` endpoint:

- <https://developers.google.com/drive/api/v3/reference/files/update>

## Examples

``` r
# create a file to move
file <- drive_example_remote("chicken.txt") |>
  drive_cp("chicken-mv.txt")
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • chicken-mv.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>

# rename it, but leave in current folder (root folder, in this case)
file <- drive_mv(file, "chicken-mv-renamed.txt")
#> Original file:
#> • chicken-mv.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>
#> Has been renamed:
#> • chicken-mv-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>

# create a folder to move the file into
folder <- drive_mkdir("mv-folder")
#> Created Drive file:
#> • mv-folder <id: 1vUlVJyJPGdCAvAqIL8LiXmOb_8S9-gls>
#> With MIME type:
#> • application/vnd.google-apps.folder

# move the file and rename it again,
# specify destination as a dribble
file <- drive_mv(file, path = folder, name = "chicken-mv-re-renamed.txt")
#> Original file:
#> • chicken-mv-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>
#> Has been renamed and moved:
#> • mv-folder/chicken-mv-re-renamed.txt
#>   <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>

# verify renamed file is now in the folder
drive_ls(folder)
#> # A dribble: 1 × 3
#>   name                      id       drive_resource   
#>   <chr>                     <drv_id> <list>           
#> 1 chicken-mv-re-renamed.txt 16o01RG… <named list [44]>

# move the file back to root folder
file <- drive_mv(file, "~/")
#> Original file:
#> • chicken-mv-re-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>
#> Has been moved:
#> • ~/chicken-mv-re-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>

# move it again
# specify destination as path with trailing slash
# to ensure we get a move vs. renaming it to "mv-folder"
file <- drive_mv(file, "mv-folder/")
#> Original file:
#> • chicken-mv-re-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>
#> Has been moved:
#> • mv-folder/chicken-mv-re-renamed.txt
#>   <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>

# `overwrite = FALSE` errors if something already exists at target filepath
# THIS WILL ERROR!
drive_create("name-squatter-mv", path = "~/")
#> Created Drive file:
#> • name-squatter-mv <id: 1opQAQbEueoDeH_fTipna11x3JpGVU9QC>
#> With MIME type:
#> • application/octet-stream
drive_mv(file, path = "~/", name = "name-squatter-mv", overwrite = FALSE)
#> Error in check_for_overwrite(parent = params[["addParents"]] %||% parent_before,     name = params[["name"]] %||% file$name, overwrite = overwrite): 1 item already exists at the target filepath and `overwrite =
#> FALSE`:
#> • name-squatter-mv <id: 1opQAQbEueoDeH_fTipna11x3JpGVU9QC>

# `overwrite = TRUE` moves the existing item to trash, then proceeds
drive_mv(file, path = "~/", name = "name-squatter-mv", overwrite = TRUE)
#> File trashed:
#> • name-squatter-mv <id: 1opQAQbEueoDeH_fTipna11x3JpGVU9QC>
#> Original file:
#> • chicken-mv-re-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>
#> Has been renamed and moved:
#> • ~/name-squatter-mv <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>

# Clean up
drive_rm(file, folder)
#> Files deleted:
#> • chicken-mv-re-renamed.txt <id: 16o01RGqi93zXjCtoHzgXgmjTyrwvlPwh>
#> • mv-folder <id: 1vUlVJyJPGdCAvAqIL8LiXmOb_8S9-gls>
```
