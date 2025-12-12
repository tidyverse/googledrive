# Copy a Drive file

Copies an existing Drive file into a new file id.

## Usage

``` r
drive_cp(
  file,
  path = NULL,
  name = NULL,
  ...,
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

  Specifies target destination for the new file on Google Drive. Can be
  an actual path (character), a file id marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

  If `path` is a shortcut to a folder, it is automatically resolved to
  its target folder.

  If `path` is given as a path (as opposed to a `dribble` or an id), it
  is best to explicitly indicate if it's a folder by including a
  trailing slash, since it cannot always be worked out from the context
  of the call. By default, the new file has the same parent folder as
  the source file.

- name:

  Character, new file name if not specified as part of `path`. This will
  force `path` to be interpreted as a folder, even if it is character
  and lacks a trailing slash. Defaults to "Copy of `FILE-NAME`".

- ...:

  Named parameters to pass along to the Drive API. Has [dynamic
  dots](https://rlang.r-lib.org/reference/dyn-dots.html) semantics. You
  can affect the metadata of the target file by specifying properties of
  the Files resource via `...`. Read the "Request body" section of the
  Drive API docs for the associated endpoint to learn about relevant
  parameters.

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

Wraps the `files.copy` endpoint:

- <https://developers.google.com/drive/api/v3/reference/files/copy>

## Examples

``` r
# Target one of the official example files
(src_file <- drive_example_remote("chicken.txt"))
#> # A dribble: 1 × 3
#>   name        id                                drive_resource   
#>   <chr>       <drv_id>                          <list>           
#> 1 chicken.txt 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y <named list [40]>

# Make a "Copy of" copy in your My Drive
cp1 <- drive_cp(src_file)
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • Copy of chicken.txt <id: 1UQbEXTVzBcm5N4X6WfRokF85fFqZnukj>

# Make an explicitly named copy, in a different folder, and star it.
# The starring is an example of providing metadata via `...`.
# `starred` is not an actual argument to `drive_cp()`,
# it just gets passed through to the API.
folder <- drive_mkdir("drive-cp-folder")
#> Created Drive file:
#> • drive-cp-folder <id: 1sR-WNdSRPX7s5v4W6miJzieGMGVj0XWh>
#> With MIME type:
#> • application/vnd.google-apps.folder
cp2 <- drive_cp(
  src_file,
  path = folder,
  name = "chicken-cp.txt",
  starred = TRUE
)
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • drive-cp-folder/chicken-cp.txt
#>   <id: 1pdhTxUL08PGEwyrWhI7X67FlUkGnzoTD>
drive_reveal(cp2, "starred")
#> # A dribble: 1 × 4
#>   name           starred id       drive_resource   
#>   <chr>          <lgl>   <drv_id> <list>           
#> 1 chicken-cp.txt TRUE    1pdhTxU… <named list [43]>

# `overwrite = FALSE` errors if file already exists at target filepath
# THIS WILL ERROR!
# drive_cp(src_file, name = "Copy of chicken.txt", overwrite = FALSE)

# `overwrite = TRUE` moves an existing file to trash, then proceeds
cp3 <- drive_cp(src_file, name = "Copy of chicken.txt", overwrite = TRUE)
#> File trashed:
#> • Copy of chicken.txt <id: 1UQbEXTVzBcm5N4X6WfRokF85fFqZnukj>
#> Original file:
#> • chicken.txt <id: 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y>
#> Copied to file:
#> • Copy of chicken.txt <id: 1Wp1_IkAisw9zIFMTJiaMem4R9D1PVvbK>

# Delete all of our copies and the new folder!
drive_rm(cp1, cp2, cp3, folder)
#> Files deleted:
#> • Copy of chicken.txt <id: 1UQbEXTVzBcm5N4X6WfRokF85fFqZnukj>
#> • chicken-cp.txt <id: 1pdhTxUL08PGEwyrWhI7X67FlUkGnzoTD>
#> • Copy of chicken.txt <id: 1Wp1_IkAisw9zIFMTJiaMem4R9D1PVvbK>
#> • drive-cp-folder <id: 1sR-WNdSRPX7s5v4W6miJzieGMGVj0XWh>

# Target an official example file that's a csv file
(csv_file <- drive_example_remote("chicken.csv"))
#> # A dribble: 1 × 3
#>   name        id                                drive_resource   
#>   <chr>       <drv_id>                          <list>           
#> 1 chicken.csv 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7 <named list [39]>

# copy AND AT THE SAME TIME convert it to a Google Sheet
chicken_sheet <- drive_cp(
  csv_file,
  name = "chicken-sheet-copy",
  mime_type = drive_mime_type("spreadsheet")
)
#> Original file:
#> • chicken.csv <id: 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7>
#> Copied to file:
#> • chicken-sheet-copy
#>   <id: 1NfS_nv7naQK5EMNqXu-kanqO3wX5CH3dXsZTge-unNI>
# is it really a Google Sheet?
drive_reveal(chicken_sheet, "mime_type")$mime_type
#> [1] "application/vnd.google-apps.spreadsheet"

# go see the new Sheet in the browser
# drive_browse(chicken_sheet)

# Clean up
drive_rm(chicken_sheet)
#> File deleted:
#> • chicken-sheet-copy
#>   <id: 1NfS_nv7naQK5EMNqXu-kanqO3wX5CH3dXsZTge-unNI>
```
