#' Make a request for the Google Drive v3 API
#'
#' @param x List, contains the  `method`, `path`, `query`, and `url`, to make
#'  the API request obtained from [build_request()]
#' @param ... List, Name-value pairs to query the API
#'
#' @return Object of class `response` from [httr].
#' @export
make_request <- function(x, ...){
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

drive_ua <- function() {
  httr::user_agent(paste0(
    "googledrive/", utils::packageVersion("googledrive"), " ",
    ## TO DO: uncomment this once we use gargle
    #"gargle/", utils::packageVersion("gargle"), " ",
    "httr/", utils::packageVersion("httr")
  ))
}
