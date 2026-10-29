# Is there a token on hand?

Reports whether googledrive has stored a token, ready for use in
downstream requests.

## Usage

``` r
drive_has_token()
```

## Value

Logical.

## See also

Other low-level API functions:
[`drive_token()`](https://googledrive.tidyverse.org/reference/drive_token.md),
[`request_generate()`](https://googledrive.tidyverse.org/reference/request_generate.md),
[`request_make()`](https://googledrive.tidyverse.org/reference/request_make.md)

## Examples

``` r
drive_has_token()
#> [1] TRUE
```
