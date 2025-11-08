# Find files on Google Drive

This is the closest googledrive function to what you can do at
<https://drive.google.com>: by default, you just get a listing of your
files. You can also search in various ways, e.g., filter by file type or
ownership or work with [shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).
This is a very powerful function. Together with the more specific
[`drive_get()`](https://googledrive.tidyverse.org/dev/reference/drive_get.md),
this is the main way to identify files to target for downstream work. If
you know you want to search within a specific folder or shared drive,
use
[`drive_ls()`](https://googledrive.tidyverse.org/dev/reference/drive_ls.md).

## Usage

``` r
drive_find(
  pattern = NULL,
  trashed = FALSE,
  type = NULL,
  n_max = Inf,
  shared_drive = NULL,
  corpus = NULL,
  ...,
  verbose = deprecated(),
  team_drive = deprecated()
)
```

## Arguments

- pattern:

  Character. If provided, only the items whose names match this regular
  expression are returned. This is implemented locally on the results
  returned by the API.

- trashed:

  Logical. Whether to search files that are not in the trash
  (`trashed = FALSE`, the default), only files that are in the trash
  (`trashed = TRUE`), or to search regardless of trashed status
  (`trashed = NA`).

- type:

  Character. If provided, only files of this type will be returned. Can
  be anything that
  [`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md)
  knows how to handle. This is processed by googledrive and sent as a
  query parameter.

- n_max:

  Integer. An upper bound on the number of items to return. This applies
  to the results requested from the API, which may be further filtered
  locally, via the `pattern` argument.

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

- ...:

  Other parameters to pass along in the request. The most likely
  candidate is `q`. See below and the API's [Search for files and
  folders
  guide](https://developers.google.com/drive/api/v3/search-files).

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
a tibble with one row per file.

## File type

The `type` argument is pre-processed with
[`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md),
so you can use a few shortcuts and file extensions, in addition to
full-blown MIME types. googledrive forms a search clause to pass to `q`.

## Search parameters

Do advanced search on file properties by providing search clauses to the
`q` parameter that is passed to the API via `...`. Multiple `q` clauses
or vector-valued `q` are combined via 'and'.

## Trash

By default, `drive_find()` sets `trashed = FALSE` and does not include
files in the trash. Literally, it adds `q = "trashed = false"` to the
query. To search *only* the trash, set `trashed = TRUE`. To see files
regardless of trash status, set `trashed = NA`, which adds
`q = "(trashed = true or trashed = false)"` to the query.

## Sort order

By default, `drive_find()` sends `orderBy = "recency desc"`, so the top
files in your result have high "recency" (whatever that means). To
suppress sending `orderBy` at all, do `drive_find(orderBy = NULL)`. The
`orderBy` parameter accepts sort keys in addition to `recency`, which
are documented in the [`files.list`
endpoint](https://developers.google.com/drive/api/v3/reference/files/list).
googledrive translates a snake_case specification of `order_by` into the
lowerCamel form, `orderBy`.

## Shared drives and domains

If you work with shared drives and/or Google Workspace, you can apply
your search query to collections of items beyond those associated with
"My Drive". Use the `shared_drive` or `corpus` arguments to control
this. Read more about [shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

## See also

Wraps the `files.list` endpoint:

- <https://developers.google.com/drive/api/v3/reference/files/list>

Helpful resource for forming your own queries:

- <https://developers.google.com/drive/api/v3/search-files>

## Examples

``` r
if (FALSE) { # \dontrun{
# list "My Drive" w/o regard for folder hierarchy
drive_find()

# filter for folders, the easy way and the hard way
drive_find(type = "folder")
drive_find(q = "mimeType = 'application/vnd.google-apps.folder'")

# filter for Google Sheets, the easy way and the hard way
drive_find(type = "spreadsheet")
drive_find(q = "mimeType='application/vnd.google-apps.spreadsheet'")

# files whose names match a regex
# the local, general, sometimes-slow-to-execute version
drive_find(pattern = "ick")
# the server-side, executes-faster version
# NOTE: works only for a pattern at the beginning of file name
drive_find(q = "name contains 'chick'")

# search for files located directly in your root folder
drive_find(q = "'root' in parents")
# FYI: this is equivalent to
drive_ls("~/")

# control page size or cap the number of files returned
drive_find(pageSize = 50)
# all params passed through `...` can be camelCase or snake_case
drive_find(page_size = 50)
drive_find(n_max = 58)
drive_find(page_size = 5, n_max = 15)

# various ways to specify q search clauses
# multiple q's
drive_find(
  q = "name contains 'TEST'",
  q = "modifiedTime > '2020-07-21T12:00:00'"
)
# vector q
drive_find(q = c("starred = true", "visibility = 'anyoneWithLink'"))

# default `trashed = FALSE` excludes files in the trash
# `trashed = TRUE` consults ONLY file in the trash
drive_find(trashed = TRUE)
# `trashed = NA` disregards trash status completely
drive_find(trashed = NA)

# suppress the default sorting on recency
drive_find(order_by = NULL, n_max = 5)

# sort on various keys
drive_find(order_by = "modifiedByMeTime", n_max = 5)
# request descending order
drive_find(order_by = "quotaBytesUsed desc", n_max = 5)
} # }
```
