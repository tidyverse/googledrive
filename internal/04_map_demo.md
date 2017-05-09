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
my_file <- gd_get_id("test") %>%
  gd_file
```

lets take a peak
----------------

``` r
my_file
```

    ## File name: This is a test 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-09 
    ## Access: Shared with specific people.

we can also pull out multiple files
-----------------------------------

``` r
lst_of_files <- purrr::map(.x =gd_get_id("test", n = 3), gd_file) 
```

change access
-------------

``` r
my_file <- my_file %>%
  gd_share(role = "reader", type = "anyone")
```

    ## The permissions for file 'This is a test' have been updated

check access
------------

``` r
my_file
```

    ## File name: This is a test 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-09 
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
    ##                       name     type
    ##                      <chr>    <chr>
    ## 1           This is a test document
    ## 2           This is a test document
    ## 3                     test document
    ## 4                     test document
    ## 5                     test document
    ## 6                     test document
    ## 7                     test document
    ## 8                     test document
    ## 9        Happy Little Demo document
    ## 10 Football Stadium Survey     form
    ## # ... with 90 more rows, and 1 more variables: id <chr>

I'll use my `THIS IS A TEST` folder.

``` r
folder <- gd_get_id("THIS IS A TEST") %>%
  gd_file
```

``` r
new_file <- gd_upload("~/desktop/hide/test.txt") %>%
  gd_mv(folder)
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
to_delete <- purrr::map(gd_get_id("test", n = 3),  gd_file)
 
purrr::map(to_delete, gd_delete)
```

    ## The file 'test' has been deleted from your Google Drive

    ## The file 'This is a test' has been deleted from your Google Drive
    ## The file 'This is a test' has been deleted from your Google Drive

    ## [[1]]
    ## [1] TRUE
    ## 
    ## [[2]]
    ## [1] TRUE
    ## 
    ## [[3]]
    ## [1] TRUE
