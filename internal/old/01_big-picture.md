big picture
================
Lucy D’Agostino McGowan
4/26/2017

-   [List](#list)
-   [Metadata](#metadata)
-   [User info](#user-info)
-   [Upload file](#upload-file)
-   [Update sharing](#update-sharing)
-   [View permissions](#view-permissions)
-   [Make it fully shareable](#make-it-fully-shareable)
-   [Extract share link](#extract-share-link)
-   [Delete file](#delete-file)

*side note, really excited to include emojis in a non-hacky way, thanks [emo::ji](http://github.com/hadley/emo)* 🌻

``` r
library('googledrive')
library('dplyr')
drive_auth("drive-token.rds")
```

List
----

`drive_list()` pulls out name, type, & id

``` r
drive_list()
```

    ## # A tibble: 100 x 5
    ##        name         type    parents
    ##       <chr>        <chr>     <list>
    ##  1 chickwts  spreadsheet <list [1]>
    ##  2 chickwts  spreadsheet <list [1]>
    ##  3 chickwts  spreadsheet <list [1]>
    ##  4 chickwts  spreadsheet <list [1]>
    ##  5 chickwts  spreadsheet <list [1]>
    ##  6 chickwts  spreadsheet <list [1]>
    ##  7 chickwts  spreadsheet <list [1]>
    ##  8 chickwts     text/csv <list [1]>
    ##  9     test presentation <list [1]>
    ## 10      baz     document <list [1]>
    ## # ... with 90 more rows, and 2 more variables: id <chr>, gfile <list>

We can search using regular expressions

``` r
drive_list(pattern = "test")
```

    ## # A tibble: 61 x 5
    ##             name         type    parents
    ##            <chr>        <chr>     <list>
    ##  1          test presentation <list [1]>
    ##  2 tests_8675309       folder <list [1]>
    ##  3   its-a-test!   image/jpeg <list [1]>
    ##  4   its-a-test!   image/jpeg <list [1]>
    ##  5   its-a-test!   image/jpeg <list [1]>
    ##  6   its-a-test!   image/jpeg <list [1]>
    ##  7   its-a-test!   image/jpeg <list [1]>
    ##  8   its-a-test!   image/jpeg <list [1]>
    ##  9   its-a-test!   image/jpeg <list [1]>
    ## 10   its-a-test!   image/jpeg <list [1]>
    ## # ... with 51 more rows, and 2 more variables: id <chr>, gfile <list>

We can also pass additional query parameters through the `...`, for example

``` r
drive_list(pattern = "test", orderBy = "modifiedTime")
```

    ## # A tibble: 98 x 5
    ##           name       type    parents                           id
    ##          <chr>      <chr>     <list>                        <chr>
    ##  1 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTYVctbGpHWURVS3c
    ##  2 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTT0YtS0phR3hnX0k
    ##  3 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTVC1LS0dYcUhfbDQ
    ##  4 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTaXpXcGhuRDZzNjg
    ##  5 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTWE9pODhrcDhiVmM
    ##  6 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTSUNoTE5CdTJjSDg
    ##  7 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTSjVlNDdUZXdDOUE
    ##  8 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTeVg3UnpPQmMzV00
    ##  9 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTcVVxcm92SnNlajQ
    ## 10 its-a-test! image/jpeg <list [1]> 0B0Gh-SuuA2nTcjJWZ01kRG5DbE0
    ## # ... with 88 more rows, and 1 more variables: gfile <list>

Metadata
--------

Note: now it seems we have to specify the fields (in v2 where I was working previously, it would automatically output everything, see [this](https://developers.google.com/drive/v3/web/migration)).

List of all fields [here](https://developers.google.com/drive/v3/web/migration).

Now let's say I want to dive deeper into the top one

``` r
id <- drive_list("test")$id[1]
file <- drive_file(id)
file
```

    ## File name: test 
    ## File owner: tidyverse testdrive 
    ## File type: presentation 
    ## Last modified: 2017-05-22 
    ## Access: Shared with specific people.

In addition to the things I've pulled out, there is a `tibble` of permissions as well as a `list` (now named `kitchen_sink`, this should change), that contains all output fields.

``` r
file$permissions
```

    ## # A tibble: 1 x 7
    ##               kind                   id  type
    ##              <chr>                <chr> <chr>
    ## 1 drive#permission 01555823402173812461  user
    ## # ... with 4 more variables: emailAddress <chr>, role <chr>,
    ## #   displayName <chr>, deleted <lgl>

``` r
str(file$kitchen_sink)
```

    ## List of 27
    ##  $ kind                 : chr "drive#file"
    ##  $ id                   : chr "1XknZYver9cjpjWAWYcNq4keotpzDdmaWvvim8q-t-LY"
    ##  $ name                 : chr "test"
    ##  $ mimeType             : chr "application/vnd.google-apps.presentation"
    ##  $ starred              : logi FALSE
    ##  $ trashed              : logi FALSE
    ##  $ explicitlyTrashed    : logi FALSE
    ##  $ parents              :List of 1
    ##   ..$ : chr "0AEGh-SuuA2nTUk9PVA"
    ##  $ spaces               :List of 1
    ##   ..$ : chr "drive"
    ##  $ version              : chr "13822"
    ##  $ webViewLink          : chr "https://docs.google.com/presentation/d/1XknZYver9cjpjWAWYcNq4keotpzDdmaWvvim8q-t-LY/edit?usp=drivesdk"
    ##  $ iconLink             : chr "https://drive-thirdparty.googleusercontent.com/16/type/application/vnd.google-apps.presentation"
    ##  $ thumbnailLink        : chr "https://docs.google.com/feeds/vt?gd=true&id=1XknZYver9cjpjWAWYcNq4keotpzDdmaWvvim8q-t-LY&v=2&s=AMedNnoAAAAAWSNVMqfDkprZmRcuzzeD"| __truncated__
    ##  $ viewedByMe           : logi TRUE
    ##  $ viewedByMeTime       : chr "2017-05-22T17:01:13.856Z"
    ##  $ createdTime          : chr "2017-05-22T16:59:54.102Z"
    ##  $ modifiedTime         : chr "2017-05-22T16:59:58.899Z"
    ##  $ modifiedByMeTime     : chr "2017-05-22T16:59:58.899Z"
    ##  $ owners               :List of 1
    ##   ..$ :List of 5
    ##   .. ..$ kind        : chr "drive#user"
    ##   .. ..$ displayName : chr "tidyverse testdrive"
    ##   .. ..$ me          : logi TRUE
    ##   .. ..$ permissionId: chr "01555823402173812461"
    ##   .. ..$ emailAddress: chr "tidyverse.testdrive@gmail.com"
    ##  $ lastModifyingUser    :List of 5
    ##   ..$ kind        : chr "drive#user"
    ##   ..$ displayName : chr "tidyverse testdrive"
    ##   ..$ me          : logi TRUE
    ##   ..$ permissionId: chr "01555823402173812461"
    ##   ..$ emailAddress: chr "tidyverse.testdrive@gmail.com"
    ##  $ shared               : logi FALSE
    ##  $ ownedByMe            : logi TRUE
    ##  $ capabilities         :List of 15
    ##   ..$ canAddChildren                : logi FALSE
    ##   ..$ canChangeViewersCanCopyContent: logi TRUE
    ##   ..$ canComment                    : logi TRUE
    ##   ..$ canCopy                       : logi TRUE
    ##   ..$ canDelete                     : logi TRUE
    ##   ..$ canDownload                   : logi TRUE
    ##   ..$ canEdit                       : logi TRUE
    ##   ..$ canListChildren               : logi FALSE
    ##   ..$ canMoveItemIntoTeamDrive      : logi TRUE
    ##   ..$ canReadRevisions              : logi TRUE
    ##   ..$ canRemoveChildren             : logi FALSE
    ##   ..$ canRename                     : logi TRUE
    ##   ..$ canShare                      : logi TRUE
    ##   ..$ canTrash                      : logi TRUE
    ##   ..$ canUntrash                    : logi TRUE
    ##  $ viewersCanCopyContent: logi TRUE
    ##  $ writersCanShare      : logi TRUE
    ##  $ permissions          :List of 1
    ##   ..$ :List of 7
    ##   .. ..$ kind        : chr "drive#permission"
    ##   .. ..$ id          : chr "01555823402173812461"
    ##   .. ..$ type        : chr "user"
    ##   .. ..$ emailAddress: chr "tidyverse.testdrive@gmail.com"
    ##   .. ..$ role        : chr "owner"
    ##   .. ..$ displayName : chr "tidyverse testdrive"
    ##   .. ..$ deleted     : logi FALSE
    ##  $ quotaBytesUsed       : chr "0"

User info
---------

``` r
drive_user()
```

    ## $user
    ## $user$kind
    ## [1] "drive#user"
    ## 
    ## $user$displayName
    ## [1] "tidyverse testdrive"
    ## 
    ## $user$me
    ## [1] TRUE
    ## 
    ## $user$permissionId
    ## [1] "01555823402173812461"
    ## 
    ## $user$emailAddress
    ## [1] "tidyverse.testdrive@gmail.com"
    ## 
    ## 
    ## attr(,"class")
    ## [1] "guser" "list"

Upload file
-----------

``` r
write.table("this is a test", file = "~/desktop/test.txt")
drive_upload(input = "~/desktop/test.txt", output = "This is a test", overwrite = TRUE)
```

    ## File uploaded to Google Drive: 
    ## ~/desktop/test.txt 
    ## As the Google text/plain named:
    ## This is a test

``` r
file <- drive_file(drive_list("This is a test")$id)
file
```

    ## File name: This is a test 
    ## File owner: tidyverse testdrive 
    ## File type: text/plain 
    ## Last modified: 2017-05-22 
    ## Access: Shared with specific people.

Update sharing
--------------

``` r
file <- drive_share(file, role = "writer", type = "user", emailAddress = "dagostino.mcgowan.stats@gmail.com",emailMessage = "I am sharing this cool file with you. Now you can write. You are welcome." )
```

    ## The permissions for file 'This is a test' have been updated

View permissions
----------------

``` r
file$permissions %>%
  select(displayName,role, type)
```

    ## # A tibble: 2 x 3
    ##                     displayName   role  type
    ##                           <chr>  <chr> <chr>
    ## 1           tidyverse testdrive  owner  user
    ## 2 D'Agostino McGowan Statistics writer  user

Make it fully shareable
-----------------------

``` r
file <- drive_share(file, role = "reader", type = "anyone", allowFileDiscovery = "true")
```

    ## The permissions for file 'This is a test' have been updated

Extract share link
------------------

``` r
drive_share_link(file)
```

    ## [1] "https://drive.google.com/file/d/0B0Gh-SuuA2nTdVhWRnJwTGgwZHc/view?usp=drivesdk"

*this looks exactly the same as the share link from the Google Drive GUI except `usp=drivesdk` instead of `usp=sharing`*

Delete file
-----------

``` r
drive_delete(file)
```

    ## The file 'This is a test' has been deleted from your Google Drive
