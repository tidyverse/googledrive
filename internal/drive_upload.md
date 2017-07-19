Playing with `drive_upload()`
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

overwrite using a `dribble`
---------------------------

Let's try to upload a file into that same location, using the `x` dribble object.

``` r
## this should error
y <- drive_upload(system.file("DESCRIPTION"), x)
```

    ## Error: File already exists:
    ##   * test-upload-lucy
    ## Use `overwrite = TRUE` to upload new content into this file id.

Let's add set the parameter `overwrite = TRUE`. Now this should work.

``` r
y <- drive_upload(system.file("DESCRIPTION"), x, overwrite = TRUE)
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTVGVHczc4N1hCME0

The `id`s for `x` and `y` should be identical.

``` r
identical(y$id, x$id)
```

    ## [1] TRUE

overwrite using a character `path`
----------------------------------

``` r
y <- drive_upload(system.file("DESCRIPTION"), "test-upload-lucy", overwrite = TRUE)
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTVGVHczc4N1hCME0

``` r
identical(y$id, x$id)
```

    ## [1] TRUE

If we do not set the parameter `overwrite = TRUE`, it should still create the file when `path` is character. Now we will have 2 files in the same location with the same name.

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
    ## 1 test-upload-lucy 0B0Gh-SuuA2nTV1NzYWRKY2ttS28    <list [32]>
    ## 2 test-upload-lucy 0B0Gh-SuuA2nTVGVHczc4N1hCME0    <list [33]>

If we try to overwrite *again*, we should receive an error, since we don't know which to overwrite.

``` r
z <- drive_upload(system.file("DESCRIPTION"),
                  "test-upload-lucy",
                  overwrite = TRUE)
```

    ## Error in drive_upload(system.file("DESCRIPTION"), "test-upload-lucy", : Path to overwrite is not unique:
    ## * My Drive/test-upload-lucy

If we specify the `x` or `y` `dribble` as the `path`, however, we should still be able to overwrite.

``` r
z <- drive_upload(system.file("DESCRIPTION"), x, overwrite = TRUE)
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTVGVHczc4N1hCME0

``` r
identical(z$id, x$id)
```

    ## [1] TRUE

If we specify the `x` `dribble` as a `path`, AND specify a `name`, it will error that `x` is not a folder. If you specify BOTH a `path` and a `name`, the expectation is that the `path` is intended to be a folder.

You will receive the following error if you give a `name` AND you give something in `path` that DOES exist on your Drive, but that is NOT a folder.

``` r
z <- drive_upload(system.file("DESCRIPTION"), x, name = "new name", overwrite = TRUE)
```

    ## Error: Requested parent folder does not exist:
    ## * test-upload-lucy

folders
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
b <- drive_upload(system.file("DESCRIPTION"), a, overwrite = TRUE)
```

    ## File updated with new media:
    ##   * test-upload-lucy
    ## with id:
    ##   * 0B0Gh-SuuA2nTbmJ2MnBBYUtxOU0

`b` should also exist in `folder`.

``` r
b_parent <- unlist(b$files_resource[[1]]$parents)
identical(b_parent, folder$id)
```

    ## [1] TRUE

If I try to give it a new name, it should be okay now, since `folder` is a valid folder.

``` r
c <- drive_upload(system.file("DESCRIPTION"), folder, name = "new_name", overwrite = TRUE)
```

    ## File uploaded:
    ##   * new_name
    ## with MIME type:
    ##   * text/plain

If I try to stick it in a folder that does not exist, it should complain that the path is not on Drive. You will receive this error if you give any `path` but it does not exist on your Drive.

``` r
c <- drive_upload(system.file("DESCRIPTION"), "this is not a real folder", name = "new_name", overwrite = TRUE)
```

    ## Error: Input does not hold exactly one Drive file:
    ## path

Note: *if you want to overwrite AND give it a new name, you have to use* `drive_rename()`.

clean up
--------

``` r
drive_rm(c("test-upload-lucy", "test-folder-lucy"))
```

    ## Files deleted:
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTbmJ2MnBBYUtxOU0
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTV1NzYWRKY2ttS28
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTVGVHczc4N1hCME0
    ##   * test-folder-lucy: 0B0Gh-SuuA2nTWTJ4ZDZKcFFtRTQ
