# File permissions

You can use googledrive to manage permissions on your Drive files,
i.e. grant different people or groups of people various levels of access
(read, comment, edit, etc.).

Let’s upload a file and view its permissions.

``` r
library(googledrive)

file <- drive_example_local("chicken.txt") |>
  drive_upload(name = "chicken-perm-article.txt") |>
  drive_reveal("permissions")
#> Local file:
#> • /home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.txt
#> Uploaded into Drive file:
#> • chicken-perm-article.txt <id: 1T-wUvp3TV108rlxP_OajbuENnye6tbN7>
#> With MIME type:
#> • text/plain

file
#> # A dribble: 1 × 5
#>   name              shared id       drive_resource permissions_resource
#>   <chr>             <lgl>  <drv_id> <list>         <list>              
#> 1 chicken-perm-art… FALSE  1T-wUvp… <named list>   <named list [2]>
```

`shared = FALSE` indicates that this file is not yet shared with anyone
and, for those so inclined, detailed information on permissions can be
found in the `permissions_resource` list-column. Note that the
`drive_resource`, which is always present in a dribble, typically also
contains information on permissions. So if you just want to *know* about
permissions, as opposed to modifying them, you can probably consult
`drive_resource`.

Let’s give a specific person permission to edit this file and a
customized message, using the `emailAddress` and `emailMessage`
parameters.

``` r
file <- file |>
  drive_share(
    role = "writer",
    type = "user",
    emailAddress = "serena@example.com",
    emailMessage = "Would appreciate your feedback on this!"
  )
```

Let’s say we also want “anyone with a link” to be able to read the file.

``` r
file <- file |>
  drive_share(role = "reader", type = "anyone")
```

This comes up often enough that we’ve made a convenience wrapper:

``` r
file <- file |>
  drive_share_anyone()
#> Permissions updated:
#> • role = reader
#> • type = anyone
#> For file:
#> • chicken-perm-article.txt <id: 1T-wUvp3TV108rlxP_OajbuENnye6tbN7>
file
#> # A dribble: 1 × 5
#>   name              shared id       drive_resource permissions_resource
#>   <chr>             <lgl>  <drv_id> <list>         <list>              
#> 1 chicken-perm-art… TRUE   1T-wUvp… <named list>   <named list [2]>
```

We see that the file is now `shared = TRUE`.

Now that we’ve made a few updates to our permissions, the
`permissions_resource` list-column has become more interesting. Here’s
how to pull important information out of this and put into a tibble with
one row per permission. (*Permission handling will become more
formalized in future versions of googledrive. See [the
issue](https://github.com/tidyverse/googledrive/issues/180)*). We use
other packages in the tidyverse now for this data wrangling.

``` r
library(tidyverse)

perm <- pluck(file, "permissions_resource", 1, "permissions")

permissions <- tibble(
  id =    map_chr(perm, "id",           .default = NA_character_),
  name =  map_chr(perm, "displayName",  .default = NA_character_),
  type =  map_chr(perm, "type",         .default = NA_character_),
  role =  map_chr(perm, "role",         .default = NA_character_),
  email = map_chr(perm, "emailAddress", .default = NA_character_)
)
permissions
```

We’ve suppressed execution of the above chunk but here’s some static,
indicative output:

``` r
#> # A tibble: 3 x 5
#>   id           name            type   role  email
#>   <chr>        <chr>           <chr>  <chr> <chr>
#> 1 12345678901… Serena Somebody user   writ… serena@example.com
#> 2 anyoneWithL… NA              anyone read… NA
#> 3 98765432109… Orville Owner   user   owner orville@example.com
```

## Clean up

``` r
drive_rm(file)
#> File deleted:
#> • chicken-perm-article.txt <id: 1T-wUvp3TV108rlxP_OajbuENnye6tbN7>
```
