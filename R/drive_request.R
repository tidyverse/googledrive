#' Build a request for the Google Drive v3 API
#'
#' Build a request, using some knowledge of the [Drive v3
#' API](https://developers.google.com/drive/v3/web/about-sdk). Most users
#' should, instead, use higher-level wrappers that facilitate common tasks, such
#' as uploading or downloading Drive files. The functions here are intended for
#' internal use and for programming around the Drive API.
#'
#' * `build_request()` takes a nickname for an endpoint and uses the API spec to
#' look up the `path` and `method`. The `params` are checked for validity and
#' completeness with respect to the endpoint.
#'
#' @param endpoint Character. Nickname for one of the documented Drive v3 API
#'   endpoints. *to do: list or link, once I've auto-generated those docs*
#' @param params Named list. Parameters destined for endpoint URL substitution
#'   or, otherwise, the query.
#' @param token Drive token, obtained from [`drive_auth()`]
#' @param .api_key NULL for now.
#'

#' @return `list()`\cr Components are `method`, `path`, `query`, and `url`,
#'   suitable as input for [make_request()]. The `path` is post-substitution
#'   and the `query` is a named list of all the input `params` that were not
#'   used during this substitution. `url` is the full URL after prepending the
#'   base URL for the Drive v3 API and appending an API key to the query.
#' @export
#' @examples
#' \dontrun{
#' req <- build_request(
#'   "drive.files.get",
#'   list(
#'     fileId = "abc",
#'   )
#' )
#' req
#' }
build_request <- function(endpoint = character(),
                          params = list(),
                          token = drive_token(),
                          .api_key = NULL) {
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop("Endpoint not recognized:\n", endpoint, call. = FALSE)
  }

  ## use the spec to vet and rework request parameters
  params <-   match_params(params, ept$parameters)
  params <- handle_repeats(params, ept$parameters)
  params <- check_enums(params, ept$parameters)
  params <- partition_params(params,
                             extract_path_names(ept$path),
                             extract_body_names(ept$parameters))

  out <- list(
    method = ept$method,
    path = glue::glue_data(params$path_params, ept$path),
    query = c(params$query_params),
    body = c(params$body_params),
    token = token
  )

  out$url <- httr::modify_url(
    url = .drive$base_url,
    path = out$path,
    query = out$query
  )
  out
}

## match params provided by user to spec
##   * error if required params are missing
##   * message and drop unknown params
match_params <- function(provided, spec) {
  ## .endpoints %>% map("parameters") %>% flatten() %>% map_lgl("required")
  required <- spec %>% purrr::keep("required") %>% names()
  missing <- setdiff(required, names(provided))
  if (length(missing)) {
    stop(glue::collapse(
      c("Required parameter(s) are missing:", missing), sep = "\n"),
      call. = FALSE
    )
  }

  unknown <- setdiff(names(provided), names(spec))
  if (length(unknown)) {
    m <- names(provided) %in% unknown
    msgs <- c(
      "Ignoring these unrecognized parameters:",
      glue::glue_data(tibble::enframe(provided[m]), "{name}: {value}")
    )
    message(paste(msgs, collapse = "\n"))
    provided <- provided[!m]
  }
  return(provided)
}

## certain params can be repeated on specific endpoints, e.g., ranges
##   * replicate as needed in the query params
##   * detect and error for any other repetition
handle_repeats <- function(provided, spec) {

  if (length(provided) == 0) {
    return(provided)
  }
  can_repeat <- spec[names(provided)] %>%
    purrr::map_lgl("repeated") %>%
    purrr::map_lgl(isTRUE)
  too_long <- lengths(provided) > 1 & !can_repeat
  if (any(too_long)) {
    stop(
      "These parameter(s) are not allowed to have length > 1:\n",
      names(provided)[too_long],
      call. = FALSE
    )
  }

  is_a_repeat <- duplicated(names(provided))
  too_many <- is_a_repeat & !can_repeat
  if (any(too_many)) {
    stop(
      "These parameter(s) are not allowed to appear more than once:\n",
      names(provided)[too_many],
      call. = FALSE
    )
  }

  ## replicate anything with length > 1
  n <- lengths(provided)
  nms <- names(provided)
  ## this thwarts protection from urlencoding via I() ... revisit if needed
  provided <- provided %>% purrr::flatten() %>% purrr::set_names(rep(nms, n))

  return(provided)
}

## a few parameters have fixed lists of possible values -- a.k.a the "enums"
check_enums <- function(provided, spec) {
  values <- spec %>% purrr::map("enum")
  if (length(provided) == 0 | length(values) == 0) {
    return(provided)
  }
  check_it <- tibble::tibble(
    pname = names(provided),
    pdata = purrr::flatten_chr(provided)
  )
  check_it$values = values[check_it$pname]
  not_an_enum <- check_it$values %>% purrr::map(is.na) %>% purrr::map_lgl(all)
  check_it <- check_it[!not_an_enum, ]
  ok <- purrr::map2_lgl(check_it$pdata, check_it$values, ~ .x %in% .y)
  if (any(!ok)) {
    problems <- check_it[!ok, ]
    problems$values <- problems$values %>% purrr::map_chr(paste, collapse = " | ")
    template <- paste0("Parameter '{pname}' has value '{pdata}', ",
                       "but it must be one of these:\n{values}\n\n")
    msgs <- glue::glue_data(problems, template)
    msgs %>% purrr::walk(message)
    stop("Invalid parameter value(s).", call. = FALSE)
  }
  return(provided)
}

## extract the path params by name and put the leftovers in query
## why is this correct?
## if the endpoint was specified, we have already matched against spec
## if the endpoint was unspecified, we have no choice
partition_params <- function(provided, path_param_names, body_param_names) {
  query_params <- provided
  path_params <- NULL
  body_params <- NULL
  if (length(path_param_names) && length(query_params)) {
    m <- names(provided) %in% path_param_names
    path_params <- query_params[m]
    query_params <- query_params[!m]
  }
  if (length(body_param_names) && length(query_params)) {
    m <- names(query_params) %in% body_param_names
    body_params <- query_params[m]
    query_params <- query_params[!m]
  }
  ## if no query_params, NULL is preferred to list() for the sake of
  ## downstream URLs, though the API key will generally imply there are
  ## no empty queries
  if (length(query_params) == 0) {
    query_params <- NULL
  }
  list(
    path_params = path_params,
    body_params = body_params,
    query_params = query_params
  )
}

##  input: /v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo
## output: spreadsheetId, sheetId
extract_path_names <- function(path) {
  m <- gregexpr("\\{[^/]*\\}", path)
  path_param_names <- regmatches(path, m)[[1]]
  gsub("[\\{\\}]", "", path_param_names)
}

extract_body_names <- function(params) {
  names(params)[purrr::map_lgl(params, ~ .x[["location"]] == "body")]
}

#' Make a request for the Google Drive v3 API
#'
#' @param x List, contains the  `method`, `path`, `query`, and `url`, to make
#'  the API request obtained from [`build_request()`]
#' @param ... List, Name-value pairs to query the API
#'
#' @return Object of class `response` from [httr].
#' @export
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
