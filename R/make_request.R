#' Make a request for the Google Drive v3 API
#'
#' @param x List, contains the  `method`, `path`, `query`, `body`, `token`, and
#'   `url`, to make the API request, presumably created with [build_request()].
#' @param ... List, Name-value pairs to query the API
#'
#' @return Object of class `response` from [httr].
#' @export
#' @family low-level API functions
make_request <- function(x, ...) {
  method <- list("GET" = httr::GET,
                 "POST" = httr::POST,
                 "PATCH" = httr::PATCH,
                 "PUT" = httr::PUT,
                 "DELETE" = httr::DELETE)[[x$method]]
  method(url = x$url,
         x$token,
         drive_ua(),
         query = x$query,
         body = x$body, ...)
}

#' @rdname make_request
#' @export
do_request <- function(x, ...) {
  process_response(make_request(x, ...))
}

#' @rdname make_request
#' @export
do_paginated_request <- function(x, ...) {
  ## you can't really separate make_request() and process_request()
  ## when travesing pages, because you need to process response / page i to
  ## get the pageToken for request / page i + 1
  stopifnot(identical(x$method, "GET"))
  x$query$fields <- x$query$fields %||% ""
  if (!grepl("nextPageToken", x$query$fields)) {
    x$query$fields <- glue("nextPageToken,{x$query$fields}")
  }

  responses <- list()
  i <- 1
  repeat {
    page <- make_request(x, ...)
    responses[[i]] <- process_response(page)
    x$query$pageToken <- responses[[i]]$nextPageToken
    if (is.null(x$query$pageToken)) {
      if (i > 1) message(" .")
      break
    }
    if (i == 1) message("Traversing pages", appendLF = FALSE)
    message(" .", appendLF = FALSE)
    i <- i + 1
  }

  responses
}

drive_ua <- function() {
  httr::user_agent(paste0(
    "googledrive/", utils::packageVersion("googledrive"), " ",
    ## TO DO: uncomment this once we use gargle
    #"gargle/", utils::packageVersion("gargle"), " ",
    "httr/", utils::packageVersion("httr")
  ))
}
