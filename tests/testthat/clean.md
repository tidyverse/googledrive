googledrive test clean
================
jenny
2017-07-25 22:03:33

This script aggregates the test-related clean code from all test files.

``` r
library(googledrive)
source('helper.R')
```

    ## Auto-refreshing stale OAuth token.

``` r
whoami <- drive_user()$user
whoami[c('displayName', 'emailAddress')]
```

    ## $displayName
    ## [1] "tidyverse testdrive"
    ## 
    ## $emailAddress
    ## [1] "tidyverse.testdrive@gmail.com"

``` r
## change this to TRUE when you are really ready to do this!
CLEAN <- TRUE
```

test-drive\_cp.R
----------------

``` r
nm_ <- nm_fun("-TEST-drive-cp")
if (CLEAN) {
  drive_rm(c(
    nm_("i-am-a-folder"),
    nm_("not-unique-folder"),
    nm_("i-am-a-file")
  ))
}
```

    ## Files deleted:
    ##   * i-am-a-folder-TEST-drive-cp: 0B0Gh-SuuA2nTRzZrNW5IZHNDSXc
    ##   * not-unique-folder-TEST-drive-cp: 0B0Gh-SuuA2nTY3hOdS1jUTZkN0U
    ##   * not-unique-folder-TEST-drive-cp: 0B0Gh-SuuA2nTLUNLNTU0VnFCZHc
    ##   * i-am-a-file-TEST-drive-cp: 0B0Gh-SuuA2nTWXJYRjUzeDdXc2c

test-drive\_download.R
----------------------

``` r
nm_ <- nm_fun("-TEST-drive-download")
if (CLEAN) {
  drive_rm(c(
    nm_("DESC"),
    nm_("DESC-doc")
  ))
}
```

    ## Files deleted:
    ##   * DESC-TEST-drive-download: 0B0Gh-SuuA2nTUkVCTU5xQVFhbkE
    ##   * DESC-doc-TEST-drive-download: 1KQsfsA-d9eKG_Hrf1tmgKlEahatdy8y5wmUTU2cv5XU

test-drive\_find.R
------------------

``` r
nm_ <- nm_fun("-TEST-drive-find")
if (CLEAN) {
  drive_rm(c(
    nm_("foo"),
    nm_("this-should-not-exist")
  ))
}
```

    ## No such files found to delete.

test-drive\_get.R
-----------------

``` r
nm_ <- nm_fun("-TEST-drive-get")
if (CLEAN) {
  files <- drive_find(nm_("thing0[1234]"))
  drive_rm(files)
}
```

    ## Files deleted:
    ##   * thing04-TEST-drive-get: 0B0Gh-SuuA2nTLXpuWlFkSzRtQjA
    ##   * thing03-TEST-drive-get: 0B0Gh-SuuA2nTUE5KTWhWcTZGWE0
    ##   * thing01-TEST-drive-get: 0B0Gh-SuuA2nTQWZUSHpDWTN0aUE
    ##   * thing01-TEST-drive-get: 0B0Gh-SuuA2nTRGh1MkFqNGNTVFE
    ##   * thing01-TEST-drive-get: 0B0Gh-SuuA2nTMndiSG1OMDYtbVU
    ##   * thing02-TEST-drive-get: 0B0Gh-SuuA2nTYUVNMVowVkxWbUU
    ##   * thing01-TEST-drive-get: 0B0Gh-SuuA2nTUUNETU5QQVFJQm8

test-drive\_ls.R
----------------

``` r
nm_ <- nm_fun("-TEST-drive-ls")
if (CLEAN) {
  drive_rm(c(
    nm_("list-me"),
    nm_("this-should-not-exist")
  ))
}
```

    ## Files deleted:
    ##   * list-me-TEST-drive-ls: 0B0Gh-SuuA2nTSkk5R2M5cDhKUW8

test-drive\_mkdir.R
-------------------

``` r
nm_ <- nm_fun("-TEST-drive-mkdir")
if (CLEAN) {
  drive_rm(c(
    nm_("OMNI-PARENT"),
    nm_("I-live-in-root")
  ))
}
```

    ## Files deleted:
    ##   * OMNI-PARENT-TEST-drive-mkdir: 0B0Gh-SuuA2nTZlA0aWtMczVkMmM

test-drive\_mv.R
----------------

``` r
nm_ <- nm_fun("-TEST-drive-mv")
if (CLEAN) {
  drive_rm(c(
    nm_("move-files-into-me"),
    nm_("DESC"),
    nm_("DESC-renamed")
  ))
}
```

    ## Files deleted:
    ##   * move-files-into-me-TEST-drive-mv: 0B0Gh-SuuA2nTZUliMFJMYjRDbXc

test-drive\_publish.R
---------------------

``` r
nm_ <- nm_fun("-TEST-drive-publish")
if (CLEAN) {
  drive_rm(c(
    nm_("foo_pdf"),
    nm_("foo_doc"),
    nm_("foo_sheet")
  ))
}
```

    ## Files deleted:
    ##   * foo_pdf-TEST-drive-publish: 0B0Gh-SuuA2nTNnBVQ0swd2ZOc3c
    ##   * foo_doc-TEST-drive-publish: 1BnrHhb_3Oi5CQ_iW5smjnOMd5wEZgqsxEPKT5cIpFq8
    ##   * foo_sheet-TEST-drive-publish: 1pilzyxMIdCPGajdXhG3wHytx2NH_8ob5PtrQC2ScpjA

test-drive\_share.R
-------------------

``` r
nm_ <- nm_fun("-TEST-drive-share")
if (CLEAN) {
  drive_rm(c(
    nm_("mirrors-to-share"),
    nm_("DESC")
  ))
}
```

    ## Files deleted:
    ##   * DESC-TEST-drive-share: 0B0Gh-SuuA2nTamI4TEZsY1Q5aGc

test-drive\_trash.R
-------------------

``` r
nm_ <- nm_fun("-TEST-drive-trash")
if (CLEAN) {
  drive_rm(nm_("foo"))
}
```

    ## Files deleted:
    ##   * foo-TEST-drive-trash: 0B0Gh-SuuA2nTTFowaGFxaWN5ekk

test-drive\_update.R
--------------------

``` r
nm_ <- nm_fun("-TEST-drive-update")
if (CLEAN) {
  drive_rm(c(
    nm_("update-me"),
    nm_("not-unique"),
    nm_("does-not-exist")
  ))
}
```

    ## Files deleted:
    ##   * not-unique-TEST-drive-update: 0B0Gh-SuuA2nTT0FkaTBGSGI1UHc
    ##   * not-unique-TEST-drive-update: 0B0Gh-SuuA2nTZ0tQdlVTUDZNUms

test-drive\_upload.R
--------------------

``` r
nm_ <- nm_fun("-TEST-drive-upload")
if (CLEAN) {
  drive_rm(c(
    nm_("upload-into-me"),
    nm_("DESCRIPTION")
  ))
}
```

    ## Files deleted:
    ##   * upload-into-me-TEST-drive-upload: 0B0Gh-SuuA2nTdnMyY2NCMGhiVjg
