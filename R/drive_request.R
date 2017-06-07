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


process_response <- function(res,
                             expected = "application/json; charset=UTF-8") {

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
  httr::stop_for_status(res)
  jsonlite::fromJSON(httr::content(res, "text"), simplifyVector = FALSE)
}
