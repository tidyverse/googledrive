# PUT new media into a Drive file

PUTs new media into a Drive file, in the HTTP sense:

- If the file already exists, we replace its content.

- If the file does not already exist, we create a new file.

This is a convenience wrapper around
[`drive_upload()`](https://googledrive.tidyverse.org/dev/reference/drive_upload.md)
and
[`drive_update()`](https://googledrive.tidyverse.org/dev/reference/drive_update.md).
In pseudo-code:

    target_filepath <- <determined from `path`, `name`, and `media`>
    hits <- <get all Drive files at target_filepath>
    if (no hits) {
      drive_upload(media, path, name, type, ...)
    } else if (exactly 1 hit) {
      drive_update(hit, media, ...)
    } else {
      ERROR
    }

## Usage

``` r
drive_put(
  media,
  path = NULL,
  name = NULL,
  ...,
  type = NULL,
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

- ...:

  Named parameters to pass along to the Drive API. Has [dynamic
  dots](https://rlang.r-lib.org/reference/dyn-dots.html) semantics. You
  can affect the metadata of the target file by specifying properties of
  the Files resource via `...`. Read the "Request body" section of the
  Drive API docs for the associated endpoint to learn about relevant
  parameters.

- type:

  Character. If `type = NULL`, a MIME type is automatically determined
  from the file extension, if possible. If the source file is of a
  suitable type, you can request conversion to Google Doc, Sheet or
  Slides by setting `type` to `document`, `spreadsheet`, or
  `presentation`, respectively. All non-`NULL` values for `type` are
  pre-processed with
  [`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md).

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
# create a local file to work with
local_file <- tempfile("drive_put_", fileext = ".txt")
writeLines(c("beginning", "middle"), local_file)

# PUT to a novel filepath --> drive_put() delegates to drive_upload()
file <- drive_put(local_file)
#> ℹ No pre-existing Drive file at this path. Calling `drive_upload()`.
#> Local file:
#> • /tmp/RtmplI3gau/drive_put_18fa557c1ab.txt
#> Uploaded into Drive file:
#> • drive_put_18fa557c1ab.txt <id: 1hyxOVVv7FnuA4cq47ookHzXDciyezZbl>
#> With MIME type:
#> • text/plain

# update the local file
cat("end", file = local_file, sep = "\n", append = TRUE)

# PUT again --> drive_put() delegates to drive_update()
file <- drive_put(local_file)
#> ℹ A Drive file already exists at this path. Calling `drive_update()`.
#> File updated:
#> • drive_put_18fa557c1ab.txt <id: 1hyxOVVv7FnuA4cq47ookHzXDciyezZbl>

# create a second file at this filepath
file2 <- drive_create(basename(local_file))
#> Created Drive file:
#> • drive_put_18fa557c1ab.txt <id: 1Sqmx3yfqybukPRs6sdpazWLIoIPK3fZX>
#> With MIME type:
#> • text/plain

# PUT again --> ERROR
drive_put(local_file)
#> Error in drive_put(local_file): Multiple items already exist on Drive at the target filepath.
#> Unclear what `drive_put()` should do. Exiting.
#> • drive_put_18fa557c1ab.txt <id: 1Sqmx3yfqybukPRs6sdpazWLIoIPK3fZX>
#> • drive_put_18fa557c1ab.txt <id: 1hyxOVVv7FnuA4cq47ookHzXDciyezZbl>

# Clean up
drive_find("drive_put_.+[.]txt") |> drive_rm()
#> Files deleted:
#> • drive_put_18fa557c1ab.txt <id: 1Sqmx3yfqybukPRs6sdpazWLIoIPK3fZX>
#> • drive_put_18fa557c1ab.txt <id: 1hyxOVVv7FnuA4cq47ookHzXDciyezZbl>
unlink(local_file)
```
