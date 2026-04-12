# googledrive configuration

Some aspects of googledrive behaviour can be controlled via an option.

## Usage

``` r
local_drive_quiet(env = parent.frame())

with_drive_quiet(code)
```

## Arguments

- env:

  The environment to use for scoping

- code:

  Code to execute quietly

## Auth

Read about googledrive's main auth function,
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md).
It is powered by the gargle package, which consults several options:

- Default Google user or, more precisely, `email`: see
  [`gargle::gargle_oauth_email()`](https://gargle.r-lib.org/reference/gargle_options.html)

- Whether or where to cache OAuth tokens: see
  [`gargle::gargle_oauth_cache()`](https://gargle.r-lib.org/reference/gargle_options.html)

- Whether to prefer "out-of-band" auth: see
  [`gargle::gargle_oob_default()`](https://gargle.r-lib.org/reference/gargle_options.html)

- Application Default Credentials: see
  [`gargle::credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.html)

## Messages

The `googledrive_quiet` option can be used to suppress messages from
googledrive. By default, googledrive always messages, i.e. it is *not*
quiet.

Set `googledrive_quiet` to `TRUE` to suppress messages, by one of these
means, in order of decreasing scope:

- Put `options(googledrive_quiet = TRUE)` in a start-up file, such as
  `.Rprofile`, or at the top of your R script

- Use `local_drive_quiet()` to silence googledrive in a specific scope

      foo <- function() {
        ...
        local_drive_quiet()
        drive_this(...)
        drive_that(...)
        ...
      }

- Use `with_drive_quiet()` to run a small bit of code silently

      with_drive_quiet(
        drive_something(...)
      )

`local_drive_quiet()` and `with_drive_quiet()` follow the conventions of
the the withr package (<https://withr.r-lib.org>).

## Examples

``` r
# message: "Created Drive file"
(x <- drive_create("drive-quiet-demo", type = "document"))
#> Created Drive file:
#> • drive-quiet-demo <id: 1Fh0wZdWPccKi-R0ABPqxsWC1Ff-bivjg0OVfOmv2ci4>
#> With MIME type:
#> • application/vnd.google-apps.document
#> # A dribble: 1 × 3
#>   name             id       drive_resource   
#>   <chr>            <drv_id> <list>           
#> 1 drive-quiet-demo 1Fh0wZd… <named list [37]>

# message: "File updated"
x <- drive_update(x, starred = TRUE)
#> File updated:
#> • drive-quiet-demo <id: 1Fh0wZdWPccKi-R0ABPqxsWC1Ff-bivjg0OVfOmv2ci4>
drive_reveal(x, "starred")
#> # A dribble: 1 × 4
#>   name             starred id       drive_resource   
#>   <chr>            <lgl>   <drv_id> <list>           
#> 1 drive-quiet-demo TRUE    1Fh0wZd… <named list [38]>

# suppress messages for a small amount of code
with_drive_quiet(
  x <- drive_update(x, name = "drive-quiet-works")
)
x$name
#> [1] "drive-quiet-works"

# message: "File updated"
x <- drive_update(x, media = drive_example_local("chicken.txt"))
#> File updated:
#> • drive-quiet-works <id: 1Fh0wZdWPccKi-R0ABPqxsWC1Ff-bivjg0OVfOmv2ci4>

# suppress messages within a specific scope, e.g. function
unstar <- function(y) {
  local_drive_quiet()
  drive_update(y, starred = FALSE)
}
x <- unstar(x)
drive_reveal(x, "starred")
#> # A dribble: 1 × 4
#>   name              starred id       drive_resource   
#>   <chr>             <lgl>   <drv_id> <list>           
#> 1 drive-quiet-works FALSE   1Fh0wZd… <named list [38]>

# Clean up
drive_rm(x)
#> File deleted:
#> • drive-quiet-works <id: 1Fh0wZdWPccKi-R0ABPqxsWC1Ff-bivjg0OVfOmv2ci4>
```
