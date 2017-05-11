sharing demo
================
Lucy D’Agostino McGowan
5/3/2017

-   [check current permissions](#check-current-permissions)
-   [change permissions (anyone with link)](#change-permissions-anyone-with-link)
-   [change permissions (anyone in the 🌎)](#change-permissions-anyone-in-the)
-   [make it easier to see](#make-it-easier-to-see)
-   [share link](#share-link)
-   [clean up](#clean-up)

This is a little demo to show how we may view sharing.

``` r
library('dplyr')
library('googledrive')
```

``` r
write.table("This is a little demo", "demo.txt")
drive_upload("demo.txt", "Happy Little Demo")
```

    ## File uploaded to Google Drive: 
    ## demo.txt 
    ## As the Google document named:
    ## Happy Little Demo

``` r
my_file <- drive_get_id("Happy Little Demo") %>%
  drive_file()
```

check current permissions
-------------------------

``` r
my_file$permissions
```

    ## # A tibble: 1 × 8
    ##               kind                   id  type            emailAddress
    ##              <chr>                <chr> <chr>                   <chr>
    ## 1 drive#permission 13813982488463916564  user lucydagostino@gmail.com
    ## # ... with 4 more variables: role <chr>, displayName <chr>,
    ## #   photoLink <chr>, deleted <lgl>

cool beans - it's private!

change permissions (anyone with link)
-------------------------------------

*all functions that will somehow change the file will output a new file, overwrite the old file with this to avoid confusion*

``` r
my_file<- my_file %>%
  drive_share(role = "reader", type = "anyone")
```

    ## The permissions for file 'Happy Little Demo' have been updated

Let's see what that did

``` r
my_file$permissions
```

    ## # A tibble: 2 × 9
    ##               kind                   id   type            emailAddress
    ##              <chr>                <chr>  <chr>                   <chr>
    ## 1 drive#permission 13813982488463916564   user lucydagostino@gmail.com
    ## 2 drive#permission       anyoneWithLink anyone                    <NA>
    ## # ... with 5 more variables: role <chr>, displayName <chr>,
    ## #   photoLink <chr>, deleted <lgl>, allowFileDiscovery <lgl>

Now anyone with the link can view it

change permissions (anyone in the 🌎)
------------------------------------

``` r
my_file <- my_file %>%
  drive_share(role = "reader", type = "anyone", allowFileDiscovery = "true")
```

    ## The permissions for file 'Happy Little Demo' have been updated

Let's see what that did

``` r
my_file$permissions
```

    ## # A tibble: 3 × 9
    ##               kind                   id   type            emailAddress
    ##              <chr>                <chr>  <chr>                   <chr>
    ## 1 drive#permission 13813982488463916564   user lucydagostino@gmail.com
    ## 2 drive#permission               anyone anyone                    <NA>
    ## 3 drive#permission       anyoneWithLink anyone                    <NA>
    ## # ... with 5 more variables: role <chr>, displayName <chr>,
    ## #   photoLink <chr>, deleted <lgl>, allowFileDiscovery <lgl>

make it easier to see
---------------------

I've added `access` to the Google Drive file object

``` r
my_file$access
```

    ## [1] "Anyone on the internet can find and access. No sign-in required."

and also to the print method:

``` r
my_file
```

    ## File name: Happy Little Demo 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-11 
    ## Access: Anyone on the internet can find and access. No sign-in required.

share link
----------

you can also output a link to share

``` r
drive_share_link(my_file)
```

    ## [1] "https://docs.google.com/document/d/1qrIsA5fFKn1VmvzzZ4Pymq6SYZuxaRe7xJK35j_SRRA/edit?usp=drivesdk"

clean up
--------

``` r
drive_delete(my_file)
```

    ## The file 'Happy Little Demo' has been deleted from your Google Drive
