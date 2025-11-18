# `drive_id` class

`drive_id` is an S3 class to mark strings as Drive file ids, in order to
distinguish them from Drive file names or paths. `as_id()` converts
various inputs into an instance of `drive_id`.

`as_id()` is a generic function.

## Usage

``` r
as_id(x, ...)
```

## Arguments

- x:

  A character vector of file or shared drive ids or URLs, a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
  or a suitable data frame.

- ...:

  Other arguments passed down to methods. (Not used.)

## Value

A character vector bearing the S3 class `drive_id`.

## Examples

``` r
as_id("123abc")
#> <drive_id[1]>
#> [1] 123abc
as_id("https://docs.google.com/spreadsheets/d/qawsedrf16273849/edit#gid=12345")
#> <drive_id[1]>
#> [1] qawsedrf16273849

x <- drive_find(n_max = 3)
as_id(x)
#> <drive_id[3]>
#> [1] 114mdtQYKQyVwZtBT3Xi619gMOajDicij 1lAxO_zr06v6pL6dyQJ9duwH1j2ztQ3lB
#> [3] 1dandXB0QZpjeGQq_56wTXKNwaqgsOa9D
```
