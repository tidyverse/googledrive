#' Create a Drive folder
#'
#' Creates a new Drive folder. To update the metadata of an existing Drive file,
#' including a folder, use [drive_update()].
#'
#' @seealso Wraps the `files.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/create>
#'
#' @param name Name for the new folder or, optionally, a path that specifies
#'   an existing parent folder, as well as the new name.
#' @param parent Target destination for the new folder, i.e. a folder or a Team
#'   Drive. Can be given as an actual path (character), a file id or URL marked
#'   with [as_id()], or a [`dribble`]. Defaults to your "My Drive" root folder.
#' @template dots-metadata
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Create folder named 'ghi', then another below named it 'jkl' and star it
#' ghi <- drive_mkdir("ghi")
#' jkl <- drive_mkdir("ghi/jkl", starred = TRUE)
#'
#' ## is 'jkl' really starred? YES
#' purrr::pluck(jkl, "drive_resource", 1, "starred")
#'
#' ## Another way to create folder 'mno' in folder 'ghi'
#' drive_mkdir("mno", parent = "ghi")
#'
#' ## Yet another way to create a folder named 'pqr' in folder 'ghi',
#' ## this time with parent folder stored in a dribble,
#' ## and setting the new folder's description
#' pqr <- drive_mkdir("pqr", parent = ghi, description = "I am a folder")
#'
#' ## Did we really set the description? YES
#' purrr::pluck(pqr, "drive_resource", 1, "description")
#'
#' ## clean up
#' drive_rm(ghi)
#' }
drive_mkdir <- function(name,
                        parent = NULL,
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
  params[["mimeType"]] <- "application/vnd.google-apps.folder"

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

  success <- out$name == name
  if (verbose) {
    new_path <- paste0(append_slash(path$name), out$name)
    message_glue(
      "\nFolder {if (success) '' else 'NOT '}created:\n",
      "  * {new_path}"
    )
  }
  invisible(out)
}
