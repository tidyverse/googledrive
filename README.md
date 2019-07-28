
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

Please see the package website: <https://googledrive.tidyverse.org>

Here’s a teaser that uses googledrive to view some of the files you see
on <https://drive.google.com> (up to `n_max = 25`, in this case):

``` r
library("googledrive")
drive_find(n_max = 25)
#> # A tibble: 14 x 3
#>    name                    id                              drive_resource  
#>  * <chr>                   <chr>                           <list>          
#>  1 chicken-perm-article.t… 1oWpfPYR-77c-DdvoW30682F9Gde8Z… <named list [39…
#>  2 googledrive-NEWS.md     15pfwRfXvpxekxhdERmSUnoxQY5K70… <named list [38…
#>  3 def                     1hr4EFw3r5vAMm5Jgw2SsFluBpN-oA… <named list [32…
#>  4 abc                     11lidFPceZAcNTHasQARiwAhE0NgmS… <named list [32…
#>  5 THANKS                  1zNZpVO4MCjNUFUHOwSv3WlyUh4Dq_… <named list [39…
#>  6 BioC_mirrors.csv        1vV0fPdNOyo3Ti9ofA38MuTQm27pXv… <named list [38…
#>  7 logo.jpg                1OFeNdd63NfoavqvDf5-xa3LORiamf… <named list [40…
#>  8 Rlogo.svg               11sxsw-ux-UjQjzVdxd1wjNz37hJeB… <named list [40…
#>  9 Rlogo.pdf               1cn7oVxQRgD0l_hCI4nrSSWrKeVFys… <named list [39…
#> 10 DESCRIPTION             1MjV4stVPhlMNz1AcrIizcL7yTcVaR… <named list [39…
#> 11 chicken.txt             1xmwFZ_UN-CSs3Ic2aPUw22DbxZxoe… <named list [39…
#> 12 chicken.pdf             1eK9ozP1TZjXfAgaAGmP9GrUTovGUa… <named list [39…
#> 13 chicken.jpg             1JnGjIdruQXErd20xR_ecAzN3yP_fT… <named list [40…
#> 14 chicken.csv             1eHoOi9Ch3zk3_QBRKCJajFEIO4aeG… <named list [38…
```

## Contributing

If you’d like to contribute to the development of googledrive, please
read [these
guidelines](https://googledrive.tidyverse.org/CONTRIBUTING.md).

Please note that the googledrive project is released with a
\[Contributor Code of
Conduct\]<https://googledrive.tidyverse.org/CODE_OF_CONDUCT.html>). By
contributing to this project, you agree to abide by its terms.

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
