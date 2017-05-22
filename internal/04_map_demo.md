Map Demo
================
Lucy D’Agostino McGowan
5/5/2017

-   [we can also pull out multiple files](#we-can-also-pull-out-multiple-files)
-   [change access](#change-access)
-   [check access](#check-access)
-   [delete them all!](#delete-them-all)

``` r
library("dplyr")
library("googledrive")
drive_auth("drive-token.rds")
```

we can also pull out multiple files
-----------------------------------

``` r
list_of_ids <- drive_list(pattern = "test")$id[1:10]
list_of_files <- list_of_ids %>%
  purrr::map(drive_file)
```

change access
-------------

``` r
list_of_files <- list_of_files %>%
  purrr::map(drive_share, role = "reader", type = "anyone")
```

    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated
    ## The permissions for file 'its-a-test!' have been updated

check access
------------

``` r
list_of_files %>% purrr::map_chr("access")
```

    ##  [1] "Anyone who has the link can access. No sign-in required."
    ##  [2] "Anyone who has the link can access. No sign-in required."
    ##  [3] "Anyone who has the link can access. No sign-in required."
    ##  [4] "Anyone who has the link can access. No sign-in required."
    ##  [5] "Anyone who has the link can access. No sign-in required."
    ##  [6] "Anyone who has the link can access. No sign-in required."
    ##  [7] "Anyone who has the link can access. No sign-in required."
    ##  [8] "Anyone who has the link can access. No sign-in required."
    ##  [9] "Anyone who has the link can access. No sign-in required."
    ## [10] "Anyone who has the link can access. No sign-in required."

delete them all!
----------------

``` r
list_of_files <- list_of_files %>% 
  purrr::map(drive_delete)
```

    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
    ## The file 'its-a-test!' has been deleted from your Google Drive
