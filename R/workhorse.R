build_request <- function(endpoint = NULL,
                          params = list(),
                          token = NULL,
                          send_headers = NULL,
                          api_url = NULL,
                          method = "GET"){

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

  workhorse <- set_method(workhorse)
  workhorse <- set_query(workhorse)
  workhorse <- set_body(workhorse)
  workhorse <- set_url(workhorse)

  workhorse
}

set_method <- function(x) {
  if (is.null(x$endpoint)) return(x)

  if (grepl("^/", x$endpoint) | grepl("^http", x$endpoint)) return(x)

  x$method <- sub(" .*$", "", x$endpoint)
  stopifnot(x$method %in% c("GET","POST","PATCH","PUT","DELETE"))
  x$endpoint <- sub(".* ","", x$endpoint)
  if (!(grepl("^/", x$endpoint) | grepl("^http", x$endpoint))){
    spf("endpoint not properly specified.")
  }
  x
}

## right now not setting endpoint, if you want to include parameters, must be in a named list
## may introduce the :parameter notation in endpoint later :)

set_query <- function(x){
  if (x$method != "GET" | length(x$params) == 0L) return(x)

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
    x$url <- file.path(x$api_url, sub(".","",x$endpoint))
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
