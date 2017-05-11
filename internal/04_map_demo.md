Map Demo
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
library("googledrive")
```

grab a file
-----------

``` r
my_file <- drive_get_id("test") %>%
  drive_file
```

lets take a peak
----------------

``` r
my_file
```

    ## File name: test_for_deleting 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-10 
    ## Access: Anyone on the internet can find and access. No sign-in required.

we can also pull out multiple files
-----------------------------------

``` r
lst_of_files <- purrr::map(.x =drive_get_id("test", n = 3), drive_file) 
```

change access
-------------

``` r
my_file <- my_file %>%
  drive_share(role = "reader", type = "anyone")
```

    ## The permissions for file 'test_for_deleting' have been updated

check access
------------

``` r
my_file
```

    ## File name: test_for_deleting 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-11 
    ## Access: Anyone on the internet can find and access. No sign-in required.

upload one
----------

``` r
drive_upload("~/desktop/hide/test.txt", "This is a test")
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/hide/test.txt 
    ## As the Google document named:
    ## This is a test

upload to a specific folder
---------------------------

``` r
drive_ls()
```

    ## # A tibble: 100 × 3
    ##                                                name        type
    ##                                               <chr>       <chr>
    ## 1                                    This is a test    document
    ## 2                                 test_for_deleting    document
    ## 3                           \U0001f33b Lucy & Jenny    document
    ## 4               Football Stadium Survey (Responses) spreadsheet
    ## 5                           Football Stadium Survey        form
    ## 6                                 Happy Little Demo    document
    ## 7                                    THIS IS A TEST      folder
    ## 8  Vanderbilt Graduate Student Handbook (Responses) spreadsheet
    ## 9                  WSDS Concurrent Session Abstract    document
    ## 10                R-Ladies Nashville 6-Month Survey        form
    ## # ... with 90 more rows, and 1 more variables: id <chr>

I'll use my `THIS IS A TEST` folder.

``` r
folder <- drive_get_id("THIS IS A TEST") %>%
  drive_file
```

``` r
new_file <- drive_upload("~/desktop/hide/test.txt") %>%
  drive_mv(folder)
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/hide/test.txt 
    ## As the Google document named:
    ## test

    ## The Google Drive file:
    ## test 
    ## was moved to folder:
    ## THIS IS A TEST

delete a lot!
-------------

``` r
to_delete <- purrr::map(drive_get_id("test", n = 3),  drive_file)
 
purrr::map(to_delete, drive_delete)
```

    ## The file 'test' has been deleted from your Google Drive

    ## The file 'This is a test' has been deleted from your Google Drive

    ## The file 'test_for_deleting' has been deleted from your Google Drive

    ## [[1]]
    ## [1] TRUE
    ## 
    ## [[2]]
    ## [1] TRUE
    ## 
    ## [[3]]
    ## [1] TRUE
