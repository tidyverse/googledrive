#' Create a new blank Drive file
#'
#' Creates a new blank Drive file. To create a new Drive *folder*,
#' use [drive_mkdir()]. To upload an existing local file into
#' Drive, use [drive_upload()].
#'
#' @seealso Wraps the `files.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/create>
#'
#' @param name Name for the new file or, optionally, a path that specifies
#'   an existing parent folder, as well as the new file name.
#' @param parent Target destination for the new file, i.e. a folder or a Team
#'   Drive. Can be given as an actual path (character), a file id, or URL marked
#'   with [as_id()], or a [`dribble`]. Defaults to your "My Drive" root folder.
#' @param type Character. Create a blank Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively. All non-`NULL` values for `type` are pre-processed with
#'   [drive_mime_type()].
#' @template dots-metadata
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Create a blank Google Doc named 'Word Star' in
#' ## your 'My Drive' root folder and star it
#' wordstar <- drive_create("WordStar", type = "document", starred = TRUE)
#'
#' ## is 'WordStar' really starred? YES
#' purrr::pluck(wordstar, "drive_resource", 1, "starred")
#'
#' ## Create a blank Google Slides presentation in
#' ## the root folder, and set its description
#' execuvision <- drive_create(
#'   "ExecuVision",
#'   type = "presentation",
#'   description = "deeply nested bullet lists FTW"
#' )
#'
#' ## Did we really set the description? YES
#' purrr::pluck(execuvision, "drive_resource", 1, "description")
#'
#' ## check out the new presentation
#' drive_browse(execuvision)
#'
#' ## Create folder 'b4xl' in the root folder,
#' ## then create an empty new Google Sheet in it
#' b4xl <- drive_mkdir("b4xl")
#' drive_create("VisiCalc", parent = b4xl, type = "spreadsheet")
#'
#' ## Another way to create a Google Sheet in the folder 'spreadsheets'
#' drive_create("b4xl/SuperCalc", type = "spreadsheet")
#'
#' ## Another way to create a new file in a folder,
#' ## this time specifying `parent` as a character
#' drive_create("Lotus 1-2-3", parent = "b4xl", type = "spreadsheet")
#'
#' ## clean up
#' drive_rm(wordstar, b4xl, execuvision)
#' }
drive_create <- function(name,
                         parent = NULL,
                         type = NULL,
                         ...,
                         verbose = TRUE) {
  stopifnot(is_string(name))

  ## wire up to the conventional 'path' and 'name' pattern used elsewhere
  if (is.null(parent)) {
    path <- name
    name <- NULL
  } else {
    path <- parent
  }

  if (is_path(path)) {
    if (is.null(name)) {
      path <- strip_slash(path)
    }
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  params <- toCamel(list(...))
  params[["name"]] <- name
  params[["fields"]] <- params[["fields"]] %||% "*"
  params[["mimeType"]] <- drive_mime_type(type)

  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- list(path[["id"]])
  }

  request <- request_generate(
    endpoint = "drive.files.create",
    params = params
  )
  response <- request_make(request, encode = "json")
  proc_res <- gargle::response_process(response)

  out <- as_dribble(list(proc_res))

  if (verbose) {
    message_glue(
      "\nCreated Drive file:\n  * {out$name}: {out$id}\n",
      "with MIME type:\n  * {out$drive_resource[[1]]$mimeType}"
    )
  }
  invisible(out)
}
