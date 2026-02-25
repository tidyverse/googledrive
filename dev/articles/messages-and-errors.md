# Messages and errors in googledrive

``` r
library(googledrive)
```

*Things I do in a hidden chunk here, to aid exposition about internal
tooling:*

- *“Export” the internal helpers covered below*
- *(Attempt to) auth as the service account we use when rendering
  documentation*

## User-facing messages

Everything should be emitted by helpers in `utils-ui.R`: specifically,
`drive_bullets()` (and, for errors, `drive_abort()`). These helpers are
all wrappers around cli functions, such as
[`cli::cli_bullets()`](https://cli.r-lib.org/reference/cli_bullets.html).

*These may not demo well via pkgdown, but the interactive experience is
nice.*

``` r
drive_bullets(c(
        "noindent",
  " " = "indent",
  "*" = "bullet",
  ">" = "arrow",
  "v" = "success",
  "x" = "danger",
  "!" = "warning",
  "i" = "info"
))
#> noindent
#>   indent
#> • bullet
#> → arrow
#> ✔ success
#> ✖ danger
#> ! warning
#> ℹ info
```

The helpers encourage consistent styling and make it possible to
selectively silence messages coming from googledrive. The googledrive
message helpers:

- Use the [cli package](https://cli.r-lib.org/index.html) to get
  interpolation, inline markup, and pluralization.

- Eventually route through
  [`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html),
  which is important because `inform()` prints to standard output in
  interactive sessions. This means that informational messages won’t
  have the same “look” as errors and can generally be more stylish, at
  least in IDEs like RStudio.

- Use some googledrive-wide style choices, such as:

  - The custom `.drivepath` style is like cli’s inline `.file` style,
    except cyan instead of blue.
  - The built-in `.field` style is tweaked to be flanked by single
    quotes in a no-color situation.
  - The typical “\*” bullet isn’t colored, since we’ve got so much other
    color going on.

- Are under the control of the `googledrive_quiet` option. If it’s
  unset, the default is to show messages (unless we’re testing, i.e. the
  environment variable `TESTTHAT` is `"true"`). Doing
  `options(googledrive_quiet = TRUE)` will suppress messages. There are
  withr-style convenience helpers:
  [`local_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md)
  and
  [`with_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md).

### Inline styling

How we use the inline classes:

- `.drivepath` for the name or, occasionally, the (partial) path of a
  Drive file
- `.field` for the value of an argument, e.g. a MIME type
- `.code` for a column in a data frame and for reserved words, such as
  `NULL`, `TRUE`, and `NA`
- `.arg`, `.fun`, `.path`, `.cls`, `.url` for their usual purpose

``` r
drive_bullets(c(
  "We need to talk about the {.arg foofy} argument to {.fun blarg}",
  "You provided {.field a_very_weird_value} and I suspect you're confused \\
   about something"
))
#> We need to talk about the `foofy` argument to `blarg()`
#> You provided a_very_weird_value and I suspect you're confused about
#> something
```

Most relevant cli docs:

- [CLI inline
  markup](https://cli.r-lib.org/reference/inline-markup.html)
- [Building a Semantic
  CLI](https://cli.r-lib.org/articles/semantic-cli.html)

### Bullets

I use the different bullet points in `drive_bullets()` to convey a mood.

Exclamation mark `"!"`: I’m not throwing an error or warning, but I want
to get the user’s attention, because it seems likely (but not certain)
that they misunderstand something about googledrive or Google Drive or
their Drive files. Examples:

``` r
drive_bullets(c(
  "!" = "Ignoring {.arg type}. Only consulted for native Google file types.",
  " " = "MIME type of {.arg file}: {.field mime_type}."
))
#> ! Ignoring `type`. Only consulted for native Google file types.
#>   MIME type of `file`: mime_type.

drive_bullets(c(
  "!" = "Currently only fields for the {.field files} resource can be \\
         checked for validity.",
  " " = "Nothing done."
))
#> ! Currently only fields for the files resource can be checked for
#>   validity.
#>   Nothing done.

drive_bullets(c(
  "!" = "No updates specified."
))
#> ! No updates specified.

drive_bullets(c(
  "!" = "No such file to delete."
))
#> ! No such file to delete.
```

Information “i”: I’m just keeping you informed of how my work is going.

``` r
drive_bullets(c(
  "i" = "No pre-existing file at this filepath. Calling \\
         {.fun drive_upload}."
))
#> ℹ No pre-existing file at this filepath. Calling `drive_upload()`.

drive_bullets(c(
  "i" = "Pre-existing file at this filepath. Calling \\
         {.fun drive_update}."
))
#> ℹ Pre-existing file at this filepath. Calling `drive_update()`.

drive_bullets(c(
  "i" = "Not logged in as any specific Google user."
))
#> ℹ Not logged in as any specific Google user.
```

In cases where we determine there is nothing we can or should do,
sometimes I use `"!"` and sometimes I use `"i"`. It depends on whether
it feels like the user could or should have known that no work would be
possible or needed.

### Programmatic generation of bullets

Often we need to create bullets from an R object, such as a character
vector or a dribble. What needs to happen:

- Map a cli-using string template over the object to get a character
  vector
- Truncate this vector in an aesthetically pleasing way
- Apply names to this vector to get the desired bullet points

`gargle_map_cli()` is a new generic in gargle that turns an object into
a vector of strings with cli markup. Currently gargle exports methods
for `character` (and `NULL` and a `default`) and googlesheets4 defines a
method for `dribble`. This is likely to be replaced by something in cli
itself in due course.

``` r
gargle_map_cli(letters[1:3])
#> [1] "{.field a}" "{.field b}" "{.field c}"
```

By default `gargle_map_cli.character()` just applies the `.field` style,
i.e. the template is `"{.field <<x>>}"`. But the template can be
customized, if you need something else. Note that we use non-standard
glue delimiters (`<<` and `>>`, by default), because we are
interpolating into a string with glue/cli markup, where
[`{}`](https://rdrr.io/r/base/Paren.html) has the usual meaning.

``` r
gargle_map_cli(letters[4:6], template = "how about a path {.path <<x>>}?")
#> [1] "how about a path {.path d}?" "how about a path {.path e}?"
#> [3] "how about a path {.path f}?"
```

The `gargle_map_cli.dribble()` method makes a cli-marked up string for
each row of the dribble, i.e. for each Drive file.

``` r
dat <- drive_find(n_max = 5)
gargle_map_cli(dat)
#> [1] "{.drivepath chicken-perm-article.txt} {cli::col_grey('<id: 1EaozcNLJPioIDdzwZtzLhdHjookEZbZ1>')}"  
#> [2] "{.drivepath chicken_poem.txt} {cli::col_grey('<id: 1lAxO_zr06v6pL6dyQJ9duwH1j2ztQ3lB>')}"          
#> [3] "{.drivepath 2021-09-16_r_logo.jpg} {cli::col_grey('<id: 1dandXB0QZpjeGQq_56wTXKNwaqgsOa9D>')}"     
#> [4] "{.drivepath 2021-09-16_r_about.html} {cli::col_grey('<id: 1XfCI_orH4oNUZh06C4w6vXtno-BT_zmZ>')}"   
#> [5] "{.drivepath 2021-09-16_imdb_latin1.csv} {cli::col_grey('<id: 163YPvqYmGuqQiEwEFLg2s1URq4EnpkBw>')}"
```

`gargle_map_cli.dribble()` also allows a custom template, but it’s a
more complicated and less common situation than for `character`. We
won’t get into that here. (I don’t consider the dribble styling to be
finalized yet.)

The result of `gargle_map_cli()` then gets processed with
[`gargle::bulletize()`](https://gargle.r-lib.org/reference/bulletize.html),
which adds the bullet-specifying names and does aesthetically pleasing
truncation.

``` r
bulletize(gargle_map_cli(letters))
#>               *               *               *               * 
#>    "{.field a}"    "{.field b}"    "{.field c}"    "{.field d}" 
#>               *                 
#>    "{.field e}" "… and 21 more"

bulletize(gargle_map_cli(letters), bullet = "x", n_show = 2)
#>               x               x                 
#>    "{.field a}"    "{.field b}" "… and 24 more"

drive_bullets(c(
  "These are surprising things:",
  bulletize(gargle_map_cli(letters), bullet = "!")
))
#> These are surprising things:
#> ! a
#> ! b
#> ! c
#> ! d
#> ! e
#>   … and 21 more

dat <- drive_find(n_max = 10)

drive_bullets(c(
  "Some Drive files:",
  bulletize(gargle_map_cli(dat))
))
#> Some Drive files:
#> • chicken-perm-article.txt <id: 1EaozcNLJPioIDdzwZtzLhdHjookEZbZ1>
#> • chicken_poem.txt <id: 1lAxO_zr06v6pL6dyQJ9duwH1j2ztQ3lB>
#> • 2021-09-16_r_logo.jpg <id: 1dandXB0QZpjeGQq_56wTXKNwaqgsOa9D>
#> • 2021-09-16_r_about.html <id: 1XfCI_orH4oNUZh06C4w6vXtno-BT_zmZ>
#> • 2021-09-16_imdb_latin1.csv <id: 163YPvqYmGuqQiEwEFLg2s1URq4EnpkBw>
#>   … and 5 more
```

It’s conceivable that cli will gain a better way of vectorization, but
this works for now.

Known dysfunction: it’s inefficient to `gargle_map_cli()` over the whole
object, then truncate with `bulletize()`. But it’s easy. There are
contexts, like tibble printing, where formatting stuff that will never
see the light of day is really punishing. But I’m not sure I really have
to worry about that.

## Errors

I am currently using
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
which is present in the dev version of cli (as of late May 2021, cli
version 2.5.0.9000).

It’s wrapped as `drive_abort()`, for the same reason as
`drive_bullets()`, namely to apply some package-wide style tweaks.

The mechanics of `drive_abort()` usage are basically the same as
`drive_bullets()`.
