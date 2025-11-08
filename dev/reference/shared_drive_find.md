# Find shared drives

This is the closest googledrive function to what you get from visiting
<https://drive.google.com> and clicking "Shared drives".

A shared drive supports files owned by an organization rather than an
individual user. Shared drives follow different sharing and ownership
models from a specific user's "My Drive". Shared drives are the
successors to the earlier concept of Team Drives. Learn more about
[shared
drives](https://googledrive.tidyverse.org/dev/reference/shared_drives.md).

## Usage

``` r
shared_drive_find(pattern = NULL, n_max = Inf, ...)
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

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per shared drive.

## See also

Wraps the `drives.list` endpoint:

- <https://developers.google.com/drive/api/v3/reference/drives/list>

## Examples

``` r
if (FALSE) { # \dontrun{
shared_drive_find()
} # }
```
