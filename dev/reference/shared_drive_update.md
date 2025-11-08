# Update a shared drive

Update the metadata of an existing shared drive, e.g. its background
image or theme.

A shared drive supports files owned by an organization rather than an
individual user. Shared drives follow different sharing and ownership
models from a specific user's "My Drive". Shared drives are the
successors to the earlier concept of Team Drives. Learn more about
[shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

## Usage

``` r
shared_drive_update(shared_drive, ...)
```

## Arguments

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

- ...:

  Properties to set in `name = value` form. See the "Request body"
  section of the Drive API docs for this endpoint.

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per shared drive.

## See also

Wraps the `drives.update` endpoint:

- <https://developers.google.com/drive/api/v3/reference/drives/update>

## Examples

``` r
if (FALSE) { # \dontrun{
# create a shared drive
sd <- shared_drive_create("I love themes!")

# see the themes available to you
themes <- drive_about()$driveThemes
purrr::map_chr(themes, "id")

# cycle through various themes for this shared drive
sd <- shared_drive_update(sd, themeId = "bok_choy")
sd <- shared_drive_update(sd, themeId = "cocktails")

# Clean up
shared_drive_rm(sd)
} # }
```
