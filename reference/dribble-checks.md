# Check facts about a dribble

Sometimes you need to check things about a
[`dribble`](https://googledrive.tidyverse.org/reference/dribble.md)\` or
about the files it represents, such as:

- Is it even a dribble?

- Size: Does the dribble hold exactly one file? At least one file? No
  file?

- File type: Is this file a folder?

- File ownership and access: Is it mine? Published? Shared?

## Usage

``` r
is_dribble(d)

no_file(d)

single_file(d)

some_files(d)

confirm_dribble(d, arg = caller_arg(d), call = caller_env())

confirm_single_file(d, arg = caller_arg(d), call = caller_env())

confirm_some_files(d, arg = caller_arg(d), call = caller_env())

is_folder(d)

is_shortcut(d)

is_folder_shortcut(d)

is_native(d)

is_parental(d)

is_mine(d)

is_shared_drive(d)
```

## Arguments

- d:

  A [`dribble`](https://googledrive.tidyverse.org/reference/dribble.md).

- arg:

  An argument name as a string. This argument will be mentioned in error
  messages as the input that is at the origin of a problem.

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Examples

``` r
## most of us have multiple files or folders on Google Drive
d <- drive_find()
is_dribble(d)
#> [1] TRUE
no_file(d)
#> [1] FALSE
single_file(d)
#> [1] FALSE
some_files(d)
#> [1] TRUE

# this will error
# confirm_single_file(d)

confirm_some_files(d)
#> # A dribble: 16 × 3
#>    name                id       drive_resource   
#>    <chr>               <drv_id> <list>           
#>  1 chicken_sheet       1s0kEHc… <named list [38]>
#>  2 r_logo.jpg          1wFAZdm… <named list [46]>
#>  3 THANKS              19URV7B… <named list [45]>
#>  4 googledrive-NEWS.md 1h1lhFf… <named list [44]>
#>  5 def                 1ALSW_N… <named list [36]>
#>  6 abc                 1o89YN5… <named list [36]>
#>  7 BioC_mirrors.csv    13tMFbh… <named list [44]>
#>  8 Rlogo.svg           1lCQGxj… <named list [46]>
#>  9 DESCRIPTION         1KKYhtc… <named list [45]>
#> 10 r_about.html        1mHtQhv… <named list [45]>
#> 11 imdb_latin1.csv     1S5HxY7… <named list [44]>
#> 12 chicken.txt         1xMvlJH… <named list [45]>
#> 13 chicken.pdf         1au0aK6… <named list [45]>
#> 14 chicken.jpg         1-BF1c4… <named list [46]>
#> 15 chicken.csv         12212CX… <named list [44]>
#> 16 chicken_doc         11GY4Q4… <named list [38]>
is_folder(d)
#>  [1] FALSE FALSE FALSE FALSE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
#> [12] FALSE FALSE FALSE FALSE FALSE
is_mine(d)
#>  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#> [14] TRUE TRUE TRUE
```
