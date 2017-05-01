# build_request <- function(endpoint = NULL,
#                           params = list(),
#                           token = NULL,
#                           send_headers = NULL,
#                           api_url = NULL,
#                           method = "GET", ...){
#
#   work_horse <- list(method = method,
#                      url = character,
#                      headers = NULL,
#                      query = NULL,
#                      body = NULL,
#                      endpoint = endpoint,
#                      params = params,
#                      token = token,
#                      send_headers = send_headers,
#                      api_url = api_url)
#   return(work_horse)
# }


build_request <- function(url = NULL,token = NULL, method = "GET", query = NULL, body = NULL, encode = NULL){
  x <- list()
  x$url <- url
  x$method <- method
  x$query <- query
  x$body <- body
  x$token <- token
  x$encode <- encode
  x
}

make_request <- function(x){
  method <-  list("GET" = httr::GET,
                  "POST" = httr::POST,
                  "PATCH" = httr::PATCH,
                  "PUT" = httr::PUT,
                  "DELETE" = httr::DELETE)[[x$method]]
  method(url = x$url,
         x$token,
         query = x$query,
         body = x$body,
         encode = x$encode)
}

process_request <- function(res) {
  httr::stop_for_status(res)
  metadata <- httr::content(res)
}
