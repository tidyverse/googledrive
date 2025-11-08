# Deprecated Team Drive functions

**\[deprecated\]**

Team Drives have been rebranded as *shared drives* and, as of
googledrive v2.0.0, all `team_drive_*()` functions have been deprecated,
in favor of `shared_drive_*()` successors.

The changes in googledrive reflect that the Team Drives resource
collection has been deprecated in the Drive API v3, in favor of the new
(shared) Drives resource collection. Read more

- <https://cloud.google.com/blog/products/application-development/upcoming-changes-to-the-google-drive-api-and-google-picker-api>

## Usage

``` r
team_drive_find(pattern = NULL, n_max = Inf, ..., verbose = deprecated())

team_drive_get(name = NULL, id = NULL, verbose = deprecated())

team_drive_create(name, verbose = deprecated())

team_drive_rm(team_drive = NULL, verbose = deprecated())

team_drive_update(team_drive, ..., verbose = deprecated())

as_team_drive(x, ...)

is_team_drive(d)
```

## Arguments

- pattern:

  Character. If provided, only the items whose names match this regular
  expression are returned. This is implemented locally on the results
  returned by the API.

- n_max:

  Integer. An upper bound on the number of items to return. This applies
  to the results requested from the API, which may be further filtered
  locally, via the `pattern` argument.

- ...:

  Other parameters to pass along in the request, such as `pageSize` or
  `useDomainAdminAccess`.

- name:

  Character vector of names. A character vector marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)
  is treated as if it was provided via the `id` argument.

- id:

  Character vector of shared drive ids or URLs (it is first processed
  with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)).
  If both `name` and `id` are non-`NULL`, `id` is silently ignored.

- team_drive:

  **\[deprecated\]** Google Drive and the Drive API have replaced Team
  Drives with shared drives.

- x:

  A vector of shared drive names, a vector of shared drive ids marked
  with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  a list of Drives resource objects, or a suitable data frame.

- d:

  A
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per shared drive.
