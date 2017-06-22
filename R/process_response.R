process_response <- function(res) {

  if (httr::status_code(res) == 204) {
    return(TRUE)
  }

  if (httr::status_code(res) >= 200 && httr::status_code(res) < 300) {
    return(res %>%
             stop_for_content_type() %>%
             httr::content(as = "parsed", type = "application/json")
    )
  }

  type <- res$headers$`Content-type`
  if (!grepl("^application/json", type)) {
    out <- httr::content(res, as = "text")
    stop("HTTP error [", res$status, "] ", out, call. = FALSE)
  }

  out <- httr::content(res, as = "parsed", type = "application/json")
  out <- out$error
  errors <- out$errors[[1]]
  msg <- glue::glue("HTTP error [{out$code}] {out$message}")
  details <- glue::glue_data(errors, "  * {names(errors)}: {errors}")
  err_msg <- glue::collapse(c(msg, details), sep = "\n")
  cl <- c("googledrive_error", paste0("http_error_", out$code),
          "error", "condition")
  cond <- structure(list(message = err_msg), class = cl)
  stop(cond)
}

stop_for_content_type <- function(response,
                                  expected = "application/json; charset=UTF-8") {
  actual <- response$headers$`Content-Type`
  if (actual != expected) {
    stop(
      glue::glue("Expected content-type:\n{expected}\n",
                 "Actual content-type:\n{actual}"),
      call. = FALSE
    )
  }
  response
}
