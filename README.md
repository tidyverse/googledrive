
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googledrive <a href="https://googledrive.tidyverse.org"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/googledrive)](https://CRAN.R-project.org/package=googledrive)
[![R-CMD-check](https://github.com/tidyverse/googledrive/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tidyverse/googledrive/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/tidyverse/googledrive/branch/main/graph/badge.svg)](https://app.codecov.io/gh/tidyverse/googledrive?branch=main)
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
#> # A dribble: 25 × 3
#>    name        id                                           drive_resource   
#>    <chr>       <drv_id>                                     <list>           
#>  1 Lotus 1-2-3 1SQF6dCJqp-SKtlJL1V7I85Dmi8FiN41Tc_n4ZChFdjw <named list [36]>
#>  2 SuperCalc   1UjS64lUYg6hNaSsRJ36pU1edKSwLrPAykrJCZOoRDqM <named list [36]>
#>  3 ExecuVision 1trDZHrDR7_340KL2HZw3iW66OaS5Uq9iwmW_fdlFBIk <named list [37]>
#>  4 WordStar    1sPYkLduB-N6i_8Ql8rQZpEDfPODRv32wPgwAKZAQyBQ <named list [36]>
#>  5 Lotus 1-2-3 10VK-34k0yOzxfTQIW1M6nBeq_IOpbyqtEHJLNWusKBo <named list [36]>
#>  6 SuperCalc   1gReZE8dQGxxL-IkI94fP7q7xpoc5NpVeIyI1dxhtlrw <named list [36]>
#>  7 ExecuVision 1zUu6BtAgRr06iUd0liZ82COEQBZR3YxKw2NiP9uBA3A <named list [37]>
#>  8 WordStar    1jjj5IGt2kkSAHd1mFYHqPNemnxkNr96g2QEfUQCcgI8 <named list [36]>
#>  9 Lotus 1-2-3 1-VN4iZ1-gCDPMCFgqg0RxcW8GvD8hgoQNjtFSIBYUUc <named list [36]>
#> 10 SuperCalc   1ZXmNZxlxjtuUlmFF0fdImeFoeIw65d7Cz9gYnm4Trz8 <named list [36]>
#> # … with 15 more rows
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
