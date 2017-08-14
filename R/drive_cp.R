#' Copy a Drive file.
#'
#' Copies an existing Drive file into a new file id.
#'
#' @seealso Wraps the `files.copy` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/copy>
#'
#' @template file
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
#' file <- drive_upload(system.file("DESCRIPTION"), "DESC-ex")
#'
#' ## Make a "Copy of" copy in same folder as the original
#' drive_cp("DESC-ex")
#'
#' ## Make an explicitly named copy in same folder as the original
#' drive_cp("DESC-ex", "DESC-ex-two")
#'
#' ## Make an explicitly named copy in a different folder
#' folder <- drive_mkdir("new-folder")
#' drive_cp("DESC-ex", folder, "DESC-ex-three")
#'
#' ## Make an explicitly named copy and star it.
#' ## The starring is an example of providing metadata via `...`.
#' ## `starred` is not an actual argument to `drive_cp()`,
#' ## it just gets passed through to the API.
#' drive_cp("DESC-ex", name = "DESC-ex-starred", starred = TRUE)
#'
#' ## Behold all of our copies!
#' drive_find("DESC-ex")
#'
#' ## Delete all of our copies and the new folder!
#' drive_find("DESC-ex") %>% drive_rm()
#' drive_rm(folder)
#'
#' ## upload a csv file to copy
#' csv_file <- drive_upload(R.home('doc/BioC_mirrors.csv'))
#'
#' ## copy AND AT THE SAME TIME convert it to a Google Sheet
#' mirrors_sheet <- drive_cp(
#'   csv_file,
#'   name = "BioC_mirrors",
#'   mimeType = drive_mime_type("spreadsheet")
#' )
#'
#' ## go see the new Sheet in the browser
#' ## drive_browse(mirrors_sheet)
#'
#' ## clean up
#' drive_rm(csv_file, mirrors_sheet)
#' }
#' @export
drive_cp <- function(file, path = NULL, name = NULL, ..., verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)
  if (is_parental(file)) {
    stop_glue("The Drive API does not copy folders or Team Drives.")
  }

  if (!is.null(name)) {
    stopifnot(is_string(name))
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  name <- name %||% glue("Copy of {file$name}")

  dots <- toCamel(list(...))
  dots$fields <- dots$fields %||% "*"
  params <- c(
    fileId = file$id,
    dots
  )

  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- list(path$id)
  }

  if (!is.null(name)) {
    params[["name"]] <- name
  }

  request <-  generate_request(
    endpoint = "drive.files.copy",
    params = params
  )
  res <- make_request(request, encode = "json")
  proc_res <- process_response(res)

  out <- as_dribble(list(proc_res))

  if (verbose) {
    new_path <- paste0(append_slash(path$name), out$name)
    message_glue("\nFile copied:\n  * {file$name} -> {new_path}")
  }
  invisible(out)
}
