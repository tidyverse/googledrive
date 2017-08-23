#' Build a request for the Google Drive v3 API
#'
#' Build a request, using some knowledge of the
#' [Drive v3 API](https://developers.google.com/drive/v3/web/about-sdk). Most
#' users should, instead, use higher-level wrappers that facilitate common
#' tasks, such as uploading or downloading Drive files. The functions here are
#' intended for internal use and for programming around the Drive API.
#'
#' There are two functions:
#' * `generate_request()` lets you provide the bare minimum of input. It takes a
#'   nickname for an endpoint and:
#'   - Uses the API spec to look up the `path` and `method`.
#'   - Checks `params` for validity and completeness with respect to the
#'     endpoint. Separates body parameters from those destined for path
#'     substitution or the query.
#'   - Adds an API key to the query if `token = NULL`. Or, at least, we try.
#'   - Adds `supportsTeamDrives = TRUE` to the query if the endpoint requires.
#'
#'   `generate_request()` then passes things along to `build_request()`. Use
#'   [drive_endpoints()] to see which endpoints can be accessed this way.
#' * `build_request()` builds a request from explicit parts. It is quite
#' dumb, only doing URL endpoint substitution and URL formation. It's up to the
#' caller to make sure the `path`, `method`, `params`, `body`, and `token` are
#' valid. Use this to call a Drive API endpoint that doesn't appear in the list
#' returned by [drive_endpoints()].
#'
#' @param endpoint Character. Nickname for one of the selected Drive v3 API
#'   endpoints built into googledrive. Learn more in [drive_endpoints()].
#' @param params Named list. Parameters destined for endpoint URL substitution,
#'   the query, or, for `generate_request()` only, the body.
#' @param key API key. Will be needed for requests that don't contain a token.
#'   The need for an API key in the absence of a token is explained in Google's
#'   document
#'   [Credentials, access, security, and identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279).
#'   In order of precedence, these sources are consulted: the formal `key`
#'   argument, a `key` parameter in `params`, a pre-configured API key fetched
#'   via [drive_api_key()]. googledrive ships with a built-in key or users can
#'   override with their own via [drive_auth_config()].
#' @param token Drive token. Set to `NULL` to suppress the inclusion of a token.
#'   Note that, if auth has been de-activated via [drive_auth_config()],
#'   `drive_token()` will actually return `NULL`.
#'
#' @return `list()`\cr Components are `method`, `path`, `query`, `body`,
#'   `token`, and `url`, suitable as input for [make_request()]. The `path` is
#'   post-substitution and the `query` is a named list of all the non-body
#'   `params` that were not used during this substitution. `url` is the full URL
#'   after prepending the base URL for the Drive v3 API and appending the query.
#' @export
#' @family low-level API functions
#' @examples
#' req <- generate_request(
#'   "drive.files.get",
#'   list(fileId = "abc"),
#'   token = NULL
#' )
#' req
generate_request <- function(endpoint = character(),
                             params = list(),
                             key = NULL,
                             token = drive_token()) {
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop_glue("\nEndpoint not recognized:\n  * {endpoint}")
  }

  params <- match_params(params, ept$parameters)
  params <- partition_params(params, extract_body_names(ept$parameters))

  if (is.null(token)) {
    key <- key %||% params[["unmatched"]][["key"]] %||% drive_api_key()
    if (is.null(key)) {
      warning_glue("Request contains neither a token nor an API key.")
    } else {
      params[["unmatched"]][["key"]] <- key
    }
  }

  if (!is.null(ept[["parameters"]][["supportsTeamDrives"]])) {
    params[["unmatched"]][["supportsTeamDrives"]] <- TRUE
  }

  build_request(
    path = ept$path,
    method = ept$method,
    params = params$unmatched,
    body = params$matched,
    token = token
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
#'   list(fileId = "abc", key = drive_api_key()),
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
#'     fileId = "your-file-id-goes-here",
#'     fields = "*"
#'   ),
#'   token = googledrive:::drive_token()
#' )
#' process_response(make_request(req))
#' }
build_request <- function(path = "",
                          method,
                          params = list(),
                          body = list(),
                          token = NULL) {

  params <- partition_params(params, extract_path_names(path))

  out <- list(
    method = method,
    path = glue_data(params$matched, path),
    query = params$unmatched,
    body = body,
    token = token
  )

  out$url <- httr::modify_url(
    url = .drive$base_url,
    path = out$path,
    ## prevent a trailing `?` or `?=` when the query is trivial, e.g. list() or
    ## contains a single element which is NULL
    ## https://github.com/r-lib/httr/issues/451
    query = if (length(unlist(out$query)) == 0) NULL else out$query
  )
  out
}

## match params provided by user to spec
##   * error if required params are missing
##   * error for unknown params
match_params <- function(provided, spec) {
  ## .endpoints %>% map("parameters") %>% flatten() %>% map_lgl("required")
  required <- spec %>% purrr::keep("required") %>% names()
  missing <- setdiff(required, names(provided))
  if (length(missing)) {
    stop_collapse(
      c("Required parameter(s) are missing:", missing)
    )
  }

  unknown <- setdiff(names(provided), names(spec))
  if (length(unknown)) {
    stop_collapse(
      c("These parameters are not recognized for this endpoint:", unknown)
    )
  }

  provided
}

## partition a parameter list into two parts, using names to identify
## components destined for the second part
## example input:
# partition_params(
#   list(a = "a", b = "b", c = "c", d = "d"),
#   c("b", "c")
# )
## example output:
# list(
#   unmatched = list(a = "a", d = "d"),
#   matched = list(b = "b", c = "c")
# )
partition_params <- function(input, nms_to_match) {
  out <- list(
    unmatched = input,
    matched = list()
  )
  if (length(nms_to_match) && length(input)) {
    m <- names(out$unmatched) %in% nms_to_match
    out$matched <- out$unmatched[m]
    out$unmatched <- out$unmatched[!m]
  }
  out
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
