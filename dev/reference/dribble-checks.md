# Check facts about a dribble

Sometimes you need to check things about a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)\`
or about the files it represents, such as:

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

confirm_dribble(d)

confirm_single_file(d)

confirm_some_files(d)

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

  A
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

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
#> # A dribble: 31 × 3
#>    name                       id       drive_resource   
#>    <chr>                      <drv_id> <list>           
#>  1 bravo                      11RgjTH… <named list [40]>
#>  2 chicken_poem.txt           1lAxO_z… <named list [44]>
#>  3 2021-09-16_r_logo.jpg      1dandXB… <named list [45]>
#>  4 2021-09-16_r_about.html    1XfCI_o… <named list [44]>
#>  5 2021-09-16_imdb_latin1.csv 163YPvq… <named list [43]>
#>  6 2021-09-16_chicken.txt     1axJz8G… <named list [44]>
#>  7 2021-09-16_chicken.pdf     14Hd6_V… <named list [44]>
#>  8 2021-09-16_chicken.jpg     1aslW1T… <named list [45]>
#>  9 2021-09-16_chicken.csv     1Mj--zJ… <named list [43]>
#> 10 pqr                        143iq-C… <named list [36]>
#> # ℹ 21 more rows
is_folder(d)
#>  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE  TRUE
#> [12]  TRUE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE  TRUE FALSE
#> [23] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
is_mine(d)
#>  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#> [14] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#> [27] TRUE TRUE TRUE TRUE TRUE
```
