#' Build a request for the Google Drive API
#'
#' @description Build a request, using knowledge of the [Drive v3
#'   API](https://developers.google.com/drive/v3/web/about-sdk) from its
#'   [Discovery
#'   Document](https://www.googleapis.com/discovery/v1/apis/drive/v3/rest). Most
#'   users should, instead, use higher-level wrappers that facilitate common
#'   tasks, such as uploading or downloading Drive files. The functions here are
#'   intended for internal use and for programming around the Drive API.
#'
#' @description `request_generate()` lets you provide the bare minimum of input.
#'   It takes a nickname for an endpoint and:
#'   * Uses the API spec to look up the `path`, `method`, and base URL.
#'   * Checks `params` for validity and completeness with respect to the
#'   endpoint. Separates parameters into those destined for the body, the query,
#'   and URL endpoint substitution (which is also enacted).
#'   * Adds an API key to the query if and only if `token = NULL`.
#'   * Adds `supportsTeamDrives = TRUE` to the query if the endpoint requires.
#'
#' @param endpoint Character. Nickname for one of the selected Drive v3 API
#'   endpoints built into googledrive. Learn more in [drive_endpoints()].
#' @param params Named list. Parameters destined for endpoint URL substitution,
#'   the query, or the body.
#' @param key API key. Needed for requests that don't contain a token. The need
#'   for an API key in the absence of a token is explained in Google's document
#'   [Credentials, access, security, and
#'   identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279).
#'    In order of precedence, these sources are consulted: the formal `key`
#'   argument, a `key` parameter in `params`, a user-configured API key fetched
#'   via [drive_api_key()], a built-in key shipped with googledrive. See
#'   [drive_auth_configure()] for details on a user-configured key.
#' @param token Drive token. Set to `NULL` to suppress the inclusion of a token.
#'   Note that, if auth has been de-activated via [drive_deauth()],
#'   `drive_token()` will actually return `NULL`.
#'
#' @return `list()`\cr Components are `method`, `path`, `query`, `body`,
#'   `token`, and `url`, suitable as input for [request_make()].
#' @export
#' @family low-level API functions
#' @seealso [gargle::request_develop()], [gargle::request_build()]
#' @examples
#' \dontrun{
#' req <- request_generate(
#'   "drive.files.get",
#'   list(fileId = "abc"),
#'   token = drive_token()
#' )
#' req
#' }
request_generate <- function(endpoint = character(),
                             params = list(),
                             key = NULL,
                             token = drive_token()) {
  ept <- drive_endpoint(endpoint)
  if (is.null(ept)) {
    stop_glue("\nEndpoint not recognized:\n  * {endpoint}")
  }

  ## modifications specific to googledrive package
  params$key <- key %||% params$key %||%
    drive_api_key() %||% gargle::tidyverse_api_key()
  if (!is.null(ept$parameters$supportsAllDrives)) {
    params$supportsAllDrives <- TRUE
  }

  req <- gargle::request_develop(endpoint = ept, params = params)
  gargle::request_build(
    path = req$path,
    method = req$method,
    params = req$params,
    body = req$body,
    token = token
  )
}
