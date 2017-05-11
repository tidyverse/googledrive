publish
================
Lucy D’Agostino McGowan
5/3/2017

-   [check published status](#check-published-status)
-   [publish it](#publish-it)
-   [clean up](#clean-up)

This is a little demo to show how we can check if a file is published & publish it if we so desire.

``` r
library('dplyr')
library('googledrive')
```

``` r
write.table("This is a little demo", "demo.txt")
drive_upload("demo.txt", name = "Happy Little Demo")
```

    ## File uploaded to Google Drive: 
    ## demo.txt 
    ## As the Google document named:
    ## Happy Little Demo

``` r
my_file <- drive_get_id("Happy Little Demo") %>%
  drive_file
```

check published status
----------------------

``` r
my_file %>%
  drive_check_publish
```

    ## The latest revision of the Google Drive file 'Happy Little Demo' is not published.

the `drive_check_publish` also outputs a new file with a tibble called `publish` with publication information. We can overwrite `my_file` to see this

``` r
my_file <- my_file %>%
  drive_check_publish
```

    ## The latest revision of the Google Drive file 'Happy Little Demo' is not published.

``` r
my_file$publish
```

    ## # A tibble: 1 × 5
    ##            check_time revision published auto_publish       last_user
    ##                <dttm>    <chr>     <lgl>        <lgl>           <chr>
    ## 1 2017-05-11 10:47:13        3     FALSE        FALSE Lucy D'Agostino

publish it
----------

``` r
my_file <- my_file %>%
  drive_publish
```

    ## You have changed the publication status of 'Happy Little Demo'.

now we have tibble with publication status

``` r
my_file$publish
```

    ## # A tibble: 1 × 5
    ##            check_time revision published auto_publish       last_user
    ##                <dttm>    <chr>     <lgl>        <lgl>           <chr>
    ## 1 2017-05-11 10:47:16        3      TRUE         TRUE Lucy D'Agostino

clean up
--------

``` r
drive_delete(my_file)
```

    ## The file 'Happy Little Demo' has been deleted from your Google Drive
