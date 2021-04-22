#' Create a new blank Drive file
#'
#' Creates a new blank Drive file. Note there are better options for these
#' special cases:
#'   * Creating a folder? Use [drive_mkdir()].
#'   * Want to upload existing local content into a new Drive file? Use
#'     [drive_upload()].
#'
#' @seealso Wraps the `files.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/create>
#'
#' @param name Name for the new file or, optionally, a path that specifies
#'   an existing parent folder, as well as the new file name.
#' @param path Target destination for the new item, i.e. a folder or a shared
#'   drive. Can be given as an actual path (character), a file id or URL marked
#'   with [as_id()], or a [`dribble`]. Defaults to your "My Drive" root folder.
#' @param type Character. Create a blank Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively. All non-`NULL` values for `type` are pre-processed with
#'   [drive_mime_type()].
#' @template dots-metadata
#' @template overwrite
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' # Create a blank Google Doc named 'WordStar' in
#' # your 'My Drive' root folder and star it
#' wordstar <- drive_create("WordStar", type = "document", starred = TRUE)
#'
#' # is 'WordStar' really starred? YES
#' purrr::pluck(wordstar, "drive_resource", 1, "starred")
#'
#' # Create a blank Google Slides presentation in
#' # the root folder, and set its description
#' execuvision <- drive_create(
#'   "ExecuVision",
#'   type = "presentation",
#'   description = "deeply nested bullet lists FTW"
#' )
#'
#' # Did we really set the description? YES
#' purrr::pluck(execuvision, "drive_resource", 1, "description")
#'
#' # check out the new presentation
#' drive_browse(execuvision)
#'
#' # Create folder 'b4xl' in the root folder,
#' # then create an empty new Google Sheet in it
#' b4xl <- drive_mkdir("b4xl")
#' drive_create("VisiCalc", path = b4xl, type = "spreadsheet")
#'
#' # Another way to create a Google Sheet in the folder 'b4xl'
#' drive_create("b4xl/SuperCalc", type = "spreadsheet")
#'
#' # Yet another way to create a new file in a folder,
#' # this time specifying parent `path` as a character
#' drive_create("Lotus 1-2-3", path = "b4xl", type = "spreadsheet")
#'
#' # Did we really create those Sheets in the intended folder? YES
#' drive_ls("b4xl")
#'
#' # `overwrite = FALSE` errors if file already exists at target filepath
#' # THIS WILL ERROR!
#' drive_create("VisiCalc", path = b4xl, overwrite = FALSE)
#'
#' # `overwrite = TRUE` moves an existing file to trash, then proceeds
#' drive_create("VisiCalc", path = b4xl, overwrite = TRUE)
#'
#' # clean up
#' drive_rm(wordstar, b4xl, execuvision)
#' }
drive_create <- function(name,
                         path = NULL,
                         type = NULL,
                         ...,
                         overwrite = NA,
                         verbose = deprecated()) {
  warn_for_verbose(verbose)

  # the order and role of `path` and `name` is naturally inverted here,
  # relative to all other related functions, hence we pre-process
  stopifnot(is_string(name))
  if (is.null(path)) {
    path <- name
    name <- NULL
  }
  tmp <- rationalize_path_name(path, name)
  path <- tmp$path
  name <- tmp$name

  params <- toCamel(list2(...))

  # load (path, name) into params
  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- list(path[["id"]])
  }
  params[["name"]] <- name
  check_for_overwrite(params[["parents"]], params[["name"]], overwrite)

  params[["fields"]] <- params[["fields"]] %||% "*"
  params[["mimeType"]] <- drive_mime_type(type)

  request <- request_generate(
    endpoint = "drive.files.create",
    params = params
  )
  response <- request_make(request)
  proc_res <- gargle::response_process(response)

  out <- as_dribble(list(proc_res))

  drive_bullets(c(
    "Created Drive file:",
    cli_format_dribble(out),
    "with MIME type:",
    "*" = "{out$drive_resource[[1]]$mimeType}"
  ))
  invisible(out)
}
