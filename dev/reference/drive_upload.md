# Upload into a new Drive file

Uploads a local file into a new Drive file. To update the content or
metadata of an existing Drive file, use
[`drive_update()`](https://googledrive.tidyverse.org/dev/reference/drive_update.md).
To upload or update, depending on whether the Drive file already exists,
see
[`drive_put()`](https://googledrive.tidyverse.org/dev/reference/drive_put.md).

## Usage

``` r
drive_upload(
  media,
  path = NULL,
  name = NULL,
  type = NULL,
  ...,
  overwrite = NA,
  verbose = deprecated()
)
```

## Arguments

- media:

  Character, path to the local file to upload.

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
  of the call. By default, the file is created in the current user's "My
  Drive" root folder.

- name:

  Character, new file name if not specified as part of `path`. This will
  force `path` to be interpreted as a folder, even if it is character
  and lacks a trailing slash. Defaults to the file's local name.

- type:

  Character. If `type = NULL`, a MIME type is automatically determined
  from the file extension, if possible. If the source file is of a
  suitable type, you can request conversion to Google Doc, Sheet or
  Slides by setting `type` to `document`, `spreadsheet`, or
  `presentation`, respectively. All non-`NULL` values for `type` are
  pre-processed with
  [`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md).

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

Wraps the `files.create` endpoint:

- <https://developers.google.com/drive/api/v3/reference/files/create>

MIME types that can be converted to native Google formats:

- <https://developers.google.com/drive/api/v3/manage-uploads#import_to_google_docs_types>

## Examples

``` r
# upload a csv file
chicken_csv <- drive_example_local("chicken.csv") |>
  drive_upload("chicken-upload.csv")
#> Local file:
#> • /home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.csv
#> Uploaded into Drive file:
#> • chicken-upload.csv <id: 1JKPgn5HkKhun_pf2em28WODpiniSICuo>
#> With MIME type:
#> • text/csv

# or convert it to a Google Sheet
chicken_sheet <- drive_example_local("chicken.csv") |>
  drive_upload(
    name = "chicken-sheet-upload.csv",
    type = "spreadsheet"
  )
#> Local file:
#> • /home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.csv
#> Uploaded into Drive file:
#> • chicken-sheet-upload
#>   <id: 1bl3Cx42AnhcXwrPzQHZ87caZv6ix5cLIwfszElGiBxU>
#> With MIME type:
#> • application/vnd.google-apps.spreadsheet

# check out the new Sheet!
drive_browse(chicken_sheet)

# Clean up
drive_find("chicken.*upload") |> drive_rm()
#> Files deleted:
#> • chicken-sheet-upload
#>   <id: 1bl3Cx42AnhcXwrPzQHZ87caZv6ix5cLIwfszElGiBxU>
#> • chicken-upload.csv <id: 1JKPgn5HkKhun_pf2em28WODpiniSICuo>

# Upload a file and, at the same time, star it
chicken <- drive_example_local("chicken.jpg") |>
  drive_upload(starred = "true")
#> Local file:
#> • /home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.jpg
#> Uploaded into Drive file:
#> • chicken.jpg <id: 1IyFoNN4zSYXiSMyzEI46LakGsMaofOBa>
#> With MIME type:
#> • image/jpeg

# Is is really starred? YES
purrr::pluck(chicken, "drive_resource", 1, "starred")
#> [1] TRUE

# Clean up
drive_rm(chicken)
#> File deleted:
#> • chicken.jpg <id: 1IyFoNN4zSYXiSMyzEI46LakGsMaofOBa>

# `overwrite = FALSE` errors if something already exists at target filepath
# THIS WILL ERROR!
drive_create("name-squatter-upload")
#> Created Drive file:
#> • name-squatter-upload <id: 1IIbpbrA7GElTdOepLUkThRrh495zC6V6>
#> With MIME type:
#> • application/octet-stream
drive_example_local("chicken.jpg") |>
  drive_upload(
    name = "name-squatter-upload",
    overwrite = FALSE
  )
#> Error in check_for_overwrite(params[["parents"]], params[["name"]], overwrite): 1 item already exists at the target filepath and `overwrite =
#> FALSE`:
#> • name-squatter-upload <id: 1IIbpbrA7GElTdOepLUkThRrh495zC6V6>

# `overwrite = TRUE` moves the existing item to trash, then proceeds
chicken <- drive_example_local("chicken.jpg") |>
  drive_upload(
    name = "name-squatter-upload",
    overwrite = TRUE
  )
#> File trashed:
#> • name-squatter-upload <id: 1IIbpbrA7GElTdOepLUkThRrh495zC6V6>
#> Local file:
#> • /home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.jpg
#> Uploaded into Drive file:
#> • name-squatter-upload <id: 1Tyz_V64GMfY_Yzuc4tZBJ-BI-3-SsBoW>
#> With MIME type:
#> • image/jpeg

# Clean up
drive_rm(chicken)
#> File deleted:
#> • name-squatter-upload <id: 1Tyz_V64GMfY_Yzuc4tZBJ-BI-3-SsBoW>

if (FALSE) { # \dontrun{
# Upload to a shared drive:
#   * Shared drives are only available if your account is associated with a
#     Google Workspace
#   * The shared drive (or shared-drive-hosted folder) MUST be captured as a
#     dribble first and provided via `path`
sd <- shared_drive_get("Marketing")
drive_upload("fascinating.csv", path = sd)
} # }
```
