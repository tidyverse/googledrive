
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googledrive <img src="man/figures/logo.png" align="right" height=140/>

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
#>  1 Lotus 1-2-3 1WaRXQYmqqc0Y_dwGHK1BNUITYJMidsxhk2hyRi2Ip5c <named list [36]>
#>  2 SuperCalc   1eHOkbsxBEo6MeH2iL6NhOsx7KSmp03AS99BRXNe5JNo <named list [36]>
#>  3 ExecuVision 1yJOdIFYEngyu-ou3xrUn4HgvluRXvmEtRvEUGglQg0Y <named list [37]>
#>  4 WordStar    1BArmW-ClrWz-VEH5Wk1dy21VmxdJ7mUkVboCUFKi2lM <named list [36]>
#>  5 Lotus 1-2-3 1TzUNjVyNeknJEJMAV-j_gxXUU160wDU0D7J0Efm15ro <named list [36]>
#>  6 SuperCalc   19lruwoovxQgRyeDpryhqBRtC9ijKxlZO_uSqCDirw1M <named list [36]>
#>  7 ExecuVision 1m31QKg2maTqEvdNOLx1zJOxltW4eXTa7QDLhRVhiEGY <named list [37]>
#>  8 WordStar    1jhPZkMKHugCSyTJEaBHrK7ikeiZ_xmHCGMZw9LeTfaw <named list [36]>
#>  9 Lotus 1-2-3 1sCG9aDVppEAAOcIFSH31307_7Xrz7Kz0ksOmeTTF8p0 <named list [36]>
#> 10 SuperCalc   1BSVeaMP9TURi43rGLZy_BOKtFu-3OL7mmoD-DjbaU1Q <named list [36]>
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
