
<!-- README.md is generated from README.Rmd. Please edit that file -->
googledrive
===========

[![Build Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)[![Coverage Status](https://img.shields.io/codecov/c/github/tidyverse/googledrive/master.svg)](https://codecov.io/github/tidyverse/googledrive?branch=master)

WARNING: this is under very active development

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

Here's a teaser that uses googledrive to list the files you see on <https://drive.google.com>:

``` r
library("googledrive")
drive_list()
#> # A tibble: 52 x 3
#>                                name                           id
#>  *                            <chr>                        <chr>
#>  1                              abc 0B0Gh-SuuA2nTdE1MaG1rOWpkR28
#>  2 upload-into-me-TEST-drive-upload 0B0Gh-SuuA2nTaDJNckJJWXA5Rms
#>  3        i-am-a-file-TEST-drive-cp 0B0Gh-SuuA2nTVmJNcUt6QlJBVUE
#>  4      i-am-a-folder-TEST-drive-cp 0B0Gh-SuuA2nTczF5SlBSLUpQNE0
#>  5 move-files-into-me-TEST-drive-mv 0B0Gh-SuuA2nTZUliMFJMYjRDbXc
#>  6            list-me-TEST-drive-ls 0B0Gh-SuuA2nTSkk5R2M5cDhKUW8
#>  7                baz-TEST-drive-mv 0B0Gh-SuuA2nTUVJzU2ZzSUMtUkU
#>  8                foo-TEST-drive-mv 0B0Gh-SuuA2nTNUhHSjRTWmpWME0
#>  9     OMNI-PARENT-TEST-drive-mkdir 0B0Gh-SuuA2nTZlA0aWtMczVkMmM
#> 10                         test1234 0B0Gh-SuuA2nTXzVmSjRTS2JkUGM
#> # ... with 42 more rows, and 1 more variables: files_resource <list>
```
