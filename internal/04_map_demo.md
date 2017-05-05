Untitled
================
Lucy D’Agostino McGowan
5/5/2017

-   [grab a file](#grab-a-file)
-   [lets take a peak](#lets-take-a-peak)
-   [we can also pull out multiple files](#we-can-also-pull-out-multiple-files)
-   [change access](#change-access)
-   [check access](#check-access)
-   [upload one](#upload-one)
-   [upload to a specific folder](#upload-to-a-specific-folder)
-   [delete a lot!](#delete-a-lot)

``` r
library("dplyr")
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library("googledrive")
```

grab a file
-----------

``` r
file <- gd_get_id("test") %>%
  gd_file
```

    ## Auto-refreshing stale OAuth token.

lets take a peak
----------------

``` r
file
```

    ## File name: test 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-05 
    ## Access: Shared with specific people.

we can also pull out multiple files
-----------------------------------

``` r
lst_of_files <- purrr::map(.x =gd_get_id("test", n = 3), gd_file) 
```

change access
-------------

``` r
file %>%
  gd_share(role = "reader", type = "anyone") -> file_update
```

    ## The permissions for file 'test' have been updated

check access
------------

``` r
file_update
```

    ## File name: test 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-05 
    ## Access: Anyone who has the link can access. No sign-in required.

upload one
----------

``` r
gd_upload("~/desktop/hide/test.txt", "This is a test")
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/hide/test.txt 
    ## As the Google document named:
    ## This is a test

upload to a specific folder
---------------------------

``` r
gd_ls()
```

    ## # A tibble: 100 × 3
    ##                                                name        type
    ##                                               <chr>       <chr>
    ## 1                                    This is a test    document
    ## 2                                              test    document
    ## 3                                    This is a test    document
    ## 4                                              test    document
    ## 5                                    THIS IS A TEST      folder
    ## 6                           \U0001f33b Lucy & Jenny    document
    ## 7  Vanderbilt Graduate Student Handbook (Responses) spreadsheet
    ## 8                  WSDS Concurrent Session Abstract    document
    ## 9                 R-Ladies Nashville 6-Month Survey        form
    ## 10           Health Insurance Questions (Responses) spreadsheet
    ## # ... with 90 more rows, and 1 more variables: id <chr>

I'll use my `THIS IS A TEST` folder.

``` r
folder <- gd_get_id("THIS IS A TEST") %>%
  gd_file
```

``` r
new_file <- gd_upload("~/desktop/hide/test.txt", folder = folder)
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/hide/test.txt 
    ## As the Google document named:
    ## test

delete a lot!
-------------

``` r
to_delete <- purrr::map(gd_get_id("test", n = 3),  gd_file)
 
purrr::map(to_delete, gd_delete)
```

    ## The file 'test' has been deleted from your Google Drive

    ## The file 'This is a test' has been deleted from your Google Drive

    ## The file 'test' has been deleted from your Google Drive

    ## [[1]]
    ## [1] TRUE
    ## 
    ## [[2]]
    ## [1] TRUE
    ## 
    ## [[3]]
    ## [1] TRUE
