# Create a new blank Drive file

Creates a new blank Drive file. Note there are better options for these
special cases:

- Creating a folder? Use
  [`drive_mkdir()`](https://googledrive.tidyverse.org/dev/reference/drive_mkdir.md).

- Want to upload existing local content into a new Drive file? Use
  [`drive_upload()`](https://googledrive.tidyverse.org/dev/reference/drive_upload.md).

## Usage

``` r
drive_create(
  name,
  path = NULL,
  type = NULL,
  ...,
  overwrite = NA,
  verbose = deprecated()
)
```

## Arguments

- name:

  Name for the new file or, optionally, a path that specifies an
  existing parent folder, as well as the new file name.

- path:

  Target destination for the new item, i.e. a folder or a shared drive.
  Can be given as an actual path (character), a file id or URL marked
  with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).
  Defaults to your "My Drive" root folder. If `path` is a shortcut to a
  folder, it is automatically resolved to its target folder.

- type:

  Character. Create a blank Google Doc, Sheet or Slides by setting
  `type` to `document`, `spreadsheet`, or `presentation`, respectively.
  All non-`NULL` values for `type` are pre-processed with
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

## Examples

``` r
# Create a blank Google Doc named 'WordStar' in
# your 'My Drive' root folder and star it
wordstar <- drive_create("WordStar", type = "document", starred = TRUE)
#> Created Drive file:
#> • WordStar <id: 1_Ac7j2Kz-PAz3IoO6GYfOr0fkWfuokcBMQ2KuymwqE8>
#> With MIME type:
#> • application/vnd.google-apps.document

# is 'WordStar' really starred? YES
purrr::pluck(wordstar, "drive_resource", 1, "starred")
#> [1] TRUE

# Create a blank Google Slides presentation in
# the root folder, and set its description
execuvision <- drive_create(
  "ExecuVision",
  type = "presentation",
  description = "deeply nested bullet lists FTW"
)
#> Created Drive file:
#> • ExecuVision <id: 1MK5bN3NI-TrdRiLc9-LIU_M2DAR3RDM30Qa6ZWsSpW4>
#> With MIME type:
#> • application/vnd.google-apps.presentation

# Did we really set the description? YES
purrr::pluck(execuvision, "drive_resource", 1, "description")
#> [1] "deeply nested bullet lists FTW"

# check out the new presentation
drive_browse(execuvision)

# Create folder 'b4xl' in the root folder,
# then create an empty new Google Sheet in it
b4xl <- drive_mkdir("b4xl")
#> Created Drive file:
#> • b4xl <id: 1cUCP5fT9hYiks65WYwYNh1xlDRGjlrDC>
#> With MIME type:
#> • application/vnd.google-apps.folder
drive_create("VisiCalc", path = b4xl, type = "spreadsheet")
#> Created Drive file:
#> • VisiCalc <id: 1o6CunVGFG57XCAJYF93ScibxfgmrzZAIIosmXKO1_i0>
#> With MIME type:
#> • application/vnd.google-apps.spreadsheet

# Another way to create a Google Sheet in the folder 'b4xl'
drive_create("b4xl/SuperCalc", type = "spreadsheet")
#> Created Drive file:
#> • SuperCalc <id: 17rAep8V5hSWME3ouxT36OF_d1XcihAK4KLDfaSM3GjE>
#> With MIME type:
#> • application/vnd.google-apps.spreadsheet

# Yet another way to create a new file in a folder,
# this time specifying parent `path` as a character
drive_create("Lotus 1-2-3", path = "b4xl", type = "spreadsheet")
#> Created Drive file:
#> • Lotus 1-2-3 <id: 18D1lemI-hII0N6IVt7mThKLoHKH7JfElutGOH5b8AeA>
#> With MIME type:
#> • application/vnd.google-apps.spreadsheet

# Did we really create those Sheets in the intended folder? YES
drive_ls("b4xl")
#> # A dribble: 3 × 3
#>   name        id       drive_resource   
#>   <chr>       <drv_id> <list>           
#> 1 Lotus 1-2-3 18D1lem… <named list [38]>
#> 2 SuperCalc   17rAep8… <named list [38]>
#> 3 VisiCalc    1o6CunV… <named list [38]>

# `overwrite = FALSE` errors if file already exists at target filepath
# THIS WILL ERROR!
drive_create("VisiCalc", path = b4xl, overwrite = FALSE)
#> Error in check_for_overwrite(params[["parents"]], params[["name"]], overwrite): 1 item already exists at the target filepath and `overwrite =
#> FALSE`:
#> • VisiCalc <id: 1o6CunVGFG57XCAJYF93ScibxfgmrzZAIIosmXKO1_i0>

# `overwrite = TRUE` moves an existing file to trash, then proceeds
drive_create("VisiCalc", path = b4xl, overwrite = TRUE)
#> File trashed:
#> • VisiCalc <id: 1o6CunVGFG57XCAJYF93ScibxfgmrzZAIIosmXKO1_i0>
#> Created Drive file:
#> • VisiCalc <id: 1lDzwcox6lYrDF-hX5_kF2NcpstYpAgU7>
#> With MIME type:
#> • application/octet-stream

# Clean up
drive_rm(wordstar, b4xl, execuvision)
#> Files deleted:
#> • WordStar <id: 1_Ac7j2Kz-PAz3IoO6GYfOr0fkWfuokcBMQ2KuymwqE8>
#> • b4xl <id: 1cUCP5fT9hYiks65WYwYNh1xlDRGjlrDC>
#> • ExecuVision <id: 1MK5bN3NI-TrdRiLc9-LIU_M2DAR3RDM30Qa6ZWsSpW4>
```
