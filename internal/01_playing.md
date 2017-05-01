playing
================
Lucy D’Agostino McGowan
4/26/2017

-   [List](#list)
-   [Metadata](#metadata)
-   [User info](#user-info)
-   [Upload file](#upload-file)

*side note, really excited to include emojis in a non-hacky way, thanks [emo::ji](http://github.com/hadley/emo)* 🌻

``` r
library('googledrive')
library('dplyr')
```

List
----

`gd_ls()` pulls out name, type, & id (we probably don't want to see id, but seems useful to have here, so we could pick which one we want to get more info on?)

``` r
gd_ls()
```

    ## # A tibble: 100 × 3
    ##                                      name         type
    ##                                     <chr>        <chr>
    ## 1                                    test     document
    ## 2                                    test     document
    ## 3                                    test     document
    ## 4                                    test     document
    ## 5                                test9999 presentation
    ## 6                              lalallalal     document
    ## 7                               test12345     document
    ## 8                               test12345     document
    ## 9  Health Insurance Questions (Responses)  spreadsheet
    ## 10             Health Insurance Questions         form
    ## # ... with 90 more rows, and 1 more variables: id <chr>

Metadata
--------

Note: now it seems we have to specify the fields (in v2 where I was working previously, it would automatically output everything, see [this](https://developers.google.com/drive/v3/web/migration)).

List of all fields [here](https://developers.google.com/drive/v3/web/migration).

Now let's say I want to dive deeper into the top one

``` r
metadata_tbl <- gd_ls() %>%
                  slice(1) %>%
                  select(id) %>%
                  gd_get()
metadata_tbl
```

    ## # A tibble: 1 × 5
    ##    name     type           owner   modified      object
    ##   <chr>    <chr>           <chr>     <date>      <list>
    ## 1  test document Lucy D'Agostino 2017-05-01 <list [27]>

In addition to the things I've pulled out, there is a `list-col` (now named `object`, this should change), that contains all output fields.

``` r
metadata_tbl %>%
  select(object)
```

    ## # A tibble: 1 × 1
    ##        object
    ##        <list>
    ## 1 <list [27]>

and we can dive deeper into this object by piecing through this list like so

``` r
metadata_tbl %>%
  select(object) %>%
  .[[1]] %>% #ick this is clearly not the best way to do this...
  .[[1]] %>%
  .$permissions
```

    ## [[1]]
    ## [[1]]$kind
    ## [1] "drive#permission"
    ## 
    ## [[1]]$id
    ## [1] "13813982488463916564"
    ## 
    ## [[1]]$type
    ## [1] "user"
    ## 
    ## [[1]]$emailAddress
    ## [1] "lucydagostino@gmail.com"
    ## 
    ## [[1]]$role
    ## [1] "owner"
    ## 
    ## [[1]]$displayName
    ## [1] "Lucy D'Agostino"
    ## 
    ## [[1]]$photoLink
    ## [1] "https://lh5.googleusercontent.com/-9QyJNrSIw8U/AAAAAAAAAAI/AAAAAAAAAXY/zcdEycKqKQk/s64/photo.jpg"
    ## 
    ## [[1]]$deleted
    ## [1] FALSE

User info
---------

``` r
gd_user()
```

    ## $user
    ## $user$kind
    ## [1] "drive#user"
    ## 
    ## $user$displayName
    ## [1] "Lucy D'Agostino"
    ## 
    ## $user$photoLink
    ## [1] "https://lh5.googleusercontent.com/-9QyJNrSIw8U/AAAAAAAAAAI/AAAAAAAAAXY/zcdEycKqKQk/s64/photo.jpg"
    ## 
    ## $user$me
    ## [1] TRUE
    ## 
    ## $user$permissionId
    ## [1] "13813982488463916564"
    ## 
    ## $user$emailAddress
    ## [1] "lucydagostino@gmail.com"
    ## 
    ## 
    ## $date
    ## [1] "2017-05-01 04:03:47 GMT"
    ## 
    ## attr(,"class")
    ## [1] "drive_user" "list"

Upload file
-----------

``` r
write.table("this is a test", file = "~/desktop/test.txt")
gd_upload(file = "~/desktop/test.txt")
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/test.txt 
    ## As the Google document named:
    ## test
