
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googledrive <img src="man/figures/logo.png" align="right" height=140/>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/googledrive)](https://cran.r-project.org/package=googledrive)
[![Build
Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)[![AppVeyor
Build
Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)[![codecov](https://codecov.io/gh/tidyverse/googledrive/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/googledrive?branch=master)

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

Please see the package website:
<https://tidyverse.github.io/googledrive/>

Here’s a teaser that uses googledrive to view some of the files you see
on <https://drive.google.com>:

``` r
library("googledrive")
drive_find(n_max = 25)
#> Auto-refreshing stale OAuth token.
#> # A tibble: 25 x 3
#>    name                 id                                  drive_resource
#>  * <chr>                <chr>                               <list>        
#>  1 chicken-xyz.csv      0B0Gh-SuuA2nTVUZGclZiSzZ0bkE        <list [38]>   
#>  2 chicken-rm.txt       0B0Gh-SuuA2nTT3dBbXd1ZWtvSkE        <list [39]>   
#>  3 chicken.jpg          0B0Gh-SuuA2nTbEhtYnIzcFNfX3M        <list [41]>   
#>  4 README-mirrors.csv   1LJlt-1emr662GV8WdEzddzsfqrt-VgQeZ… <list [34]>   
#>  5 README-mirrors.csv   1PLXfempSnjpXbKVEXwMG5vBEnd-FwmC26… <list [34]>   
#>  6 def                  0B0Gh-SuuA2nTRG5YWFVGaV8zbU0        <list [32]>   
#>  7 abc                  0B0Gh-SuuA2nTT2NqTGdLVWFkcjA        <list [32]>   
#>  8 folder1-level4       0B0Gh-SuuA2nTaTR6elE0TjZUUHM        <list [33]>   
#>  9 folder1-level3       0B0Gh-SuuA2nTWktWeTB0ajVoQjQ        <list [33]>   
#> 10 cranberry-TEST-driv… 1PM--xCb5axy5Uu9f6fDNjPAN2psRbQ2_U… <list [33]>   
#> # … with 15 more rows
```

## Contributing

If you’d like to contribute to the development of googledrive, please
read [these guidelines](.github/CONTRIBUTING.md).

Please note that the googledrive project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.
