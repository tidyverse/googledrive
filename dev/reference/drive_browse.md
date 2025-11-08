# Visit Drive file in browser

Visits a file on Google Drive in your default browser.

## Usage

``` r
drive_browse(file = .Last.value)
```

## Arguments

- file:

  Something that identifies the file of interest on your Google Drive.
  Can be a name or path, a file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

## Value

Character vector of file hyperlinks, from
[`drive_link()`](https://googledrive.tidyverse.org/dev/reference/drive_link.md),
invisibly.

## Examples

``` r
if (FALSE) { # drive_has_token() && rlang::is_interactive()
drive_find(n_max = 1) |> drive_browse()
}
```
