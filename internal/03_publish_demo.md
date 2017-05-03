publish
================
Lucy D’Agostino McGowan
5/3/2017

-   [check published status](#check-published-status)
-   [publish it](#publish-it)
-   [check again](#check-again)
-   [clean up](#clean-up)

This is a little demo to show how we can check if a file is published & publish it if we so desire.

``` r
library('dplyr')
library('googledrive')
```

``` r
write.table("This is a little demo", "demo.txt")
gd_upload("demo.txt", name = "Happy Little Demo")
```

    ## File uploaded to Google Drive: 
    ## demo.txt 
    ## As the Google document named:
    ## Happy Little Demo

``` r
my_file <- gd_get_id("Happy Little Demo") %>%
  gd_file
```

check published status
----------------------

``` r
my_file %>%
  gd_check_publish
```

    ## The Google Drive file 'Happy Little Demo' is not published.

publish it
----------

``` r
my_file %>%
  gd_publish
```

    ## You have successfully published 'Happy Little Demo'.

check again
-----------

``` r
my_file %>%
  gd_check_publish
```

    ## The Google Drive file 'Happy Little Demo' is published.

clean up
--------

``` r
gd_delete(my_file)
```

    ## The file 'Happy Little Demo' has been deleted from your Google Drive
