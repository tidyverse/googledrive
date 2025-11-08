# Coerce to shared drive

Converts various representations of a shared drive into a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
the object used by googledrive to hold Drive file metadata. Shared
drives can be specified via

- Name

- Shared drive id, marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)
  to distinguish from name

- Data frame or
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
  consisting solely of shared drives

- List representing [Drives
  resource](https://developers.google.com/drive/api/v3/reference/drives#resource-representations)
  objects (mostly for internal use)

A shared drive supports files owned by an organization rather than an
individual user. Shared drives follow different sharing and ownership
models from a specific user's "My Drive". Shared drives are the
successors to the earlier concept of Team Drives. Learn more about
[shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

This is a generic function.

## Usage

``` r
as_shared_drive(x, ...)
```

## Arguments

- x:

  A vector of shared drive names, a vector of shared drive ids marked
  with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  a list of Drives resource objects, or a suitable data frame.

- ...:

  Other arguments passed down to methods. (Not used.)

## Examples

``` r
if (FALSE) { # \dontrun{
# specify the name
as_shared_drive("abc")

# specify the id (substitute one of your own!)
as_shared_drive(as_id("0AOPK1X2jaNckUk9PVA"))
} # }
```
