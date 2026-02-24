# Get Drive files by path or id

Retrieves metadata for files specified via `path` or via file `id`. This
function is quite straightforward if you specify files by `id`. But
there are some important considerations when you specify your target
files by `path`. See below for more. If the target files are specified
via `path`, the returned
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
will include a `path` column.

## Usage

``` r
drive_get(
  path = NULL,
  id = NULL,
  shared_drive = NULL,
  corpus = NULL,
  verbose = deprecated(),
  team_drive = deprecated()
)
```

## Arguments

- path:

  Character vector of path(s) to get. Use a trailing slash to indicate
  explicitly that a path is a folder, which can disambiguate if there is
  a file of the same name (yes this is possible on Drive!). If `path`
  appears to contain Drive URLs or is explicitly marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  it is treated as if it was provided via the `id` argument.

- id:

  Character vector of Drive file ids or URLs (it is first processed with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)).
  If both `path` and `id` are non-`NULL`, `id` is silently ignored.

- shared_drive:

  Anything that identifies one specific shared drive: its name, its id
  or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).
  The value provided to `shared_drive` is pre-processed with
  [`as_shared_drive()`](https://googledrive.tidyverse.org/dev/reference/as_shared_drive.md).
  Read more about [shared
  drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

- corpus:

  Character, specifying which collections of items to search. Relevant
  to those who work with shared drives and/or Google Workspace domains.
  If specified, must be one of `"user"`, `"drive"` (requires that
  `shared_drive` also be specified), `"allDrives"`, or `"domain"`. Read
  more about [shared
  drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

- verbose:

  **\[deprecated\]** This logical argument to individual googledrive
  functions is deprecated. To globally suppress googledrive messaging,
  use `options(googledrive_quiet = TRUE)` (the default behaviour is to
  emit informational messages). To suppress messaging in a more limited
  way, use the helpers
  [`local_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md)
  or
  [`with_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md).

- team_drive:

  **\[deprecated\]** Google Drive and the Drive API have replaced Team
  Drives with shared drives.

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per file. If the target files were specified via
`path`, there will be a `path` column.

## Getting by `path`

Google Drive does NOT behave like your local file system! File and
folder names need not be unique, even at a given level of the hierarchy.
This means that a single path can describe multiple files (or 0 or
exactly 1).

A single file can also be compatible with multiple paths, i.e. one path
could be more specific than the other. A file located at `~/alfa/bravo`
can be found as `bravo`, `alfa/bravo`, and `~/alfa/bravo`. If all 3 of
those were included in the input `path`, they would be represented by a
**single** row in the output.

It's best to think of `drive_get()` as a setwise operation when using
file paths. Do not assume that the `i`-th input path corresponds to row
`i` in the output (although it often does!). If there's not a 1-to-1
relationship between the input and output, this will be announced in a
message.

`drive_get()` performs just enough path resolution to uniquely identify
a file compatible with each input `path`, for all `path`s at once. If
you absolutely want the full canonical path, run the output of
`drive_get()` through
[`drive_reveal(d, "path")`](https://googledrive.tidyverse.org/dev/reference/drive_reveal.md)\`.

## Files that you don't own

If you want to get a file via `path` and it's not necessarily on your My
Drive, you may need to specify the `shared_drive` or `corpus` arguments
to search other collections of items. Read more about [shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

## See also

To add path information to any
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
that lacks it, use
[`drive_reveal(d, "path")`](https://googledrive.tidyverse.org/dev/reference/drive_reveal.md).
To list the contents of a folder, use
[`drive_ls()`](https://googledrive.tidyverse.org/dev/reference/drive_ls.md).
For general searching, use
[`drive_find()`](https://googledrive.tidyverse.org/dev/reference/drive_find.md).

Wraps the `files.get` endpoint and, if you specify files by name or
path, also calls `files.list`:

- <https://developers.google.com/drive/api/v3/reference/files/get>

- <https://developers.google.com/drive/api/v3/reference/files/list>

## Examples

``` r
# get info about your "My Drive" root folder
drive_get("~/")
#> ✔ The input `path` resolved to exactly 1 file.
#> # A dribble: 1 × 4
#>   name     path  id                  drive_resource   
#>   <chr>    <chr> <drv_id>            <list>           
#> 1 My Drive ~/    0AO_RMaBzcP63Uk9PVA <named list [33]>
# the API reserves the file id "root" for your root folder
drive_get(id = "root")
#> # A dribble: 1 × 3
#>   name     id                  drive_resource   
#>   <chr>    <drv_id>            <list>           
#> 1 My Drive 0AO_RMaBzcP63Uk9PVA <named list [33]>
drive_get(id = "root") |> drive_reveal("path")
#> # A dribble: 1 × 4
#>   name     path  id                  drive_resource   
#>   <chr>    <chr> <drv_id>            <list>           
#> 1 My Drive ~/    0AO_RMaBzcP63Uk9PVA <named list [33]>

# set up some files to get by path
alfalfa <- drive_mkdir("alfalfa")
#> Created Drive file:
#> • alfalfa <id: 19wOv6kaRKCw9-BQUIaB8sfF9GgqVy9PB>
#> With MIME type:
#> • application/vnd.google-apps.folder
broccoli <- drive_upload(
  drive_example_local("chicken.txt"),
  name = "broccoli", path = alfalfa
)
#> Local file:
#> • /home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.txt
#> Uploaded into Drive file:
#> • broccoli <id: 19ODg09g8WnnjsyOQSWycdQpqnqSc0eN2>
#> With MIME type:
#> • text/plain
drive_get("broccoli")
#> ! Problem with 1 path: path is compatible with more than 1 file
#>   broccoli
#> ! No path resolved to exactly 1 file.
#> # A dribble: 2 × 4
#>   name     path     id                                drive_resource   
#>   <chr>    <chr>    <drv_id>                          <list>           
#> 1 broccoli broccoli 19ODg09g8WnnjsyOQSWycdQpqnqSc0eN2 <named list [43]>
#> 2 broccoli broccoli 1aNh9_YiunRSwgmopO5hZJgusiZQh1Ii7 <named list [44]>
drive_get("alfalfa/broccoli")
#> ✔ The input `path` resolved to exactly 1 file.
#> # A dribble: 1 × 4
#>   name     path               id       drive_resource   
#>   <chr>    <chr>              <drv_id> <list>           
#> 1 broccoli ~/alfalfa/broccoli 19ODg09… <named list [43]>
drive_get("~/alfalfa/broccoli")
#> ✔ The input `path` resolved to exactly 1 file.
#> # A dribble: 1 × 4
#>   name     path               id       drive_resource   
#>   <chr>    <chr>              <drv_id> <list>           
#> 1 broccoli ~/alfalfa/broccoli 19ODg09… <named list [44]>
drive_get(c("broccoli", "alfalfa/", "~/alfalfa/broccoli"))
#> ! Problem with 1 path: path is compatible with more than 1 file
#>   broccoli
#> ! 1 file in the output is associated with more than 1 input `path`
#>   broccoli <id: 19ODg09g8WnnjsyOQSWycdQpqnqSc0eN2>
#> ! 2 out of 3 input paths resolved to exactly 1 file.
#> # A dribble: 3 × 4
#>   name     path               id       drive_resource   
#>   <chr>    <chr>              <drv_id> <list>           
#> 1 broccoli ~/alfalfa/broccoli 19ODg09… <named list [44]>
#> 2 broccoli ~/broccoli         1aNh9_Y… <named list [44]>
#> 3 alfalfa  ~/alfalfa/         19wOv6k… <named list [35]>

# Clean up
drive_rm(alfalfa)
#> File deleted:
#> • alfalfa <id: 19wOv6kaRKCw9-BQUIaB8sfF9GgqVy9PB>

if (FALSE) { # \dontrun{
# The examples below are indicative of correct syntax.
# But note these will generally result in an error or a
# 0-row dribble, unless you replace the inputs with paths
# or file ids that exist in your Drive.

# multiple names
drive_get(c("abc", "def"))

# multiple names, one of which must be a folder
drive_get(c("abc", "def/"))

# query by file id(s)
drive_get(id = "abcdefgeh123456789")
drive_get(as_id("abcdefgeh123456789"))
drive_get(id = c("abcdefgh123456789", "jklmnopq123456789"))

# apply to a browser URL for, e.g., a Google Sheet
my_url <- "https://docs.google.com/spreadsheets/d/FILE_ID/edit#gid=SHEET_ID"
drive_get(my_url)
drive_get(as_id(my_url))
drive_get(id = my_url)

# access the shared drive named "foo"
# shared_drive params must be specified if getting by path
foo <- shared_drive_get("foo")
drive_get(c("this.jpg", "that-file"), shared_drive = foo)
# shared_drive params are not necessary if getting by id
drive_get(as_id("123456789"))

# search all shared drives and other files user has accessed
drive_get(c("this.jpg", "that-file"), corpus = "allDrives")
} # }
```
