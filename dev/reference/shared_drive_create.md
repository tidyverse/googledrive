# Create a new shared drive

A shared drive supports files owned by an organization rather than an
individual user. Shared drives follow different sharing and ownership
models from a specific user's "My Drive". Shared drives are the
successors to the earlier concept of Team Drives. Learn more about
[shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

## Usage

``` r
shared_drive_create(name)
```

## Arguments

- name:

  Character. Name of the new shared drive. Must be non-empty and not
  entirely whitespace.

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per shared drive.

## See also

Wraps the `drives.create` endpoint:

- <https://developers.google.com/drive/api/v3/reference/drives/create>

## Examples

``` r
if (FALSE) { # \dontrun{
shared_drive_create("my-awesome-shared-drive")

# Clean up
shared_drive_rm("my-awesome-shared-drive")
} # }
```
