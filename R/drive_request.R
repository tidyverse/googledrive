#' Build a request for the Google Drive v3 API
#'
#' Build a request, using some knowledge of the
#' [Drive v3 API](https://developers.google.com/drive/v3/web/about-sdk). Most
#' users should, instead, use higher-level wrappers that facilitate common
#' tasks, such as uploading or downloading Drive files. The functions here are
#' intended for internal use and for programming around the Drive API.
#'
#' There are two functions:
#' * `generate_request()` takes a nickname for an endpoint and uses the API spec
#' to look up the `path` and `method`. The `params` are checked for validity and
#' completeness with respect to the endpoint. It then passes things along to
#' `gs_build_request()`. Use [drive_endpoints()] to see which endpoints can be
#' accessed this way.
#' * `build_request()` builds a request from explicit parts. It is quite
#' dumb, only doing URL endpoint substitution and URL formation. It's up to the
#' caller to make sure the `path`, `method`, `params`, and `body` are valid. Use
#' this to call a Drive API endpoint that doesn't appear in the list returned
#' by [drive_endpoints()].
#'
#' @param endpoint Character. Nickname for one of the selected Drive v3 API
#'   endpoints built into googledrive. Inspect via [drive_endpoints()].
#' @param params Named list. Parameters destined for endpoint URL substitution,
#'   the query, or body.
#' @param token Drive token, obtained from [drive_auth()].
#' @param .api_key *not in use yet*
#'

#' @return `list()`\cr Components are `method`, `path`, `query`, `body`, and
#'   `url`, suitable as input for [make_request()]. The `path` is
#'   post-substitution and the `query` is a named list of all the non-body
#'   `params` that were not used during this substitution. `url` is the full URL
#'   after prepending the base URL for the Drive v3 API and appending an API key
#'   to the query.
#' @export
#' @examples
#' req <- generate_request(
#'   "drive.files.get",
#'   list(fileId = "abc"),
#'   token = NULL
#' )
#' req
generate_request <- function(endpoint = character(),
                             params = list(),
                             token = drive_token(),
                             .api_key = NULL) {
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop("Endpoint not recognized:\n", endpoint, call. = FALSE)
  }

  ## use the spec to vet and rework request parameters
  params <-   match_params(params, ept$parameters)
  params <- partition_body(params, extract_body_names(ept$parameters))

  build_request(
    path = ept$path,
    method = ept$method,
    params = params$remaining_params,
    body = params$body_params,
    token = token,
    .api_key = .api_key
  )
}

#' @param path Character, e.g.,
#'   `"drive/v3/files/{fileId}"`. It can include
#'   variables inside curly brackets, as the example does, which are substituted
#'   using named parameters found in the `params` argument.
#' @param method Character, should match an HTTP verb, e.g., `GET`, `POST`,
#'   `PATCH` or `PUT`
#' @param body List, values to pass to the API request body.
#' @rdname generate_request
#' @export
#' @examples
#' ## re-create the previous request, but the hard way, i.e. "by hand"
#' req <- build_request(
#'   path = "drive/v3/files/{fileId}",
#'   method = "GET",
#'   list(fileId = "abc"),
#'   token = NULL
#' )
#' req
#'
#' ## call an endpoint not used by googledrive
#' ## List a file's comments
#' ## https://developers.google.com/drive/v3/reference/comments/list
#' \dontrun{
#' req <- build_request(
#'   path = "drive/v3/files/{fileId}/comments",
#'   method = "GET",
#'   params = list(
#'     fileId = "file-id-goes-here",
#'     fields = "*"
#'   ),
#'   token = googledrive:::drive_token()
#' )
#' make_request(x)
#' }
build_request <- function(path,
                          method,
                          params = list(),
                          body = NULL,
                          token = NULL,
                          .api_key = NULL) {

  params <- partition_params(params, extract_path_names(path))
  out <- list(
    method = method,
    path = glue::glue_data(params$path_params, path),
    query = params$query_params,
    body = body,
    token = token,
    .api_key = .api_key
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

partition_body <- function(provided, body_param_names) {
  remaining_params <- provided
  body_params <- NULL
  if (length(body_param_names) && length(remaining_params)) {
    m <- names(remaining_params) %in% body_param_names
    body_params <- remaining_params[m]
    remaining_params <- remaining_params[!m]
  }
  list(
    remaining_params = remaining_params,
    body_params = body_params
  )
}

## extract the path params by name and put the leftovers in query
## why is this correct?
## if the endpoint was specified, we have already matched against spec
## if the endpoint was unspecified, we have no choice
partition_params <- function(provided, path_param_names) {
  query_params <- provided
  path_params <- NULL
  if (length(path_param_names) && length(query_params)) {
    m <- names(provided) %in% path_param_names
    path_params <- query_params[m]
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

drive_ua <- function() {
  httr::user_agent(paste0(
    "googledrive/", utils::packageVersion("googledrive"), " ",
    ## TO DO: uncomment this once we use gargle
    #"gargle/", utils::packageVersion("gargle"), " ",
    "httr/", utils::packageVersion("httr")
  ))
}
