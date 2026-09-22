# Create a Drive folder

Creates a new Drive folder. To update the metadata of an existing Drive
file, including a folder, use
[`drive_update()`](https://googledrive.tidyverse.org/dev/reference/drive_update.md).

## Usage

``` r
drive_mkdir(name, path = NULL, ..., overwrite = NA, verbose = deprecated())
```

## Arguments

- name:

  Name for the new folder or, optionally, a path that specifies an
  existing parent folder, as well as the new name.

- path:

  Target destination for the new folder, i.e. a folder or a shared
  drive. Can be given as an actual path (character), a file id or URL
  marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).
  Defaults to your "My Drive" root folder. If `path` is a shortcut to a
  folder, it is automatically resolved to its target folder.

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
    Use
    [`drive_update()`](https://googledrive.tidyverse.org/dev/reference/drive_update.md)
    or
    [`drive_put()`](https://googledrive.tidyverse.org/dev/reference/drive_put.md)
    if you want to keep permissions and sharing from an already existing
    file.

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
# Create folder named 'ghi', then another below named it 'jkl' and star it
ghi <- drive_mkdir("ghi")
#> Created Drive file:
#> • ghi <id: 1d1n0XoenG9qjqCXWpWVisWi-TDxlx-IN>
#> With MIME type:
#> • application/vnd.google-apps.folder
jkl <- drive_mkdir("ghi/jkl", starred = TRUE)
#> Created Drive file:
#> • jkl <id: 1GPMyTb3tyqX7oIc8R2CdU_fKqg_OMiU_>
#> With MIME type:
#> • application/vnd.google-apps.folder

# is 'jkl' really starred? YES
purrr::pluck(jkl, "drive_resource", 1, "starred")
#> [1] TRUE

# Another way to create folder 'mno' in folder 'ghi'
drive_mkdir("mno", path = "ghi")
#> Created Drive file:
#> • mno <id: 1RBqAIq2awwKGCYNrXXn3ttyXqAnO36hw>
#> With MIME type:
#> • application/vnd.google-apps.folder

# Yet another way to create a folder named 'pqr' in folder 'ghi',
# this time with parent folder stored in a dribble,
# and setting the new folder's description
pqr <- drive_mkdir("pqr", path = ghi, description = "I am a folder")
#> Created Drive file:
#> • pqr <id: 1RU1fDw9Xo7k_XzeOrte-6StH5_AOd91i>
#> With MIME type:
#> • application/vnd.google-apps.folder

# Did we really set the description? YES
purrr::pluck(pqr, "drive_resource", 1, "description")
#> [1] "I am a folder"

# `overwrite = FALSE` errors if something already exists at target filepath
# THIS WILL ERROR!
drive_create("name-squatter-mkdir", path = ghi)
#> Created Drive file:
#> • name-squatter-mkdir <id: 1q9TNXejIC23FRAR9pFoWuWmfFlw-JQxw>
#> With MIME type:
#> • application/octet-stream
drive_mkdir("name-squatter-mkdir", path = ghi, overwrite = FALSE)
#> Error in check_for_overwrite(params[["parents"]], params[["name"]], overwrite): 1 item already exists at the target filepath and `overwrite =
#> FALSE`:
#> • name-squatter-mkdir <id: 1q9TNXejIC23FRAR9pFoWuWmfFlw-JQxw>

# `overwrite = TRUE` moves the existing item to trash, then proceeds
drive_mkdir("name-squatter-mkdir", path = ghi, overwrite = TRUE)
#> File trashed:
#> • name-squatter-mkdir <id: 1q9TNXejIC23FRAR9pFoWuWmfFlw-JQxw>
#> Created Drive file:
#> • name-squatter-mkdir <id: 1R_j-fWeYDaXf_qsykASk2-9ei_eJ1x2r>
#> With MIME type:
#> • application/vnd.google-apps.folder

# list everything inside 'ghi'
drive_ls("ghi")
#> # A dribble: 4 × 3
#>   name                id                                drive_resource
#>   <chr>               <drv_id>                          <list>        
#> 1 name-squatter-mkdir 1R_j-fWeYDaXf_qsykASk2-9ei_eJ1x2r <named list>  
#> 2 pqr                 1RU1fDw9Xo7k_XzeOrte-6StH5_AOd91i <named list>  
#> 3 mno                 1RBqAIq2awwKGCYNrXXn3ttyXqAnO36hw <named list>  
#> 4 jkl                 1GPMyTb3tyqX7oIc8R2CdU_fKqg_OMiU_ <named list>  

# Clean up
drive_rm(ghi)
#> File deleted:
#> • ghi <id: 1d1n0XoenG9qjqCXWpWVisWi-TDxlx-IN>
```
