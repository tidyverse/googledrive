# Rename a Drive file

This is a wrapper for
[`drive_mv()`](https://googledrive.tidyverse.org/dev/reference/drive_mv.md)
that only renames a file. If you would like to rename AND move the file,
see
[`drive_mv()`](https://googledrive.tidyverse.org/dev/reference/drive_mv.md).

## Usage

``` r
drive_rename(file, name = NULL, overwrite = NA, verbose = deprecated())
```

## Arguments

- file:

  Something that identifies the file of interest on your Google Drive.
  Can be a name or path, a file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- name:

  Character. Name you would like the file to have.

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

## Examples

``` r
# Create a file to rename
file <- drive_create("file-to-rename")
#> Created Drive file:
#> • file-to-rename <id: 1S0W8s01Dw76_LFUdkFgC6cJ1pEp9XqkR>
#> With MIME type:
#> • application/octet-stream

# Rename it
file <- drive_rename(file, name = "renamed-file")
#> Original file:
#> • file-to-rename <id: 1S0W8s01Dw76_LFUdkFgC6cJ1pEp9XqkR>
#> Has been renamed:
#> • renamed-file <id: 1S0W8s01Dw76_LFUdkFgC6cJ1pEp9XqkR>

# `overwrite = FALSE` errors if something already exists at target filepath
# THIS WILL ERROR!
drive_create("name-squatter-rename")
#> Created Drive file:
#> • name-squatter-rename <id: 1-WY8Gstb3Ta9taZjnzBitHWbj_07f_Ew>
#> With MIME type:
#> • application/octet-stream
drive_rename(file, name = "name-squatter-rename", overwrite = FALSE)
#> Error in check_for_overwrite(parent = params[["addParents"]] %||% parent_before,     name = params[["name"]] %||% file$name, overwrite = overwrite): 1 item already exists at the target filepath and `overwrite =
#> FALSE`:
#> • name-squatter-rename <id: 1-WY8Gstb3Ta9taZjnzBitHWbj_07f_Ew>

# `overwrite = TRUE` moves the existing item to trash, then proceeds
file <- drive_rename(file, name = "name-squatter-rename", overwrite = TRUE)
#> File trashed:
#> • name-squatter-rename <id: 1-WY8Gstb3Ta9taZjnzBitHWbj_07f_Ew>
#> Original file:
#> • renamed-file <id: 1S0W8s01Dw76_LFUdkFgC6cJ1pEp9XqkR>
#> Has been renamed:
#> • name-squatter-rename <id: 1S0W8s01Dw76_LFUdkFgC6cJ1pEp9XqkR>

# Clean up
drive_rm(file)
#> File deleted:
#> • name-squatter-rename <id: 1S0W8s01Dw76_LFUdkFgC6cJ1pEp9XqkR>
```
