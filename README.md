
<!-- README.md is generated from README.Rmd. Please edit that file -->
googledrive
===========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/googledrive)](https://cran.r-project.org/package=googledrive) [![Build Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)[![codecov](https://codecov.io/gh/tidyverse/googledrive/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/googledrive?branch=master)

Overview
--------

googledrive allows you to interact with files on Google Drive from R.

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

Here's a teaser that uses googledrive to view some of the files you see on <https://drive.google.com>:

``` r
library("googledrive")
drive_find(n_max = 25)
#> Auto-refreshing stale OAuth token.
#> # A tibble: 25 x 3
#>                            name
#>  *                        <chr>
#>  1               chicken-rm.txt
#>  2                  chicken.jpg
#>  3           README-mirrors.csv
#>  4           README-mirrors.csv
#>  5                          def
#>  6                          abc
#>  7               folder1-level4
#>  8               folder1-level3
#>  9      cranberry-TEST-drive-ls
#> 10 folder1-level2-TEST-drive-ls
#> # ... with 15 more rows, and 2 more variables: id <chr>,
#> #   drive_resource <list>
```

Contributing
------------

If you'd like to contribute to the development of googledrive, please read [these guidelines](CONTRIBUTING.md).
