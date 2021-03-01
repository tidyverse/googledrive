
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
#> # A tibble: 16 x 3
#>    name                        id                               drive_resource  
#>  * <chr>                       <chr>                            <list>          
#>  1 chicken.csv                 1o6dQB-ZygN9Bbl_y9xUEilQNYEZbIx… <named list [38…
#>  2 upload-into-me-article-demo 1yP0o6H8l-4IUJj2LDGOoYp-vIfBb1g… <named list [32…
#>  3 Rlogo.pdf                   1cn7oVxQRgD0l_hCI4nrSSWrKeVFysU… <named list [39…
#>  4 THANKS                      1zNZpVO4MCjNUFUHOwSv3WlyUh4Dq_d… <named list [39…
#>  5 chicken-perm-article.txt    1oWpfPYR-77c-DdvoW30682F9Gde8Zp… <named list [39…
#>  6 googledrive-NEWS.md         15pfwRfXvpxekxhdERmSUnoxQY5K701… <named list [38…
#>  7 def                         1hr4EFw3r5vAMm5Jgw2SsFluBpN-oAC… <named list [32…
#>  8 abc                         11lidFPceZAcNTHasQARiwAhE0NgmSf… <named list [32…
#>  9 BioC_mirrors.csv            1vV0fPdNOyo3Ti9ofA38MuTQm27pXvY… <named list [38…
#> 10 logo.jpg                    1OFeNdd63NfoavqvDf5-xa3LORiamfK… <named list [40…
#> 11 Rlogo.svg                   11sxsw-ux-UjQjzVdxd1wjNz37hJeBr… <named list [40…
#> 12 DESCRIPTION                 1MjV4stVPhlMNz1AcrIizcL7yTcVaRu… <named list [39…
#> 13 chicken.txt                 1xmwFZ_UN-CSs3Ic2aPUw22DbxZxoen… <named list [39…
#> 14 chicken.pdf                 1eK9ozP1TZjXfAgaAGmP9GrUTovGUaO… <named list [39…
#> 15 chicken.jpg                 1JnGjIdruQXErd20xR_ecAzN3yP_fTc… <named list [40…
#> 16 chicken.csv                 1eHoOi9Ch3zk3_QBRKCJajFEIO4aeGI… <named list [38…
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
