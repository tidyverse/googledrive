# Share Drive files

Grant individuals or other groups access to files, including permission
to read, comment, or edit. The returned
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
will have extra columns, `shared` and `permissions_resource`. Read more
in
[`drive_reveal()`](https://googledrive.tidyverse.org/dev/reference/drive_reveal.md).

`drive_share_anyone()` is a convenience wrapper for a common special
case: "make this `file` readable by 'anyone with a link'".

## Usage

``` r
drive_share(
  file,
  role = c("reader", "commenter", "writer", "fileOrganizer", "owner", "organizer"),
  type = c("user", "group", "domain", "anyone"),
  ...,
  verbose = deprecated()
)

drive_share_anyone(file, verbose = deprecated())
```

## Arguments

- file:

  Something that identifies the file(s) of interest on your Google
  Drive. Can be a character vector of names/paths, a character vector of
  file ids or URLs marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- role:

  Character. The role to grant. Must be one of:

  - owner (not allowed in shared drives)

  - organizer (applies to shared drives)

  - fileOrganizer (applies to shared drives)

  - writer

  - commenter

  - reader

- type:

  Character. Describes the grantee. Must be one of:

  - user

  - group

  - domain

  - anyone

- ...:

  Name-value pairs to add to the API request. This is where you provide
  additional information, such as the `emailAddress` (when grantee
  `type` is `"group"` or `"user"`) or the `domain` (when grantee type is
  `"domain"`). Read the API docs linked below for more details.

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
a tibble with one row per file. There will be extra columns, `shared`
and `permissions_resource`.

## See also

Wraps the `permissions.create` endpoint:

- <https://developers.google.com/drive/api/v3/reference/permissions/create>

Drive roles and permissions are described here:

- <https://developers.google.com/drive/api/v3/ref-roles>

## Examples

``` r
# Create a file to share
file <- drive_example_remote("chicken_doc") |>
  drive_cp(name = "chicken-share.txt")
#> Original file:
#> • chicken_doc <id: 1X9pd4nOjl33zDFfTjw-_eFL7Qb9_g6VfVFDp1PPae94>
#> Copied to file:
#> • chicken-share.txt <id: 1GfbWiz-55xDF_3aUjETFds5x92KVNJM1ynwTSVQLtek>

# Let a specific person comment
file <- file |>
  drive_share(
    role = "commenter",
    type = "user",
    emailAddress = "susan@example.com"
  )
#> Permissions updated:
#> • role = commenter
#> • type = user
#> For file:
#> • chicken-share.txt <id: 1GfbWiz-55xDF_3aUjETFds5x92KVNJM1ynwTSVQLtek>

# Let a different specific person edit and customize the email notification
file <- file |>
  drive_share(
    role = "writer",
    type = "user",
    emailAddress = "carol@example.com",
    emailMessage = "Would appreciate your feedback on this!"
  )
#> Permissions updated:
#> • role = writer
#> • type = user
#> For file:
#> • chicken-share.txt <id: 1GfbWiz-55xDF_3aUjETFds5x92KVNJM1ynwTSVQLtek>

# Let anyone read the file
file <- file |>
  drive_share(role = "reader", type = "anyone")
#> Permissions updated:
#> • role = reader
#> • type = anyone
#> For file:
#> • chicken-share.txt <id: 1GfbWiz-55xDF_3aUjETFds5x92KVNJM1ynwTSVQLtek>
# Single-purpose wrapper function for this
drive_share_anyone(file)
#> Permissions updated:
#> • role = reader
#> • type = anyone
#> For file:
#> • chicken-share.txt <id: 1GfbWiz-55xDF_3aUjETFds5x92KVNJM1ynwTSVQLtek>

# Clean up
drive_rm(file)
#> File deleted:
#> • chicken-share.txt <id: 1GfbWiz-55xDF_3aUjETFds5x92KVNJM1ynwTSVQLtek>
```
