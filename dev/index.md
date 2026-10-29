# googledrive

## Overview

googledrive allows you to interact with files on Google Drive from R.

## Installation

Install the CRAN version:

``` r

install.packages("googledrive")
```

Or install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("tidyverse/googledrive")
```

## Usage

Here’s a teaser that uses googledrive to view some of the files you see
on <https://drive.google.com> (up to `n_max = 25`, in this case):

``` r

library("googledrive")
drive_find(n_max = 25)
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
```

## Where to learn more

[Get
started](https://googledrive.tidyverse.org/articles/googledrive.html) is
a more extensive general introduction to googledrive.

Browse the [articles
index](https://googledrive.tidyverse.org/articles/index.html) to find
articles that cover various topics in more depth.

See the [function
index](https://googledrive.tidyverse.org/reference/index.html) for an
organized, exhaustive listing.

## Contributing

If you’d like to contribute to the development of googledrive, please
read [these
guidelines](https://googledrive.tidyverse.org/CONTRIBUTING.html).

Please note that the googledrive project is released with a [Contributor
Code of
Conduct](https://googledrive.tidyverse.org/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## Privacy

[Privacy policy](https://tidyverse.org/google_privacy_policy/)
