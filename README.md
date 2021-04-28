
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
#> # A tibble: 12 x 3
#>    name                id                                drive_resource   
#>  * <chr>               <chr>                             <list>           
#>  1 Rlogo.pdf           1opPZyo4WUiue56qlF8SO5ipaTJwPLzZg <named list [39]>
#>  2 THANKS              1JCQ06Wj6AjntiyjnHsXmmcHZWCkBNgBJ <named list [39]>
#>  3 googledrive-NEWS.md 1wMnFwFSIG0eQ4UUUEbn6-udF3GoKY3xN <named list [38]>
#>  4 def                 12xjsE3eIf84VSFF5hNhSEOnQF8DDSHkc <named list [32]>
#>  5 abc                 1qkS667DEnvDzTuVBSyj5NeGzIGbrAy9Q <named list [32]>
#>  6 BioC_mirrors.csv    1f-Ua7sUZq1g5YycA1mXwlVRrYn1lN15o <named list [38]>
#>  7 logo.jpg            1yhwnYA0TfXZ5lykclxIPyjvSBLL3h_Y0 <named list [40]>
#>  8 Rlogo.svg           1vhSTljYBXwOqILwgZ8hC3XKzVC98I5x3 <named list [40]>
#>  9 DESCRIPTION         1U4iwGpIa1SVPuiki3bs2fS-EltIvL3JD <named list [39]>
#> 10 chicken.txt         1af6w2ZU-JjwI7jrKW1OGiiRbM2GMTbil <named list [39]>
#> 11 chicken.pdf         1nL7iro5YQLt1d77acGiHoawmPTWonh6p <named list [39]>
#> 12 chicken.jpg         1QQhNDl_f2W-UxacIfCBaftUopfqi1Tw1 <named list [40]>
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
