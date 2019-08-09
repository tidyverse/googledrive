#' Copy a Drive file
#'
#' Copies an existing Drive file into a new file id.
#'
#' @seealso Wraps the `files.copy` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/copy>
#'
#' @template file-singular
#' @template path
#' @templateVar name file
#' @templateVar default {}
#' @template name
#' @templateVar name file
#' @templateVar default Defaults to "Copy of `FILE-NAME`".
#' @template dots-metadata
#' @template verbose
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## Create a file to copy
#' file <- drive_upload(drive_example("chicken.txt"), "chicken-cp.txt")
#'
#' ## Make a "Copy of" copy in same folder as the original
#' drive_cp("chicken-cp.txt")
#'
#' ## Make an explicitly named copy in same folder as the original
#' drive_cp("chicken-cp.txt", "chicken-cp-two.txt")
#'
#' ## Make an explicitly named copy in a different folder
#' folder <- drive_mkdir("new-folder")
#' drive_cp("chicken-cp.txt", path = folder, name = "chicken-cp-three.txt")
#'
#' ## Make an explicitly named copy and star it.
#' ## The starring is an example of providing metadata via `...`.
#' ## `starred` is not an actual argument to `drive_cp()`,
#' ## it just gets passed through to the API.
#' drive_cp("chicken-cp.txt", name = "chicken-cp-starred.txt", starred = TRUE)
#'
#' ## Behold all of our copies!
#' drive_find("chicken-cp")
#'
#' ## Delete all of our copies and the new folder!
#' drive_find("chicken-cp") %>% drive_rm()
#' drive_rm(folder)
#'
#' ## upload a csv file to copy
#' csv_file <- drive_upload(drive_example("chicken.csv"))
#'
#' ## copy AND AT THE SAME TIME convert it to a Google Sheet
#' chicken_sheet <- drive_cp(
#'   csv_file,
#'   name = "chicken-cp",
#'   mime_type = drive_mime_type("spreadsheet")
#' )
#'
#' ## go see the new Sheet in the browser
#' ## drive_browse(chicken_sheet)
#'
#' ## clean up
#' drive_rm(csv_file, chicken_sheet)
#' }
#' @export
drive_cp <- function(file, path = NULL, name = NULL, ..., verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)
  if (is_parental(file)) {
    stop_glue("The Drive API does not copy folders or Team Drives.")
  }

  # vet (path, name)
  if (!is.null(name)) {
    stopifnot(is_string(name))
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  params <- toCamel(list(...))

  # load (path, name) into params
  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- list(path$id)
  }
  params[["name"]] <- name %||% glue("Copy of {file$name}")

  params[["fields"]] <- params[["fields"]] %||% "*"
  params[["fileId"]] <- file$id

  request <- request_generate(
    endpoint = "drive.files.copy",
    params = params
  )
  res <- request_make(request, encode = "json")
  proc_res <- gargle::response_process(res)

  out <- as_dribble(list(proc_res))

  if (verbose) {
    new_path <- paste0(append_slash(path$name), out$name)
    message_glue("\nFile copied:\n  * {file$name} -> {new_path}")
  }
  invisible(out)
}
