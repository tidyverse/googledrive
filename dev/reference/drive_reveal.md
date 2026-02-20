# Add a new column of Drive file information

`drive_reveal()` adds extra information about your Drive files that is
not readily available in the default
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
produced by googledrive. Why is this info not always included in the
default `dribble`?

- You don't always care about it. There is a lot of esoteric information
  in the `drive_resource` that has little value for most users.

- It might be "expensive" to get this information and put it into a
  usable form. For example, revealing a file's `"path"`,
  `"permissions"`, or `"published"` status all require additional API
  calls.

`drive_reveal()` can also **hoist** any property out of the
`drive_resource` list-column, when the property's name is passed as the
`what` argument. The resulting new column is simplified if it is easy to
do so, e.g., if the individual elements are all string or logical. If
`what` extracts a date-time, we return
[`POSIXct`](https://rdrr.io/r/base/DateTimeClasses.html). Otherwise,
you'll get a list-column. If this makes you sad, consider using
[`tidyr::hoist()`](https://tidyr.tidyverse.org/reference/hoist.html)
instead. It is more powerful due to a richer "plucking specification"
and its `ptype` and `transform` arguments. Another useful function is
[`tidyr::unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html).

## Usage

``` r
drive_reveal(file, what = c("path", "permissions", "published", "parent"))
```

## Arguments

- file:

  Something that identifies the file(s) of interest on your Google
  Drive. Can be a character vector of names/paths, a character vector of
  file ids or URLs marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- what:

  Character, describing the type of info you want to add. These values
  get special handling (more details below):

  - `path`

  - `permissions`

  - `published`

  - `parent`

  You can also request any property in the `drive_resource` column by
  name. The request can be in `camelCase` or `snake_case`, but the new
  column name will always be `snake_case`. Some examples of `what`:

  - `mime_type` (or `mimeType`)

  - `trashed`

  - `starred`

  - `description`

  - `version`

  - `web_view_link` (or `webViewLink`)

  - `modified_time` (or `modifiedTime`)

  - `created_time` (or `createdTime`)

  - `owned_by_me` (or `ownedByMe`)

  - `size`

  - `quota_bytes_used` (or `quotaBytesUsed`)

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a tibble with one row per file. The additional info requested via `what`
appears in one (or more) extra columns.

## File path

When `what = "path"` the
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
gains a character column holding each file's path. This can be *very
slow*, so use with caution.

The example path `~/a/b/` illustrates two conventions used in
googledrive:

- The leading `~/` means that the folder `a` is located in the current
  user's "My Drive" root folder.

- The trailing `/` means that `b`, located in `a`, is *a folder or a
  folder shortcut*.

## Permissions

When `what = "permissions"` the
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
gains a logical column `shared` that indicates whether a file is shared
and a new list-column `permissions_resource` containing lists of
[Permissions
resources](https://developers.google.com/drive/api/v3/reference/permissions).

## Publishing

When `what = "published"` the
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
gains a logical column `published` that indicates whether a file is
published and a new list-column `revision_resource` containing lists of
[Revisions
resources](https://developers.google.com/drive/api/v3/reference/revisions).

## Parent

When `what = "parent"` the
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
gains a character column `id_parent` that is the file id of this item's
parent folder. This information is available in the `drive_resource`,
but can't just be hoisted out:

- Google Drive used to allow files to have multiple parents, but this is
  no longer supported and googledrive now assumes this is impossible.
  However, we have seen (very old) files that still have \>1 parent
  folder. If we see this we message about it and drop all but the first
  parent.

- The `parents` property in `drive_resource` has an "extra" layer of
  nesting and needs to be flattened.

If you really want the raw `parents` property, call
`drive_reveal(what = "parents")`.

## See also

To learn more about the properties present in the metadata of a Drive
file (which is what's in the `drive_resource` list-column of a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)),
see the API docs:

- <https://developers.google.com/drive/api/v3/reference/files#resource-representations>

## Examples

``` r
# Get a few of your files
files <- drive_find(n_max = 10, trashed = NA)

# the "special" cases that require additional API calls and can be slow
drive_reveal(files, "path")
#> # A dribble: 10 × 4
#>    name                 path                   id       drive_resource
#>    <chr>                <chr>                  <drv_id> <list>        
#>  1 name-squatter-rename ~/name-squatter-rename 1zyeygh… <named list>  
#>  2 name-squatter-mv     ~/name-squatter-mv     11BX-ac… <named list>  
#>  3 name-squatter-upload ~/name-squatter-upload 1BJ22jo… <named list>  
#>  4 name-squatter-rename ~/name-squatter-rename 1vcfucc… <named list>  
#>  5 name-squatter-mv     ~/name-squatter-mv     1PsenIZ… <named list>  
#>  6 name-squatter-upload ~/name-squatter-upload 1y0aNbI… <named list>  
#>  7 name-squatter-rename ~/name-squatter-rename 1_geS-7… <named list>  
#>  8 name-squatter-mv     ~/name-squatter-mv     12Qf1Vn… <named list>  
#>  9 name-squatter-upload ~/name-squatter-upload 13b89cb… <named list>  
#> 10 name-squatter-rename ~/name-squatter-rename 1_KLIz8… <named list>  
drive_reveal(files, "permissions")
#> # A dribble: 10 × 5
#>    name             shared id       drive_resource permissions_resource
#>    <chr>            <lgl>  <drv_id> <list>         <list>              
#>  1 name-squatter-r… FALSE  1zyeygh… <named list>   <named list [2]>    
#>  2 name-squatter-mv FALSE  11BX-ac… <named list>   <named list [2]>    
#>  3 name-squatter-u… FALSE  1BJ22jo… <named list>   <named list [2]>    
#>  4 name-squatter-r… FALSE  1vcfucc… <named list>   <named list [2]>    
#>  5 name-squatter-mv FALSE  1PsenIZ… <named list>   <named list [2]>    
#>  6 name-squatter-u… FALSE  1y0aNbI… <named list>   <named list [2]>    
#>  7 name-squatter-r… FALSE  1_geS-7… <named list>   <named list [2]>    
#>  8 name-squatter-mv FALSE  12Qf1Vn… <named list>   <named list [2]>    
#>  9 name-squatter-u… FALSE  13b89cb… <named list>   <named list [2]>    
#> 10 name-squatter-r… FALSE  1_KLIz8… <named list>   <named list [2]>    
drive_reveal(files, "published")
#> # A dribble: 10 × 5
#>    name             published id       drive_resource revision_resource
#>    <chr>            <lgl>     <drv_id> <list>         <list>           
#>  1 name-squatter-r… FALSE     1zyeygh… <named list>   <named list [9]> 
#>  2 name-squatter-mv FALSE     11BX-ac… <named list>   <named list [9]> 
#>  3 name-squatter-u… FALSE     1BJ22jo… <named list>   <named list [9]> 
#>  4 name-squatter-r… FALSE     1vcfucc… <named list>   <named list [9]> 
#>  5 name-squatter-mv FALSE     1PsenIZ… <named list>   <named list [9]> 
#>  6 name-squatter-u… FALSE     1y0aNbI… <named list>   <named list [9]> 
#>  7 name-squatter-r… FALSE     1_geS-7… <named list>   <named list [9]> 
#>  8 name-squatter-mv FALSE     12Qf1Vn… <named list>   <named list [9]> 
#>  9 name-squatter-u… FALSE     13b89cb… <named list>   <named list [9]> 
#> 10 name-squatter-r… FALSE     1_KLIz8… <named list>   <named list [9]> 

# a "special" case of digging info out of `drive_resource`, then processing
# a bit
drive_reveal(files, "parent")
#> # A dribble: 10 × 4
#>    name                 id_parent           id       drive_resource   
#>    <chr>                <drv_id>            <drv_id> <list>           
#>  1 name-squatter-rename 0AO_RMaBzcP63Uk9PVA 1zyeygh… <named list [41]>
#>  2 name-squatter-mv     0AO_RMaBzcP63Uk9PVA 11BX-ac… <named list [41]>
#>  3 name-squatter-upload 0AO_RMaBzcP63Uk9PVA 1BJ22jo… <named list [41]>
#>  4 name-squatter-rename 0AO_RMaBzcP63Uk9PVA 1vcfucc… <named list [41]>
#>  5 name-squatter-mv     0AO_RMaBzcP63Uk9PVA 1PsenIZ… <named list [41]>
#>  6 name-squatter-upload 0AO_RMaBzcP63Uk9PVA 1y0aNbI… <named list [41]>
#>  7 name-squatter-rename 0AO_RMaBzcP63Uk9PVA 1_geS-7… <named list [41]>
#>  8 name-squatter-mv     0AO_RMaBzcP63Uk9PVA 12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload 0AO_RMaBzcP63Uk9PVA 13b89cb… <named list [41]>
#> 10 name-squatter-rename 0AO_RMaBzcP63Uk9PVA 1_KLIz8… <named list [41]>

# the "simple" cases of digging info out of `drive_resource`
drive_reveal(files, "trashed")
#> # A dribble: 10 × 4
#>    name                 trashed id       drive_resource   
#>    <chr>                <lgl>   <drv_id> <list>           
#>  1 name-squatter-rename TRUE    1zyeygh… <named list [41]>
#>  2 name-squatter-mv     TRUE    11BX-ac… <named list [41]>
#>  3 name-squatter-upload TRUE    1BJ22jo… <named list [41]>
#>  4 name-squatter-rename TRUE    1vcfucc… <named list [41]>
#>  5 name-squatter-mv     TRUE    1PsenIZ… <named list [41]>
#>  6 name-squatter-upload TRUE    1y0aNbI… <named list [41]>
#>  7 name-squatter-rename TRUE    1_geS-7… <named list [41]>
#>  8 name-squatter-mv     TRUE    12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload TRUE    13b89cb… <named list [41]>
#> 10 name-squatter-rename TRUE    1_KLIz8… <named list [41]>
drive_reveal(files, "mime_type")
#> # A dribble: 10 × 4
#>    name                 mime_type               id       drive_resource
#>    <chr>                <chr>                   <drv_id> <list>        
#>  1 name-squatter-rename application/octet-stre… 1zyeygh… <named list>  
#>  2 name-squatter-mv     application/octet-stre… 11BX-ac… <named list>  
#>  3 name-squatter-upload application/octet-stre… 1BJ22jo… <named list>  
#>  4 name-squatter-rename application/octet-stre… 1vcfucc… <named list>  
#>  5 name-squatter-mv     application/octet-stre… 1PsenIZ… <named list>  
#>  6 name-squatter-upload application/octet-stre… 1y0aNbI… <named list>  
#>  7 name-squatter-rename application/octet-stre… 1_geS-7… <named list>  
#>  8 name-squatter-mv     application/octet-stre… 12Qf1Vn… <named list>  
#>  9 name-squatter-upload application/octet-stre… 13b89cb… <named list>  
#> 10 name-squatter-rename application/octet-stre… 1_KLIz8… <named list>  
drive_reveal(files, "starred")
#> # A dribble: 10 × 4
#>    name                 starred id       drive_resource   
#>    <chr>                <lgl>   <drv_id> <list>           
#>  1 name-squatter-rename FALSE   1zyeygh… <named list [41]>
#>  2 name-squatter-mv     FALSE   11BX-ac… <named list [41]>
#>  3 name-squatter-upload FALSE   1BJ22jo… <named list [41]>
#>  4 name-squatter-rename FALSE   1vcfucc… <named list [41]>
#>  5 name-squatter-mv     FALSE   1PsenIZ… <named list [41]>
#>  6 name-squatter-upload FALSE   1y0aNbI… <named list [41]>
#>  7 name-squatter-rename FALSE   1_geS-7… <named list [41]>
#>  8 name-squatter-mv     FALSE   12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload FALSE   13b89cb… <named list [41]>
#> 10 name-squatter-rename FALSE   1_KLIz8… <named list [41]>
drive_reveal(files, "description")
#> # A dribble: 10 × 4
#>    name                 description id       drive_resource   
#>    <chr>                <list>      <drv_id> <list>           
#>  1 name-squatter-rename <NULL>      1zyeygh… <named list [41]>
#>  2 name-squatter-mv     <NULL>      11BX-ac… <named list [41]>
#>  3 name-squatter-upload <NULL>      1BJ22jo… <named list [41]>
#>  4 name-squatter-rename <NULL>      1vcfucc… <named list [41]>
#>  5 name-squatter-mv     <NULL>      1PsenIZ… <named list [41]>
#>  6 name-squatter-upload <NULL>      1y0aNbI… <named list [41]>
#>  7 name-squatter-rename <NULL>      1_geS-7… <named list [41]>
#>  8 name-squatter-mv     <NULL>      12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload <NULL>      13b89cb… <named list [41]>
#> 10 name-squatter-rename <NULL>      1_KLIz8… <named list [41]>
drive_reveal(files, "version")
#> # A dribble: 10 × 4
#>    name                 version id       drive_resource   
#>    <chr>                <chr>   <drv_id> <list>           
#>  1 name-squatter-rename 3       1zyeygh… <named list [41]>
#>  2 name-squatter-mv     3       11BX-ac… <named list [41]>
#>  3 name-squatter-upload 3       1BJ22jo… <named list [41]>
#>  4 name-squatter-rename 3       1vcfucc… <named list [41]>
#>  5 name-squatter-mv     3       1PsenIZ… <named list [41]>
#>  6 name-squatter-upload 3       1y0aNbI… <named list [41]>
#>  7 name-squatter-rename 3       1_geS-7… <named list [41]>
#>  8 name-squatter-mv     3       12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload 3       13b89cb… <named list [41]>
#> 10 name-squatter-rename 3       1_KLIz8… <named list [41]>
drive_reveal(files, "web_view_link")
#> # A dribble: 10 × 4
#>    name                 web_view_link           id       drive_resource
#>    <chr>                <chr>                   <drv_id> <list>        
#>  1 name-squatter-rename https://drive.google.c… 1zyeygh… <named list>  
#>  2 name-squatter-mv     https://drive.google.c… 11BX-ac… <named list>  
#>  3 name-squatter-upload https://drive.google.c… 1BJ22jo… <named list>  
#>  4 name-squatter-rename https://drive.google.c… 1vcfucc… <named list>  
#>  5 name-squatter-mv     https://drive.google.c… 1PsenIZ… <named list>  
#>  6 name-squatter-upload https://drive.google.c… 1y0aNbI… <named list>  
#>  7 name-squatter-rename https://drive.google.c… 1_geS-7… <named list>  
#>  8 name-squatter-mv     https://drive.google.c… 12Qf1Vn… <named list>  
#>  9 name-squatter-upload https://drive.google.c… 13b89cb… <named list>  
#> 10 name-squatter-rename https://drive.google.c… 1_KLIz8… <named list>  
drive_reveal(files, "modified_time")
#> # A dribble: 10 × 4
#>    name                 modified_time       id       drive_resource   
#>    <chr>                <dttm>              <drv_id> <list>           
#>  1 name-squatter-rename 2026-02-20 14:13:42 1zyeygh… <named list [41]>
#>  2 name-squatter-mv     2026-02-20 14:13:19 11BX-ac… <named list [41]>
#>  3 name-squatter-upload 2026-02-19 14:34:42 1BJ22jo… <named list [41]>
#>  4 name-squatter-rename 2026-02-19 14:33:43 1vcfucc… <named list [41]>
#>  5 name-squatter-mv     2026-02-19 14:33:18 1PsenIZ… <named list [41]>
#>  6 name-squatter-upload 2026-02-18 14:32:28 1y0aNbI… <named list [41]>
#>  7 name-squatter-rename 2026-02-18 14:31:31 1_geS-7… <named list [41]>
#>  8 name-squatter-mv     2026-02-18 14:31:07 12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload 2026-02-17 14:34:45 13b89cb… <named list [41]>
#> 10 name-squatter-rename 2026-02-17 14:34:04 1_KLIz8… <named list [41]>
drive_reveal(files, "created_time")
#> # A dribble: 10 × 4
#>    name                 created_time        id       drive_resource   
#>    <chr>                <dttm>              <drv_id> <list>           
#>  1 name-squatter-rename 2026-02-20 14:13:42 1zyeygh… <named list [41]>
#>  2 name-squatter-mv     2026-02-20 14:13:19 11BX-ac… <named list [41]>
#>  3 name-squatter-upload 2026-02-19 14:34:42 1BJ22jo… <named list [41]>
#>  4 name-squatter-rename 2026-02-19 14:33:43 1vcfucc… <named list [41]>
#>  5 name-squatter-mv     2026-02-19 14:33:18 1PsenIZ… <named list [41]>
#>  6 name-squatter-upload 2026-02-18 14:32:28 1y0aNbI… <named list [41]>
#>  7 name-squatter-rename 2026-02-18 14:31:31 1_geS-7… <named list [41]>
#>  8 name-squatter-mv     2026-02-18 14:31:07 12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload 2026-02-17 14:34:45 13b89cb… <named list [41]>
#> 10 name-squatter-rename 2026-02-17 14:34:04 1_KLIz8… <named list [41]>
drive_reveal(files, "owned_by_me")
#> # A dribble: 10 × 4
#>    name                 owned_by_me id       drive_resource   
#>    <chr>                <lgl>       <drv_id> <list>           
#>  1 name-squatter-rename TRUE        1zyeygh… <named list [41]>
#>  2 name-squatter-mv     TRUE        11BX-ac… <named list [41]>
#>  3 name-squatter-upload TRUE        1BJ22jo… <named list [41]>
#>  4 name-squatter-rename TRUE        1vcfucc… <named list [41]>
#>  5 name-squatter-mv     TRUE        1PsenIZ… <named list [41]>
#>  6 name-squatter-upload TRUE        1y0aNbI… <named list [41]>
#>  7 name-squatter-rename TRUE        1_geS-7… <named list [41]>
#>  8 name-squatter-mv     TRUE        12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload TRUE        13b89cb… <named list [41]>
#> 10 name-squatter-rename TRUE        1_KLIz8… <named list [41]>
drive_reveal(files, "size")
#> # A dribble: 10 × 4
#>    name                 size  id       drive_resource   
#>    <chr>                <chr> <drv_id> <list>           
#>  1 name-squatter-rename 0     1zyeygh… <named list [41]>
#>  2 name-squatter-mv     0     11BX-ac… <named list [41]>
#>  3 name-squatter-upload 0     1BJ22jo… <named list [41]>
#>  4 name-squatter-rename 0     1vcfucc… <named list [41]>
#>  5 name-squatter-mv     0     1PsenIZ… <named list [41]>
#>  6 name-squatter-upload 0     1y0aNbI… <named list [41]>
#>  7 name-squatter-rename 0     1_geS-7… <named list [41]>
#>  8 name-squatter-mv     0     12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload 0     13b89cb… <named list [41]>
#> 10 name-squatter-rename 0     1_KLIz8… <named list [41]>
drive_reveal(files, "quota_bytes_used")
#> # A dribble: 10 × 4
#>    name                 quota_bytes_used id       drive_resource   
#>    <chr>                <chr>            <drv_id> <list>           
#>  1 name-squatter-rename 0                1zyeygh… <named list [41]>
#>  2 name-squatter-mv     0                11BX-ac… <named list [41]>
#>  3 name-squatter-upload 0                1BJ22jo… <named list [41]>
#>  4 name-squatter-rename 0                1vcfucc… <named list [41]>
#>  5 name-squatter-mv     0                1PsenIZ… <named list [41]>
#>  6 name-squatter-upload 0                1y0aNbI… <named list [41]>
#>  7 name-squatter-rename 0                1_geS-7… <named list [41]>
#>  8 name-squatter-mv     0                12Qf1Vn… <named list [41]>
#>  9 name-squatter-upload 0                13b89cb… <named list [41]>
#> 10 name-squatter-rename 0                1_KLIz8… <named list [41]>

# 'root' is a special file id that represents your My Drive root folder
drive_get(id = "root") |>
  drive_reveal("path")
#> # A dribble: 1 × 4
#>   name     path  id                  drive_resource   
#>   <chr>    <chr> <drv_id>            <list>           
#> 1 My Drive ~/    0AO_RMaBzcP63Uk9PVA <named list [33]>
```
