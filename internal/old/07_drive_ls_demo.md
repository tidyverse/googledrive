folders\_are\_weird
================
Lucy D’Agostino McGowan
5/11/2017

very brief demo

``` r
library(googledrive)
```

here is what my most recent files look like:
--------------------------------------------

``` r
drive_ls()
```

    ## # A tibble: 100 × 4
    ##                 name     type                                           id
    ##                <chr>    <chr>                                        <chr>
    ## 1                 yo   folder                 0Bw9rJumZU4vEQUFXQkZFbVZFNUU
    ## 2                 yo   folder                 0Bw9rJumZU4vESVNLemFsQ3c1bGc
    ## 3                bar   folder                 0Bw9rJumZU4vEd3d4ajJEQUdtUE0
    ## 4                baz   folder                 0Bw9rJumZU4vEVXgzVWpTM2llN0U
    ## 5                baz   folder                 0Bw9rJumZU4vEQlkyWlphTlZjYWc
    ## 6            my_file document 1fihkmyC76HCxvjYq6bVC4N2vG90G25FzfTBI6xe9sXg
    ## 7                bar   folder                 0Bw9rJumZU4vEU3dfY2lDZ21JRDQ
    ## 8                baz   folder                 0Bw9rJumZU4vEWEY5MjVFY0JnZG8
    ## 9                foo   folder                 0Bw9rJumZU4vEaTRsXzdhZkRtbEE
    ## 10 Untitled document document 1aJVWT_Yesc1hbzIx2JHZP32AzdWU2bcW2DavymisJ3Q
    ## # ... with 90 more rows, and 1 more variables: gfile <list>

Notice I have lots of folders named the same name!

now we can query by path
------------------------

``` r
drive_ls(path = "foo/bar/baz")
```

    ## # A tibble: 2 × 4
    ##      name     type                                           id
    ##     <chr>    <chr>                                        <chr>
    ## 1      yo   folder                 0Bw9rJumZU4vESVNLemFsQ3c1bGc
    ## 2 my_file document 1fihkmyC76HCxvjYq6bVC4N2vG90G25FzfTBI6xe9sXg
    ## # ... with 1 more variables: gfile <list>

In this subdirectory, I have 2 things, a folder named `yo` and a file named `my_file`.

can still pass other query parameters
-------------------------------------

``` r
drive_ls(path = "foo/bar/baz",q = "mimeType='application/vnd.google-apps.folder'")
```

    ## # A tibble: 1 × 4
    ##    name   type                           id       gfile
    ##   <chr>  <chr>                        <chr>      <list>
    ## 1    yo folder 0Bw9rJumZU4vESVNLemFsQ3c1bGc <list [27]>

can also pass patterns
----------------------

``` r
drive_ls(path = "foo/bar/baz", pattern = "my_file")
```

    ## # A tibble: 1 × 4
    ##      name     type                                           id
    ##     <chr>    <chr>                                        <chr>
    ## 1 my_file document 1fihkmyC76HCxvjYq6bVC4N2vG90G25FzfTBI6xe9sXg
    ## # ... with 1 more variables: gfile <list>
