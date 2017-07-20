publish
================
Lucy D’Agostino McGowan
5/3/2017

-   [Motivation](#motivation)
-   [Push a file into a Sheet](#push-a-file-into-a-sheet)
-   [Check publication status (should be FALSE)](#check-publication-status-should-be-false)
-   [get URL](#get-url)
-   [it's published, not shared](#its-published-not-shared)
-   [switch to different account](#switch-to-different-account)
-   [this shouldn't work](#this-shouldnt-work)
-   [publish it on Drive](#publish-it-on-drive)
-   [try again!](#try-again)
-   [clean up](#clean-up)

Motivation
----------

Push a table into a Sheet.

Try to read it *as another user* Assume you even have the key. You will fail.

Now, as the user who owns the Sheet, publish it.

Now, as the other user, try again to read it via googlesheets. You should succeed.

Push a file into a Sheet
------------------------

``` r
drive_auth("drive-token.rds")
```

    ## Auto-refreshing stale OAuth token.

``` r
write_csv(chickwts, "chickwts.csv")
drive_chickwts <- drive_upload("chickwts.csv", type = "spreadsheet")
```

    ## File uploaded to Google Drive: 
    ## chickwts.csv 
    ## As the Google spreadsheet named:
    ## chickwts

Check publication status (should be FALSE)
------------------------------------------

``` r
drive_check_publish(drive_chickwts)
```

    ## The latest revision of the Google Drive file 'chickwts' is not published.

get URL
-------

``` r
url <- drive_share_link(drive_chickwts)
url
```

    ## [1] "https://docs.google.com/spreadsheets/d/1dES65Ur8AcYSS4JnnMGRp7A3wVJEHKMvBG8M60U4m0A/edit?usp=drivesdk"

it's published, not shared
--------------------------

``` r
drive_chickwts
```

    ## File name: chickwts 
    ## File owner: tidyverse testdrive 
    ## File type: spreadsheet 
    ## Last modified: 2017-05-22 
    ## Access: Shared with specific people.

``` r
key <- drive_chickwts$id
```

switch to different account
---------------------------

``` r
gs_auth("sheets-token.rds")
```

this shouldn't work
-------------------

``` r
try(gs_url(url, visibility = "private", lookup = FALSE))
```

    ## Sheet-identifying info appears to be a browser URL.
    ## googlesheets will attempt to extract sheet key from the URL.

    ## Putative key: 1dES65Ur8AcYSS4JnnMGRp7A3wVJEHKMvBG8M60U4m0A

    ## Worksheets feed constructed with private visibility

``` r
geterrmessage()
```

    ## [1] "Error in function_list[[k]](value) : Forbidden (HTTP 403).\n"

publish it on Drive
-------------------

``` r
drive_chickwts <- drive_publish(drive_chickwts)
```

    ## You have changed the publication status of 'chickwts'.

``` r
drive_check_publish(drive_chickwts)
```

    ## The latest revision of Google Drive file 'chickwts' is published.

try again!
----------

``` r
gs_url(url, lookup  = FALSE)
```

    ## Sheet-identifying info appears to be a browser URL.
    ## googlesheets will attempt to extract sheet key from the URL.

    ## Putative key: 1dES65Ur8AcYSS4JnnMGRp7A3wVJEHKMvBG8M60U4m0A

    ## Worksheets feed constructed with public visibility

    ##                   Spreadsheet title: chickwts
    ##                  Spreadsheet author: tidyverse.testdrive
    ##   Date of googlesheets registration: 2017-05-22 21:45:25 GMT
    ##     Date of last spreadsheet update: 2017-05-22 21:45:21 GMT
    ##                          visibility: public
    ##                         permissions: rw
    ##                             version: new
    ## 
    ## Contains 1 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## chickwts: 1000 x 26
    ## 
    ## Key: 1dES65Ur8AcYSS4JnnMGRp7A3wVJEHKMvBG8M60U4m0A
    ## Browser URL: https://docs.google.com/spreadsheets/d/1dES65Ur8AcYSS4JnnMGRp7A3wVJEHKMvBG8M60U4m0A/

check again that the access is still just "Shared with specific people."

``` r
drive_chickwts$access
```

    ## [1] "Shared with specific people."

clean up
--------

``` r
#drive_delete(drive_chickwts)
```
