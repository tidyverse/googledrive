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
expect_error(y <- drive_upload(system.file("DESCRIPTION"), x),
             "File already exists"
)
```

Let's add set the parameter `overwrite = TRUE`. Now this should work.

``` r
y <- drive_upload(system.file("DESCRIPTION"), x, overwrite = TRUE)
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

The `id`s for `x` and `y` should be identical.

``` r
expect_identical(y$id, x$id)
```

overwrite using a `name`
------------------------

``` r
y <- drive_upload(system.file("DESCRIPTION"), "test-upload-lucy", overwrite = TRUE)
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

``` r
expect_identical(y$id, x$id)
```

If we do not set the parameter `overwrite = TRUE`, it should still create the file. Now we will have 2 files in the same location with the same name.

``` r
y <- drive_upload(system.file("DESCRIPTION"), "test-upload-lucy")
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

Now the `id`s should no longer be identical.

``` r
expect_false(x$id == y$id)
```

``` r
drive_find("test-upload-lucy")
```

    ## # A tibble: 2 x 3
    ##               name                           id files_resource
    ## *            <chr>                        <chr>         <list>
    ## 1 test-upload-lucy 0B0Gh-SuuA2nTTnRKWkRsLTJ1LUE    <list [32]>
    ## 2 test-upload-lucy 0B0Gh-SuuA2nTdXRiOUl4N2F4VXc    <list [33]>

If we try to overwrite *again*, we should receive an error, since we don't know which to overwrite.

``` r
expect_error(
  z <- drive_upload(system.file("DESCRIPTION"),
                    "test-upload-lucy",
                    overwrite = TRUE),
  "Path to overwrite is not unique"
)
```

If we use the `x` or `y` `dribble`, however, we should still be able to overwrite.

``` r
z <- drive_upload(system.file("DESCRIPTION"), x, overwrite = TRUE)
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

``` r
expect_equal(z$id, x$id)
```

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
expect_equal(a_parent, folder$id)
```

``` r
b <- drive_upload(system.file("DESCRIPTION"), a, overwrite = TRUE)
```

    ## File uploaded:
    ##   * test-upload-lucy
    ## with MIME type:
    ##   * text/plain

`b` should also exist in `folder`.

``` r
b_parent <- unlist(b$files_resource[[1]]$parents)
expect_equal(b_parent, folder$id)
```

If I try to give it a new name, it should error.

``` r
expect_error(
  c <- drive_upload(system.file("DESCRIPTION"), b, name = "new_name", overwrite = TRUE),
  "Requested parent folder does not exist"
)
```

*hmm is this a sensible error? it definitely makes sense in some circumstances but...*

Note: \*if you want to overwrite AND give it a new name, you have to use `drive_rename()`.

clean up
--------

``` r
drive_rm("test-upload-lucy")
```

    ## Files deleted:
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTdUZ1Q3QxOEE0VEE
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTTnRKWkRsLTJ1LUE
    ##   * test-upload-lucy: 0B0Gh-SuuA2nTdXRiOUl4N2F4VXc
