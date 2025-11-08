# Download a Drive file

This function downloads a file from Google Drive. Native Google file
types, such as Google Docs, Google Sheets, and Google Slides, must be
exported to a conventional local file type. This can be specified:

- explicitly via `type`

- implicitly via the file extension of `path`

- not at all, i.e. rely on the built-in default

To see what export file types are even possible, see the [Drive API
documentation](https://developers.google.com/drive/api/v3/ref-export-formats)
or the result of `drive_about()$exportFormats`. The returned dribble
includes a `local_path` column.

## Usage

``` r
drive_download(
  file,
  path = NULL,
  type = NULL,
  overwrite = FALSE,
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

  Character. Path for output file. If absent, the default file name is
  the file's name on Google Drive and the default location is working
  directory, possibly with an added file extension.

- type:

  Character. Only consulted if `file` is a native Google file. Specifies
  the desired type of the exported file. Will be processed via
  [`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md),
  so either a file extension like `"pdf"` or a full MIME type like
  `"application/pdf"` is acceptable.

- overwrite:

  A logical scalar. If local `path` already exists, do you want to
  overwrite it?

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

[Download
files](https://developers.google.com/drive/api/v3/manage-downloads), in
the Drive API documentation.

## Examples

``` r
# Target one of the official example files
(src_file <- drive_example_remote("chicken_sheet"))
#> # A dribble: 1 × 3
#>   name          id       drive_resource   
#>   <chr>         <drv_id> <list>           
#> 1 chicken_sheet 1SeFXkr… <named list [32]>

# Download Sheet as csv, explicit type
downloaded_file <- drive_download(src_file, type = "csv")
#> File downloaded:
#> • chicken_sheet <id: 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU>
#> Saved locally as:
#> • chicken_sheet.csv

# See local path to new file
downloaded_file$local_path
#> [1] "chicken_sheet.csv"

# Download as csv, type implicit in file extension
drive_download(src_file, path = "my_csv_file.csv")
#> File downloaded:
#> • chicken_sheet <id: 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU>
#> Saved locally as:
#> • my_csv_file.csv

# Download with default name and type (xlsx)
drive_download(src_file)
#> File downloaded:
#> • chicken_sheet <id: 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU>
#> Saved locally as:
#> • chicken_sheet.xlsx

# Clean up
unlink(c("chicken_sheet.csv", "chicken_sheet.xlsx", "my_csv_file.csv"))
```
