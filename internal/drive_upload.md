Playing with `drive_upload()` and `drive_update()`
================
Lucy D’Agostino McGowan
7/14/2017

``` r
library("googledrive")
library("testthat")
```

Let's upload a file.

``` r
drive_auth("drive-token.rds")
```

    ## Auto-refreshing stale OAuth token.

``` r
x <- drive_upload(system.file("DESCRIPTION"), "test-upload-lucy")
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

Overwrite using a `dribble`
---------------------------

Let's try to upload a file into that same location, using the `x` dribble object. This won't work with `drive_upload()`.

``` r
## this should error
y <- drive_upload(system.file("DESCRIPTION"), x)
```

    ## Error: Requested parent folder does not exist:
    ## test-upload-lucy

Let's use `drive_update()`. Now this should work.

``` r
y <- drive_update(system.file("DESCRIPTION"), x)
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTRzlBVDhvM2NkRkE

The `id`s for `x` and `y` should be identical.

``` r
identical(y$id, x$id)
```

    ## [1] TRUE

Overwrite using a character `path`
----------------------------------

``` r
y <- drive_update(system.file("DESCRIPTION"), "test-upload-lucy")
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTRzlBVDhvM2NkRkE

``` r
identical(y$id, x$id)
```

    ## [1] TRUE

If we use `drive_upload()`, it should still create the file. Now we will have 2 files in the same location with the same name.

``` r
y <- drive_upload(system.file("DESCRIPTION"), "test-upload-lucy")
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

Now the `id`s should no longer be identical.

``` r
!identical(x$id, y$id)
```

    ## [1] TRUE

``` r
drive_find("test-upload-lucy")
```

    ## # A tibble: 2 x 3
    ##               name                           id files_resource
    ## *            <chr>                        <chr>         <list>
    ## 1 test-upload-lucy 0B0Gh-SuuA2nTT2JQbHBqVGJhY0E    <list [32]>
    ## 2 test-upload-lucy 0B0Gh-SuuA2nTRzlBVDhvM2NkRkE    <list [33]>

If we try to overwrite *again*, we should receive an error, since we don't know which to overwrite.

``` r
z <- drive_update(system.file("DESCRIPTION"),
                  "test-upload-lucy")
```

    ## Error: Path to update is not unique:
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTT2JQbHBqVGJhY0E
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTRzlBVDhvM2NkRkE

Folders
-------

Let's make sure this plays nice with folders

``` r
folder <- drive_mkdir("test-folder-lucy")
```

    ## Folder created:
    ##   * test-folder-lucy

``` r
a <- drive_upload(system.file("DESCRIPTION"), folder, "test-upload-lucy")
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

Let's make sure `a` is actually in `folder`.

``` r
a_parent <- unlist(a$files_resource[[1]]$parents)
identical(a_parent, folder$id)
```

    ## [1] TRUE

``` r
b <- drive_update(system.file("DESCRIPTION"), a)
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTdk5nTVFBcnRtRE0

`b` should also exist in `folder`.

``` r
b_parent <- unlist(b$files_resource[[1]]$parents)
identical(b_parent, folder$id)
```

    ## [1] TRUE

If I try to stick it in a folder that does not exist, it should complain that the path is not on Drive. You will receive this error if you give any `path` but it does not exist on your Drive.

``` r
c <- drive_upload(system.file("DESCRIPTION"), "this is not a real folder", name = "new_name")
```

    ## Error: Input does not hold exactly one Drive file:
    ## path

Note: *if you want to update AND give it a new name, you have to use* `drive_rename()`.

clean up
--------

``` r
drive_rm(c("test-upload-lucy", "test-folder-lucy"))
```

    ## Files deleted:
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTdk5nTVFBcnRtRE0
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTT2JQbHBqVGJhY0E
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTRzlBVDhvM2NkRkE
    ##   * test-folder-lucy: 0B0Gh-SuuA2nTbFNtc3dyNVlGWTQ
