# Dealing with multiple files

Some googledrive functions are built to naturally handle multiple files,
while others operate on a single file.

Functions that expect a single file:

- [`drive_browse()`](https://googledrive.tidyverse.org/dev/reference/drive_browse.md)  
- [`drive_cp()`](https://googledrive.tidyverse.org/dev/reference/drive_cp.md)  
- [`drive_download()`](https://googledrive.tidyverse.org/dev/reference/drive_download.md)
- [`drive_ls()`](https://googledrive.tidyverse.org/dev/reference/drive_ls.md)
- [`drive_mv()`](https://googledrive.tidyverse.org/dev/reference/drive_mv.md)  
- [`drive_put()`](https://googledrive.tidyverse.org/dev/reference/drive_put.md)
- [`drive_rename()`](https://googledrive.tidyverse.org/dev/reference/drive_rename.md)  
- [`drive_update()`](https://googledrive.tidyverse.org/dev/reference/drive_update.md)
- [`drive_upload()`](https://googledrive.tidyverse.org/dev/reference/drive_upload.md)

Functions that allow multiple files:

- [`drive_publish()`](https://googledrive.tidyverse.org/dev/reference/drive_publish.md)  
- [`drive_reveal()`](https://googledrive.tidyverse.org/dev/reference/drive_reveal.md)  
- [`drive_rm()`](https://googledrive.tidyverse.org/dev/reference/drive_rm.md)  
- [`drive_share()`](https://googledrive.tidyverse.org/dev/reference/drive_share.md)  
- [`drive_trash()`](https://googledrive.tidyverse.org/dev/reference/drive_trash.md)

In general, the principle is: if there are multiple parameters that are
likely to vary across multiple files, the function is designed to take a
single input. In order to use these function with multiple inputs, use
them together with your favorite approach for iteration in R. Below is a
worked example, focusing on tools in the tidyverse, namely the
[`map()`](https://purrr.tidyverse.org/reference/map.html) functions in
purrr.

## Upload multiple files, then rename them

Scenario: we have multiple local files we want to upload into a folder
on Drive. Then we regret their original names and want to rename them.

Load packages.

``` r
library(googledrive)
library(glue)
library(tidyverse)
```

### Upload

Use the example files that ship with googledrive.

``` r
local_files <- drive_examples_local()
local_files <- set_names(local_files, basename(local_files))
local_files
#>                                                                         chicken.csv 
#>     "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.csv" 
#>                                                                         chicken.jpg 
#>     "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.jpg" 
#>                                                                         chicken.pdf 
#>     "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.pdf" 
#>                                                                         chicken.txt 
#>     "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.txt" 
#>                                                                     imdb_latin1.csv 
#> "/home/runner/work/_temp/Library/googledrive/extdata/example_files/imdb_latin1.csv" 
#>                                                                         markdown.md 
#>     "/home/runner/work/_temp/Library/googledrive/extdata/example_files/markdown.md" 
#>                                                                        r_about.html 
#>    "/home/runner/work/_temp/Library/googledrive/extdata/example_files/r_about.html" 
#>                                                                          r_logo.jpg 
#>      "/home/runner/work/_temp/Library/googledrive/extdata/example_files/r_logo.jpg"
```

Create a folder on your Drive and upload all files into this folder by
iterating over the `local_files` using
[`purrr::map()`](https://purrr.tidyverse.org/reference/map.html).

``` r
folder <- drive_mkdir("upload-into-me-article-demo")
#> Created Drive file:
#> • upload-into-me-article-demo <id: 1UeAWJypFoEBAW9XEcDFRA6Bdr0ZgMd8G>
#> With MIME type:
#> • application/vnd.google-apps.folder
with_drive_quiet(
  files <- map(local_files, ~ drive_upload(.x, path = folder))
)
```

First, let’s confirm that we uploaded the files into the new folder.

``` r
drive_ls(folder)
#> # A dribble: 8 × 3
#>   name            id                                drive_resource   
#>   <chr>           <drv_id>                          <list>           
#> 1 r_logo.jpg      19Da8rn48FDAeZlHs8Qq3cljVX39TUIks <named list [45]>
#> 2 r_about.html    1Xg-7W6Kdiu0jzEAtq_5eW3Z-JODgtyRE <named list [44]>
#> 3 markdown.md     1F3eD_DzUn9pVbEIZVv_ws82QsWHAHUbw <named list [43]>
#> 4 imdb_latin1.csv 1SAlVQP3BvYapPmTMGBNm66nX2KTmwjzO <named list [43]>
#> 5 chicken.txt     1jJReX2nkxrLKxyQLmYP4aw6KctmnZUbJ <named list [44]>
#> 6 chicken.pdf     1L0zrqo0AoGgOxaSJ8A6HV4lFmNnbQ1hI <named list [44]>
#> 7 chicken.jpg     1XO4RN_jHf5HXty5XqIIFfmHaJmmsc-g5 <named list [45]>
#> 8 chicken.csv     1m9wdrpqT53pJC8kujTXo_EyqKX1pro5u <named list [44]>
```

Now let’s reflect on the `files` object returned by this operation.
`files` is a list of **dribbles**, one per uploaded file.

``` r
str(files, max.level = 1)
#> List of 8
#>  $ chicken.csv    : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ chicken.jpg    : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ chicken.pdf    : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ chicken.txt    : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ imdb_latin1.csv: dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ markdown.md    : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ r_about.html   : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
#>  $ r_logo.jpg     : dribble [1 × 3] (S3: dribble/tbl_df/tbl/data.frame)
```

This would be a favorable data structure if you’ve got more
[`map()`](https://purrr.tidyverse.org/reference/map.html)ing to do, as
you’ll see below.

But what if not? You can always row bind individual dribbles into one
big dribble yourself with, e.g.,
[`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html).

``` r
bind_rows(files)
#> # A dribble: 8 × 3
#>   name            id                                drive_resource   
#>   <chr>           <drv_id>                          <list>           
#> 1 chicken.csv     1m9wdrpqT53pJC8kujTXo_EyqKX1pro5u <named list [43]>
#> 2 chicken.jpg     1XO4RN_jHf5HXty5XqIIFfmHaJmmsc-g5 <named list [45]>
#> 3 chicken.pdf     1L0zrqo0AoGgOxaSJ8A6HV4lFmNnbQ1hI <named list [43]>
#> 4 chicken.txt     1jJReX2nkxrLKxyQLmYP4aw6KctmnZUbJ <named list [43]>
#> 5 imdb_latin1.csv 1SAlVQP3BvYapPmTMGBNm66nX2KTmwjzO <named list [43]>
#> 6 markdown.md     1F3eD_DzUn9pVbEIZVv_ws82QsWHAHUbw <named list [43]>
#> 7 r_about.html    1Xg-7W6Kdiu0jzEAtq_5eW3Z-JODgtyRE <named list [43]>
#> 8 r_logo.jpg      19Da8rn48FDAeZlHs8Qq3cljVX39TUIks <named list [45]>
```

Below we show another way to finesse this by using a variant of
[`purrr::map()`](https://purrr.tidyverse.org/reference/map.html) that
does this for us, namely
[`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html).

### Rename

Imagine that we now wish these file names had a date prefix. First, form
the new names. We use
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) for
string interpolation but you could also use
[`paste()`](https://rdrr.io/r/base/paste.html). Second, we map over two
inputs: the list of dribbles from above and the vector of new names.

``` r
(new_names <- glue("{Sys.Date()}_{basename(local_files)}"))
#> 2025-12-29_chicken.csv
#> 2025-12-29_chicken.jpg
#> 2025-12-29_chicken.pdf
#> 2025-12-29_chicken.txt
#> 2025-12-29_imdb_latin1.csv
#> 2025-12-29_markdown.md
#> 2025-12-29_r_about.html
#> 2025-12-29_r_logo.jpg
files_dribble <- map2_dfr(files, new_names, drive_rename)
#> Original file:
#> • chicken.csv <id: 1m9wdrpqT53pJC8kujTXo_EyqKX1pro5u>
#> Has been renamed:
#> • 2025-12-29_chicken.csv <id: 1m9wdrpqT53pJC8kujTXo_EyqKX1pro5u>
#> Original file:
#> • chicken.jpg <id: 1XO4RN_jHf5HXty5XqIIFfmHaJmmsc-g5>
#> Has been renamed:
#> • 2025-12-29_chicken.jpg <id: 1XO4RN_jHf5HXty5XqIIFfmHaJmmsc-g5>
#> Original file:
#> • chicken.pdf <id: 1L0zrqo0AoGgOxaSJ8A6HV4lFmNnbQ1hI>
#> Has been renamed:
#> • 2025-12-29_chicken.pdf <id: 1L0zrqo0AoGgOxaSJ8A6HV4lFmNnbQ1hI>
#> Original file:
#> • chicken.txt <id: 1jJReX2nkxrLKxyQLmYP4aw6KctmnZUbJ>
#> Has been renamed:
#> • 2025-12-29_chicken.txt <id: 1jJReX2nkxrLKxyQLmYP4aw6KctmnZUbJ>
#> Original file:
#> • imdb_latin1.csv <id: 1SAlVQP3BvYapPmTMGBNm66nX2KTmwjzO>
#> Has been renamed:
#> • 2025-12-29_imdb_latin1.csv <id: 1SAlVQP3BvYapPmTMGBNm66nX2KTmwjzO>
#> Original file:
#> • markdown.md <id: 1F3eD_DzUn9pVbEIZVv_ws82QsWHAHUbw>
#> Has been renamed:
#> • 2025-12-29_markdown.md <id: 1F3eD_DzUn9pVbEIZVv_ws82QsWHAHUbw>
#> Original file:
#> • r_about.html <id: 1Xg-7W6Kdiu0jzEAtq_5eW3Z-JODgtyRE>
#> Has been renamed:
#> • 2025-12-29_r_about.html <id: 1Xg-7W6Kdiu0jzEAtq_5eW3Z-JODgtyRE>
#> Original file:
#> • r_logo.jpg <id: 19Da8rn48FDAeZlHs8Qq3cljVX39TUIks>
#> Has been renamed:
#> • 2025-12-29_r_logo.jpg <id: 19Da8rn48FDAeZlHs8Qq3cljVX39TUIks>
```

We use
[`purrr::map2_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html)
to work through `files`, the list of dribbles (= Drive files), and
`new_names`, the vector of new names, and row bind the returned dribbles
into a single dribble holding all files.

Let’s check on the contents of this folder again to confirm the new
names:

``` r
drive_ls(folder)
#> # A dribble: 8 × 3
#>   name                       id       drive_resource   
#>   <chr>                      <drv_id> <list>           
#> 1 2025-12-29_r_logo.jpg      19Da8rn… <named list [45]>
#> 2 2025-12-29_r_about.html    1Xg-7W6… <named list [44]>
#> 3 2025-12-29_markdown.md     1F3eD_D… <named list [43]>
#> 4 2025-12-29_imdb_latin1.csv 1SAlVQP… <named list [43]>
#> 5 2025-12-29_chicken.txt     1jJReX2… <named list [44]>
#> 6 2025-12-29_chicken.pdf     1L0zrqo… <named list [44]>
#> 7 2025-12-29_chicken.jpg     1XO4RN_… <named list [45]>
#> 8 2025-12-29_chicken.csv     1m9wdrp… <named list [44]>
```

Let’s confirm that, by using `map2_df2()` instead of
[`map2()`](https://purrr.tidyverse.org/reference/map2.html), we got a
single dribble back, instead of a list of one-row dribbles:

``` r
files_dribble
#> # A dribble: 8 × 3
#>   name                       id       drive_resource   
#>   <chr>                      <drv_id> <list>           
#> 1 2025-12-29_chicken.csv     1m9wdrp… <named list [44]>
#> 2 2025-12-29_chicken.jpg     1XO4RN_… <named list [45]>
#> 3 2025-12-29_chicken.pdf     1L0zrqo… <named list [44]>
#> 4 2025-12-29_chicken.txt     1jJReX2… <named list [44]>
#> 5 2025-12-29_imdb_latin1.csv 1SAlVQP… <named list [43]>
#> 6 2025-12-29_markdown.md     1F3eD_D… <named list [43]>
#> 7 2025-12-29_r_about.html    1Xg-7W6… <named list [44]>
#> 8 2025-12-29_r_logo.jpg      19Da8rn… <named list [45]>
```

What if you wanted to get a list back, because your downstream
operations include yet more
[`map()`](https://purrr.tidyverse.org/reference/map.html)ing? Then you
would use [`map2()`](https://purrr.tidyverse.org/reference/map2.html).

``` r
files_list <- map2(files, new_names, drive_rename)
```

### Clean up

Our trashing function,
[`drive_trash()`](https://googledrive.tidyverse.org/dev/reference/drive_trash.md)
is vectorized and can therefore operate on a multi-file dribble. We
could trash these files like so:

``` r
drive_trash(files_dribble)
```

If you’re absolutely sure of yourself and happy to do something
irreversible, you could truly delete these files with
[`drive_rm()`](https://googledrive.tidyverse.org/dev/reference/drive_rm.md),
which is also vectorized:

``` r
drive_rm(files_dribble)
```

Finally – and this is the code we will actually execute – the easiest
way to delete these files is to delete their enclosing folder.

``` r
drive_rm(folder)
#> File deleted:
#> • upload-into-me-article-demo <id: 1UeAWJypFoEBAW9XEcDFRA6Bdr0ZgMd8G>
```
