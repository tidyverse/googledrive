# dribble object

googledrive stores the metadata for one or more Drive files or shared
drives as a `dribble`. It is a "Drive
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html)"
with one row per file or shared drive and, at a minimum, these columns:

- `name`: a character column containing file or shared drive names

- `id`: a character column of file or shared drive ids

- `drive_resource`: a list-column, each element of which is either a
  [Files
  resource](https://developers.google.com/drive/api/v3/reference/files#resource-representations)
  or a [Drives
  resource](https://developers.google.com/drive/api/v3/reference/drives#resource-representations)
  object. Note there is no guarantee that all documented fields are
  always present. We do check if the `kind` field is present and equal
  to one of `drive#file` or `drive#drive`.

The `dribble` format is handy because it exposes the file name, which is
good for humans, but keeps it bundled with the file's unique id and
other metadata, which are needed for API calls.

In general, the `dribble` class will be retained even after
manipulation, as long as the required variables are present and of the
correct type. This works best for manipulations via the dplyr and vctrs
packages.

## See also

[`as_dribble()`](https://googledrive.tidyverse.org/dev/reference/as_dribble.md)
