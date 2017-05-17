build_request <- function(path = NULL,
                          params = list(),
                          method = "list",
                          resource = "files",
                          token = NULL,
                          send_headers = NULL,
                          api_url = "https://www.googleapis.com/drive/v3") {

  workhorse <- list(verb = NULL,
                    url = character(),
                    headers = NULL,
                    query = NULL,
                    body = NULL,
                    method = method,
                    resource = resource,
                    path = path,
                    params = params,
                    token = token,
                    send_headers = send_headers,
                    api_url = api_url)

  workhorse <- set_path(workhorse)
  workhorse <- set_path_params(workhorse)
  workhorse <- set_query_params(workhorse)
  workhorse <- set_query_params(workhorse)
  workhorse <- set_body_params(workhorse)
  workhorse <- set_url(workhorse)
  workhorse <- set_verb(workhorse)

  return(workhorse)
}

set_path <- function(x) {
  if (!is.null(x$path)) {
    return(x)
  }
  ## find the path that matches the given method and resource
  x$path <- unique(.drive$params$path[.drive$params$method == x$method &
                                        .drive$params$resource == x$resource])
  return(x)
}

set_path_params <- function(x) {
  path_param_names <- extract_param_names(x$path)

  if (length(path_param_names) & length(x$params)) {
    m <- names(x$params) %in% path_param_names
    x$path_params <- x$params[m]
    x$params <- x$params[!m]
  }

  if (length(x$params) == 0) {
    x$params <- NULL
  }
  return(x)
}

set_query_params <- function(x) {
  if (is.null(x$params)) {
    return(x)
  }
  ok_query <- .drive$params$param_name[.drive$params$method == x$method &
                                         .drive$params$resource == x$resource &
                                         .drive$params$type == "query"]
  m <- names(x$params) %in% c(ok_query, "fields") ## also allow fields for now
  x$query <- x$params[m]
  x$params <- x$params[!m]

  if (length(x$params) == 0) {
    x$params <- NULL
  }
  return(x)
}

set_body_params <- function(x) {
  if (is.null(x$params)) {
    return(x)
  }
  if (!is.null(x$params$body)) {
    x$body <- x$params$body ##for uploads, just stick it all in the body and return
    return(x)
  }
  ok_body <- .drive$params$param_name[.drive$params$method == x$method &
                                        .drive$params$resource == x$resource &
                                        .drive$params$type == "body"]
  m <- names(x$params) %in% c(ok_body)
  x$body <- x$params[m]
  x$params <- x$params[!m]

  if (length(x$params) == 0) {
    x$params <- NULL
  }
  ## by now, we have used all of the params, if there are more,
  ## we will ignore them
  if (!is.null(x$params)) {
    msg <-  c(
      "Ignoring these unrecognized parameters:",
      glue::glue_data(tibble::enframe(x$params),"{name}: {value}")
    )
    message(paste(msg, collapse = "\n"))
  }
  return(x)
}

set_url <- function(x) {
  if (grepl("^http", x$path)) {
    x$path <- glue::glue_data(x$path_params, x$path)
    x$url <- httr::modify_url(
      url = x$path,
      query = x$query
    )
    return(x)
  }
  x$path <- paste0("drive/v3",glue::glue_data(x$path_params, x$path))
  x$url <- httr::modify_url(
    url = x$api_url,
    path = x$path,
    query = x$query
  )
  return(x)
}

set_verb <- function(x) {
  x$verb <- unique(.drive$params$verb[.drive$params$method == x$method &
                                    .drive$params$resource == x$resource ])
  return(x)
}

## adapted from googlesheets, thank you Jenny!

## input: /files/{fileId}/comments/{commentId}
## output: fileId, commentId
extract_param_names <- function(path) {
  m <- gregexpr("\\{[^/]*\\}", path)
  path_param_names <- regmatches(path, m)[[1]]
  gsub("[\\{\\}]", "", path_param_names)
}

make_request <- function(x, ...){
  verb <-  list("GET" = httr::GET,
                "POST" = httr::POST,
                "PATCH" = httr::PATCH,
                "PUT" = httr::PUT,
                "DELETE" = httr::DELETE)[[x$verb]]
  verb(url = x$url,
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
