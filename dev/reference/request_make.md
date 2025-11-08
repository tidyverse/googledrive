# Make a request for the Google Drive v3 API

Low-level functions to execute one or more Drive API requests and,
perhaps, process the response(s). Most users should, instead, use
higher-level wrappers that facilitate common tasks, such as uploading or
downloading Drive files. The functions here are intended for internal
use and for programming around the Drive API. Three functions are
documented here:

- `request_make()` does the bare minimum: calls
  [`gargle::request_retry()`](https://gargle.r-lib.org/reference/request_retry.html),
  only adding the googledrive user agent. Typically the input is created
  with
  [`request_generate()`](https://googledrive.tidyverse.org/dev/reference/request_generate.md)
  and the output is processed with
  [`gargle::response_process()`](https://gargle.r-lib.org/reference/response_process.html).

- `do_request()` is simply
  `gargle::response_process(request_make(x, ...))`. It exists only
  because we had to make `do_paginated_request()` and it felt weird to
  not make the equivalent for a single request.

- `do_paginated_request()` executes the input request **with page
  traversal**. It is impossible to separate paginated requests into a
  "make request" step and a "process request" step, because the token
  for the next page must be extracted from the content of the current
  page. Therefore this function does both and returns a list of
  processed responses, one per page.

## Usage

``` r
request_make(x, ...)

do_request(x, ...)

do_paginated_request(
  x,
  ...,
  n_max = Inf,
  n = function(res) 1,
  verbose = deprecated()
)
```

## Arguments

- x:

  List, holding the components for an HTTP request, presumably created
  with
  [`request_generate()`](https://googledrive.tidyverse.org/dev/reference/request_generate.md)
  Should contain the `method`, `url`, `body`, and `token`.

- ...:

  Optional arguments passed through to the HTTP method.

- n_max:

  Maximum number of items to return. Defaults to `Inf`, i.e. there is no
  limit and we keep making requests until we get all items.

- n:

  Function that computes the number of items in one response or page.
  The default function always returns `1` and therefore treats each page
  as an item. If you know more about the structure of the response, you
  can pass another function to count and threshhold, for example, the
  number of files or comments.

- verbose:

  **\[deprecated\]** This logical argument to individual googledrive
  functions is deprecated. To globally suppress googledrive messaging,
  use `options(googledrive_quiet = TRUE)` (the default behaviour is to
  emit informational messages). To suppress messaging in a more limited
  way, use the helpers
  [`local_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md)
  or
  [`with_drive_quiet()`](https://googledrive.tidyverse.org/dev/reference/googledrive-configuration.md).

## Value

`request_make()`: Object of class `response` from
[httr::httr](https://httr.r-lib.org/reference/httr-package.html).

`do_request()`: List representing the content returned by a single
request.

`do_paginated_request()`: List of lists, representing the returned
content, one component per page.

## See also

Other low-level API functions:
[`drive_has_token()`](https://googledrive.tidyverse.org/dev/reference/drive_has_token.md),
[`drive_token()`](https://googledrive.tidyverse.org/dev/reference/drive_token.md),
[`request_generate()`](https://googledrive.tidyverse.org/dev/reference/request_generate.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# build a request for an endpoint that is:
#   * paginated
#   * NOT privileged in googledrive, i.e. not covered by request_generate()
# "comments" are a great example
# https://developers.google.com/drive/v3/reference/comments
#
# Practice with a target file with > 2 comments
# Note that we request 2 items (comments) per page
req <- gargle::request_build(
  path = "drive/v3/files/{fileId}/comments",
  method = "GET",
  params = list(
    fileId = "your-file-id-goes-here",
    fields = "*",
    pageSize = 2
  ),
  token = googledrive::drive_token()
)
# make the paginated request, but cap it at 1 page
# should get back exactly two comments
do_paginated_request(req, n_max = 1)
} # }
```
