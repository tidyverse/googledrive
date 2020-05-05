
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googledrive <img src="man/figures/logo.png" align="right" height=140/>

<!-- badges: start -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/googledrive)](https://cran.r-project.org/package=googledrive)
[![R build
status](https://github.com/tidyverse/googledrive/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/googledrive/actions)
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
#> # A tibble: 14 x 3
#>    name                     id                                drive_resource   
#>  * <chr>                    <chr>                             <list>           
#>  1 Rlogo.pdf                1cn7oVxQRgD0l_hCI4nrSSWrKeVFysUp7 <named list [39]>
#>  2 THANKS                   1zNZpVO4MCjNUFUHOwSv3WlyUh4Dq_du3 <named list [39]>
#>  3 chicken-perm-article.txt 1oWpfPYR-77c-DdvoW30682F9Gde8Zpn- <named list [39]>
#>  4 googledrive-NEWS.md      15pfwRfXvpxekxhdERmSUnoxQY5K701y7 <named list [38]>
#>  5 def                      1hr4EFw3r5vAMm5Jgw2SsFluBpN-oAC-x <named list [32]>
#>  6 abc                      11lidFPceZAcNTHasQARiwAhE0NgmSfJN <named list [32]>
#>  7 BioC_mirrors.csv         1vV0fPdNOyo3Ti9ofA38MuTQm27pXvYq5 <named list [38]>
#>  8 logo.jpg                 1OFeNdd63NfoavqvDf5-xa3LORiamfKXS <named list [40]>
#>  9 Rlogo.svg                11sxsw-ux-UjQjzVdxd1wjNz37hJeBrBu <named list [40]>
#> 10 DESCRIPTION              1MjV4stVPhlMNz1AcrIizcL7yTcVaRuBo <named list [39]>
#> 11 chicken.txt              1xmwFZ_UN-CSs3Ic2aPUw22DbxZxoenVT <named list [39]>
#> 12 chicken.pdf              1eK9ozP1TZjXfAgaAGmP9GrUTovGUaO9S <named list [39]>
#> 13 chicken.jpg              1JnGjIdruQXErd20xR_ecAzN3yP_fTcfF <named list [40]>
#> 14 chicken.csv              1eHoOi9Ch3zk3_QBRKCJajFEIO4aeGINr <named list [38]>
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
