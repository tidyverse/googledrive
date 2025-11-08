# Get shared drives by name or id

Retrieve metadata for shared drives specified by name or id. Note that
Google Drive does NOT behave like your local file system:

- You can get zero, one, or more shared drives back for each name!
  Shared drive names need not be unique.

A shared drive supports files owned by an organization rather than an
individual user. Shared drives follow different sharing and ownership
models from a specific user's "My Drive". Shared drives are the
successors to the earlier concept of Team Drives. Learn more about
[shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

## Usage

``` r
shared_drive_get(name = NULL, id = NULL)
```

## Arguments

- name:

  Character vector of names. A character vector marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)
  is treated as if it was provided via the `id` argument.

- id:

  Character vector of shared drive ids or URLs (it is first processed
  with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)).
  If both `name` and `id` are non-`NULL`, `id` is silently ignored.

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per shared drive.

## Examples

``` r
if (FALSE) { # \dontrun{
shared_drive_get("my-awesome-shared-drive")
shared_drive_get(c("apple", "orange", "banana"))
shared_drive_get(as_id("KCmiHLXUk9PVA-0AJNG"))
shared_drive_get(as_id("https://drive.google.com/drive/u/0/folders/KCmiHLXUk9PVA-0AJNG"))
shared_drive_get(id = "KCmiHLXUk9PVA-0AJNG")
shared_drive_get(id = "https://drive.google.com/drive/u/0/folders/KCmiHLXUk9PVA-0AJNG")
} # }
```
