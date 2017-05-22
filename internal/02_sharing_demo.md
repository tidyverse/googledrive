sharing demo
================
Lucy D’Agostino McGowan
5/3/2017

-   [check current permissions](#check-current-permissions)
-   [change permissions (anyone with link)](#change-permissions-anyone-with-link)
-   [change permissions (anyone in the 🌐)](#change-permissions-anyone-in-the)
-   [make it easier to see](#make-it-easier-to-see)
-   [share link](#share-link)
-   [clean up](#clean-up)

This is a little demo to show how we may view sharing.

``` r
library('dplyr')
library('googledrive')
drive_auth("drive-token.rds")
```

``` r
write.table("This is a little demo", "demo.txt")
drive_upload("demo.txt", "Happy Little Demo")
```

    ## File uploaded to Google Drive: 
    ## demo.txt 
    ## As the Google text/plain named:
    ## Happy Little Demo

``` r
my_file <- drive_list("Happy Little Demo")$id %>%
  drive_file()
```

check current permissions
-------------------------

``` r
my_file
```

    ## File name: Happy Little Demo 
    ## File owner: tidyverse testdrive 
    ## File type: text/plain 
    ## Last modified: 2017-05-22 
    ## Access: Shared with specific people.

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
my_file
```

    ## File name: Happy Little Demo 
    ## File owner: tidyverse testdrive 
    ## File type: text/plain 
    ## Last modified: 2017-05-22 
    ## Access: Anyone who has the link can access. No sign-in required.

Now anyone with the link can view it

change permissions (anyone in the 🌐)
------------------------------------

``` r
my_file <- my_file %>%
  drive_share(role = "reader", type = "anyone", allowFileDiscovery = "true")
```

    ## The permissions for file 'Happy Little Demo' have been updated

Let's see what that did

``` r
my_file
```

    ## File name: Happy Little Demo 
    ## File owner: tidyverse testdrive 
    ## File type: text/plain 
    ## Last modified: 2017-05-22 
    ## Access: Anyone on the internet can find and access. No sign-in required.

make it easier to see
---------------------

I've added `access` to the Google Drive file object

``` r
my_file$access
```

    ## [1] "Anyone on the internet can find and access. No sign-in required."

share link
----------

you can also output a link to share

``` r
drive_share_link(my_file)
```

    ## [1] "https://drive.google.com/file/d/0B0Gh-SuuA2nTNHFSM05ycjhwRVE/view?usp=drivesdk"

clean up
--------

``` r
drive_delete(my_file)
```

    ## The file 'Happy Little Demo' has been deleted from your Google Drive
