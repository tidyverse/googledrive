
<!-- README.md is generated from README.Rmd. Please edit that file -->
googledrive
===========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/googledrive)](https://cran.r-project.org/package=googledrive) [![Build Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)[![codecov](https://codecov.io/gh/tidyverse/googledrive/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/googledrive?branch=master)

Overview
--------

`googledrive` interfaces with Google Drive from R, allowing users to seamlessly manage files on Google Drive from the comfort of their console.

Installation
------------

``` r
# Obtain the the development version from GitHub:
# install.packages("devtools")
devtools::install_github("tidyverse/googledrive")
```

Usage
-----

Please see the package website: <https://tidyverse.github.io/googledrive/>

Here's a teaser that uses googledrive to view the files you see on <https://drive.google.com>:

``` r
library("googledrive")
drive_find()
#> Items so far:
#> 121
#> 
#> # A tibble: 121 x 3
#>                                    name
#>  *                                <chr>
#>  1                                  def
#>  2                                  abc
#>  3                          DESCRIPTION
#>  4                     BioC_mirrors.csv
#>  5                                 NEWS
#>  6                               NEWS.0
#>  7                               NEWS.1
#>  8 upload-into-me-too-TEST-drive-upload
#>  9                          DESCRIPTION
#> 10                              folder1
#> # ... with 111 more rows, and 2 more variables: id <chr>,
#> #   drive_resource <list>
```

Contributing
------------

If you'd like to contribute to the development of googledrive, please read [these guidelines](CONTRIBUTING.md).
