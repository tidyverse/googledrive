build_request <- function(endpoint = NULL ,
                          path = "drive/v3/files",
                          params = list(),
                          token = NULL,
                          send_headers = NULL,
                          api_url = "https://www.googleapis.com",
                          method = "GET"){

  workhorse <- list(method = method,
                    url = character(),
                    headers = NULL,
                    query = NULL,
                    body = NULL,
                    endpoint = endpoint,
                    path = path,
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
    return(x)
  }
  if (!all(has_names(x$params))){
    spf("All parameters must be named.")
  }
  x$query <- x$params
  x$params <- NULL
  x
}

set_body <- function(x) {
  if (length(x$params) == 0L) return(x)

  x$body <- x$params
  x
}


## not setting headers yet

set_url <- function(x){

  if (!is.null(x$endpoint)) {
    x$url <- file.path(x$api_url,
                       x$path,
                       x$endpoint)
  } else{
    x$url <- file.path(x$api_url,
                       x$path)
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

process_request <- function(res, content = TRUE) {
  httr::stop_for_status(res)
  if (content == TRUE){
    httr::content(res)
  }
}
