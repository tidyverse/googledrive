googledrive test setup
================
jenny
2017-07-25 22:02:03

This script aggregates the test-related setup code from all test files.

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
SETUP <- FALSE
```

test-drive\_cp.R
----------------

``` r
nm_ <- nm_fun("-TEST-drive-cp")
if (SETUP) {
  drive_mkdir(nm_("i-am-a-folder"))
  drive_mkdir(nm_("not-unique-folder"))
  drive_mkdir(nm_("not-unique-folder"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("i-am-a-file")
  )
}
```

test-drive\_download.R
----------------------

``` r
nm_ <- nm_fun("-TEST-drive-download")
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("DESC"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC-doc"),
    type = "document"
  )
}
```

test-drive\_find.R
------------------

``` r
nm_ <- nm_fun("-TEST-drive-find")
if (SETUP) {
  drive_mkdir(nm_("foo"))
}
```

test-drive\_get.R
-----------------

``` r
nm_ <- nm_fun("-TEST-drive-get")
if (SETUP) {
  file_in_root <- drive_upload(
    system.file("DESCRIPTION"),
    name = nm_("thing01")
  )
  drive_upload(system.file("DESCRIPTION"), name = nm_("thing02"))
  drive_upload(system.file("DESCRIPTION"), name = nm_("thing03"))
  folder_in_root <- drive_mkdir(nm_("thing01"))
  folder_in_folder <- drive_mkdir(folder_in_root, name = nm_("thing01"))
  file_in_folder_in_folder <- drive_cp(
    file_in_root,
    path = folder_in_folder,
    name = nm_("thing01")
  )
  drive_upload(
    system.file("DESCRIPTION"),
    path = folder_in_root,
    name = nm_("thing04")
  )

  folder_1_of_2 <- drive_mkdir(nm_("parent01"))
  folder_2_of_2 <- drive_mkdir(nm_("parent02"))
  child_of_2_parents <- drive_upload(
    system.file("DESCRIPTION"),
    path = folder_1_of_2,
    name = nm_("child_of_2_parents")
  )
  ## not an exported function
  drive_add_parent(child_of_2_parents, folder_2_of_2)
}
```

test-drive\_ls.R
----------------

``` r
nm_ <- nm_fun("-TEST-drive-ls")
if (SETUP) {
  drive_mkdir(nm_("list-me"))
  drive_upload(
    system.file("DESCRIPTION"),
    path = file.path(nm_("list-me"), nm_("DESCRIPTION"))
  )
  drive_upload(
    R.home('doc/html/about.html'),
    path = file.path(nm_("list-me"), nm_("about-html"))
  )
}
```

test-drive\_mkdir.R
-------------------

``` r
nm_ <- nm_fun("-TEST-drive-mkdir")
if (SETUP) {
  drive_mkdir(nm_("OMNI-PARENT"))
}
```

test-drive\_mv.R
----------------

``` r
nm_ <- nm_fun("-TEST-drive-mv")
if (SETUP) {
  drive_mkdir(nm_("move-files-into-me"))
}
```

test-drive\_publish.R
---------------------

``` r
nm_ <- nm_fun("-TEST-drive-publish")
if (SETUP) {
  drive_upload(R.home('doc/html/about.html'),
               name = nm_("foo_doc"),
               type = "document")
  drive_upload(R.home('doc/BioC_mirrors.csv'),
               name = nm_("foo_sheet"),
               type = "spreadsheet")
  drive_upload(R.home('doc/html/Rlogo.pdf'),
               name = nm_("foo_pdf"))
}
```

test-drive\_share.R
-------------------

``` r
nm_ <- nm_fun("-TEST-drive-share")
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("DESC"))
}
```

test-drive\_trash.R
-------------------

``` r
nm_ <- nm_fun("-TEST-drive-trash")
if (SETUP) {
  drive_mkdir(nm_("foo"))
}
```

test-drive\_update.R
--------------------

``` r
nm_ <- nm_fun("-TEST-drive-update")
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("update_me"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
}
```

test-drive\_upload.R
--------------------

``` r
nm_ <- nm_fun("-TEST-drive-upload")
if (SETUP) {
  drive_mkdir(nm_("upload-into-me"))
}
```
