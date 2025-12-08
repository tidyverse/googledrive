# Update an existing Drive file

Update an existing Drive file id with new content ("media" in Drive
API-speak), new metadata, or both. To create a new file or update
existing, depending on whether the Drive file already exists, see
[`drive_put()`](https://googledrive.tidyverse.org/dev/reference/drive_put.md).

## Usage

``` r
drive_update(file, media = NULL, ..., verbose = deprecated())
```

## Arguments

- file:

  Something that identifies the file of interest on your Google Drive.
  Can be a name or path, a file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- media:

  Character, path to the local file to upload.

- ...:

  Named parameters to pass along to the Drive API. Has [dynamic
  dots](https://rlang.r-lib.org/reference/dyn-dots.html) semantics. You
  can affect the metadata of the target file by specifying properties of
  the Files resource via `...`. Read the "Request body" section of the
  Drive API docs for the associated endpoint to learn about relevant
  parameters.

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

Wraps the `files.update` endpoint:

- <https://developers.google.com/drive/api/v3/reference/files/update>

This function supports media upload:

- <https://developers.google.com/drive/api/v3/manage-uploads>

## Examples

``` r
# Create a new file, so we can update it
x <- drive_example_remote("chicken.csv") |>
  drive_cp()
#> Original file:
#> • chicken.csv <id: 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7>
#> Copied to file:
#> • Copy of chicken.csv <id: 1C3aBenexJP7wMCJVInJPwVhgXsSryOeM>

# Update the file with new media
x <- x |>
  drive_update(drive_example_local("chicken.txt"))
#> File updated:
#> • Copy of chicken.csv <id: 1C3aBenexJP7wMCJVInJPwVhgXsSryOeM>

# Update the file with new metadata.
# Notice here `name` is not an argument of `drive_update()`, we are passing
# this to the API via the `...``
x <- x |>
  drive_update(name = "CHICKENS!")
#> File updated:
#> • 'CHICKENS!' <id: 1C3aBenexJP7wMCJVInJPwVhgXsSryOeM>

# Update the file with new media AND new metadata
x <- x |>
  drive_update(
    drive_example_local("chicken.txt"),
    name = "chicken-poem-again.txt"
  )
#> File updated:
#> • chicken-poem-again.txt <id: 1C3aBenexJP7wMCJVInJPwVhgXsSryOeM>

# Clean up
drive_rm(x)
#> File deleted:
#> • chicken-poem-again.txt <id: 1C3aBenexJP7wMCJVInJPwVhgXsSryOeM>
```
