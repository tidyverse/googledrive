
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googledrive <img src="man/figures/logo.png" align="right" height=140/>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/googledrive)](https://CRAN.R-project.org/package=googledrive)
[![R-CMD-check](https://github.com/tidyverse/googledrive/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/googledrive/actions)
[![Codecov test
coverage](https://codecov.io/gh/tidyverse/googledrive/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/googledrive?branch=master)
<!-- badges: end -->

## Overview

googledrive allows you to interact with files on Google Drive from R.

## Installation

Install the CRAN version:

``` r
install.packages("googledrive")
```

Or install the development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("tidyverse/googledrive")
```

## Usage

Please see the package website: <https://googledrive.tidyverse.org>

Here’s a teaser that uses googledrive to view some of the files you see
on <https://drive.google.com> (up to `n_max = 25`, in this case):

``` r
library("googledrive")
drive_find(n_max = 25)
#> # A dribble: 16 x 3
#>    name               id                                        drive_resource  
#>    <chr>              <drv_id>                                  <list>          
#>  1 chicken_sheet      1s0kEHcqG2PyciERoGq52L_Qwzp4y3__rBVKSx7E… <named list [35…
#>  2 r_logo.jpg         1wFAZdmBiSRu4GShsqurxD7wIDSCZvPud         <named list [41…
#>  3 THANKS             19URV7BT0_E1KhYdfDODszK5aiELOwTSz         <named list [40…
#>  4 googledrive-NEWS.… 1h1lhFfQrDZevE2OEX10-rbi2BfvGogFm         <named list [39…
#>  5 def                1ALSW_Nqs7FsPOcrJ6MqyBoRm03gansmn         <named list [33…
#>  6 abc                1o89YN5n4325GbUA86Wp6pRH3dsTsE5iC         <named list [33…
#>  7 BioC_mirrors.csv   13tMFbhAHoeHLFS5xu19GbDjf6GWJSxyN         <named list [39…
#>  8 Rlogo.svg          1lCQGxjyoc9mQz719I8sKil_m2Nuhw0Fq         <named list [41…
#>  9 DESCRIPTION        1KKYhtcdJMKh4WYeri5TOPEeAtzdN_cqV         <named list [40…
#> 10 r_about.html       1mHtQhvJyDk5dX9ktKbeIoVW-wwWK0__N         <named list [40…
#> 11 imdb_latin1.csv    1S5HxY7a-Jb_fV4C3T6fkGyPpXfI_yb4w         <named list [39…
#> 12 chicken.txt        1xMvlJHia_qYNZmucaStDcOF9A9PD4BOT         <named list [40…
#> 13 chicken.pdf        1au0aK6YCTra2sucTRus8ZaUhbaLpinTn         <named list [40…
#> 14 chicken.jpg        1-BF1c4kWCkkByQbcLT-b2Hv6vnVsbqa_         <named list [41…
#> 15 chicken.csv        12212CXY_TopUMIKYu_l8hU5UXI8lrzQF         <named list [39…
#> 16 chicken_doc        11GY4Q4BUG3m5U4CnZP564lYvGydvZe2XZOkwCfx… <named list [35…
```

## Contributing

If you’d like to contribute to the development of googledrive, please
read [these
guidelines](https://googledrive.tidyverse.org/CONTRIBUTING.html).

Please note that the googledrive project is released with a [Contributor
Code of
Conduct](https://googledrive.tidyverse.org/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
