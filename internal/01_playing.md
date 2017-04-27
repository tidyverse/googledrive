playing
================
Lucy D’Agostino McGowan
4/26/2017

-   [List](#list)
-   [Metadata](#metadata)
-   [User info](#user-info)

*side note, really excited to include emojis in a non-hacky way, thanks [emo::ji](http://github.com/hadley/emo)* 🌻

``` r
library('googledrive')
library('dplyr')
```

this is almost an exact copy of how `gs_auth()` works

``` r
gd_auth() 
```

List
----

`gd_ls()` pulls out name, type, & id (we probably don't want to see id, but seems useful to have here, so we could pick which one we want to get more info on?)

``` r
gd_ls()
```

    ## # A tibble: 100 × 3
    ##                                                        name        type
    ##                                                       <chr>       <chr>
    ## 1                                2017 Owen Olympics Sign-up spreadsheet
    ## 2                                     contributr-maintainer spreadsheet
    ## 3                                contributr maintainer form        form
    ## 4  Space Apps 2017 - Social Media Information for All Sites spreadsheet
    ## 5  Graduate Education Working Group Nominations (Responses) spreadsheet
    ## 6          Vanderbilt Graduate Student Handbook (Responses) spreadsheet
    ## 7                                            GSC Committees        form
    ## 8                                     R-Ladies Global TEAMS    document
    ## 9                   Exec Board Reponsibilities  (Responses) spreadsheet
    ## 10                              Exec Board Reponsibilities         form
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

    ## # A tibble: 7 × 8
    ##                         name        type             owner
    ##                        <chr>       <chr>             <chr>
    ## 1 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## 2 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## 3 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## 4 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## 5 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## 6 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## 7 2017 Owen Olympics Sign-up spreadsheet Courtney Williams
    ## # ... with 5 more variables: permission_who <chr>, permission_role <chr>,
    ## #   permission_type <chr>, modified <date>, object <list>

It looks a bit repetitive - right now I have a separate line for everyone permission

``` r
metadata_tbl %>%
  select(name, permission_who, permission_role)
```

    ## # A tibble: 7 × 3
    ##                         name    permission_who permission_role
    ##                        <chr>             <chr>           <chr>
    ## 1 2017 Owen Olympics Sign-up Courtney Williams           owner
    ## 2 2017 Owen Olympics Sign-up   Richard Rosenow          writer
    ## 3 2017 Owen Olympics Sign-up     Ryan W Gillis          writer
    ## 4 2017 Owen Olympics Sign-up       John Wilson          writer
    ## 5 2017 Owen Olympics Sign-up caroline guenther          writer
    ## 6 2017 Owen Olympics Sign-up     Francis Huynh          writer
    ## 7 2017 Owen Olympics Sign-up    anyoneWithLink          writer

In addition to the things I've pulled out, there is a `list-col` (now named `object`, this should change), that contains all output fields.

``` r
metadata_tbl %>%
  select(object)
```

    ## # A tibble: 7 × 1
    ##        object
    ##        <list>
    ## 1 <list [25]>
    ## 2 <list [25]>
    ## 3 <list [25]>
    ## 4 <list [25]>
    ## 5 <list [25]>
    ## 6 <list [25]>
    ## 7 <list [25]>

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
    ## [1] "2017-04-27 18:30:15 GMT"
    ## 
    ## attr(,"class")
    ## [1] "drive_user" "list"
