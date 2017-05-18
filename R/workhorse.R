build_request <- function(endpoint = NULL,
                          params = list(),
                          token = NULL,
                          send_headers = NULL,
                          api_url = NULL,
                          method = "GET") {
  workhorse <- list(method = method,
                    url = character(),
                    headers = NULL,
                    query = NULL,
                    body = NULL,
                    endpoint = endpoint,
                    params = params,
                    token = token,
                    send_headers = send_headers,
                    api_url = api_url)

  workhorse <- set_query(workhorse)
  workhorse <- set_body(workhorse)
  workhorse <- set_url(workhorse)

  workhorse
}


## right now not setting endpoint, if you want to include parameters, must be in a named list
## may introduce the :parameter notation in endpoint later :)

set_query <- function(x){
  if (length(x$params) == 0L) return(x)
  if (x$method != "GET") {
    if (grepl("\\?", x$endpoint)) {
      x$query <- sub(".*\\?", "", x$endpoint)
      return(x)
    }
    return(x)
  }
  if (!all(has_names(x$params))){
    spf("All parameters must be named.")
  }
  x$query <- x$params
  x$params <- NULL
  x
}

set_body <- function(x){
  if (length(x$params) == 0L) return(x)

  x$body <- x$params
  x
}

## not setting headers yet

set_url <- function(x){

  if (grepl("^http", x$endpoint)){
    x$url <- x$endpoint
  } else{
    x$url <- file.path(x$api_url, sub(".", "", x$endpoint))
  }
  x
}

make_request <- function(x, ...){
  method <-  list("GET" = httr::GET,
                  "POST" = httr::POST,
                  "PATCH" = httr::PATCH,
                  "PUT" = httr::PUT,
                  "DELETE" = httr::DELETE)[[x$method]]
  method(url = x$url,
         x$token,
         query = x$query,
         body = x$body, ...)
}

process_request <- function(res,
                            expected = "application/json; charset=UTF-8",
                            internet = TRUE) {

  actual <- res$headers$`content-type`
  if (actual != expected) {
    spf(
      paste0(
        "Expected content-type:\n%s",
        "\n",
        "Actual content-type:\n%s"
      ),
      expected,
      actual
    )
  }

  if (internet) {
    httr::stop_for_status(res)
    jsonlite::fromJSON(httr::content(res, "text"), simplifyVector = FALSE)
  } else return(NULL)
}
