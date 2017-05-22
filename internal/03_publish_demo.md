publish
================
Lucy D’Agostino McGowan
5/3/2017

-   [Motivation](#motivation)
-   [Push a file into a Sheet](#push-a-file-into-a-sheet)
-   [Check publication status (should be FALSE)](#check-publication-status-should-be-false)
-   [get URL](#get-url)
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
drive_chickwts <- drive_upload("~/desktop/chickwts.csv", type = "spreadsheet")
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/chickwts.csv 
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
```

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
try(gs_url(url, lookup = FALSE))
```

    ## Sheet-identifying info appears to be a browser URL.
    ## googlesheets will attempt to extract sheet key from the URL.

    ## Putative key: 1S-GYudy2qu_JMZCVPYwKUH2Kh3hLUeqtwH7-XrF_Vs8

    ## Worksheets feed constructed with public visibility

``` r
geterrmessage()
```

    ## [1] "Error in stop_for_content_type(req, expected = \"application/atom+xml; charset=UTF-8\") : \n  Expected content-type:\napplication/atom+xml; charset=UTF-8\nActual content-type:\ntext/html; charset=UTF-8\n"

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

    ## Putative key: 1S-GYudy2qu_JMZCVPYwKUH2Kh3hLUeqtwH7-XrF_Vs8

    ## Worksheets feed constructed with public visibility

    ##                   Spreadsheet title: chickwts
    ##                  Spreadsheet author: tidyverse.testdrive
    ##   Date of googlesheets registration: 2017-05-22 19:21:02 GMT
    ##     Date of last spreadsheet update: 2017-05-22 19:20:59 GMT
    ##                          visibility: public
    ##                         permissions: rw
    ##                             version: new
    ## 
    ## Contains 1 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## chickwts: 1000 x 26
    ## 
    ## Key: 1S-GYudy2qu_JMZCVPYwKUH2Kh3hLUeqtwH7-XrF_Vs8
    ## Browser URL: https://docs.google.com/spreadsheets/d/1S-GYudy2qu_JMZCVPYwKUH2Kh3hLUeqtwH7-XrF_Vs8/

clean up
--------

``` r
drive_delete(drive_chickwts)
```

    ## The file 'chickwts' has been deleted from your Google Drive
