
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
drive_ls()
#> # A tibble: 88 x 3
#>                                name
#>  *                            <chr>
#>  1      update-me-TEST-drive-update
#>  2 upload-into-me-TEST-drive-upload
#>  3     not-unique-TEST-drive-update
#>  4     not-unique-TEST-drive-update
#>  5             foo-TEST-drive-trash
#>  6            DESC-TEST-drive-share
#>  7       foo_pdf-TEST-drive-publish
#>  8     foo_sheet-TEST-drive-publish
#>  9       foo_doc-TEST-drive-publish
#> 10 move-files-into-me-TEST-drive-mv
#> # ... with 78 more rows, and 2 more variables: id <chr>,
#> #   files_resource <list>
```

Contributing
------------

If you'd like to contribute to the development of googledrive, please read [these guidelines](CONTRIBUTING.md).
