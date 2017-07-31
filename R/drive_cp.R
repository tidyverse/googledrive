#' Copy a Drive file.
#'
#' Copies an existing Drive file into a new file id.
#'
#' @seealso Wraps the
#' [drive.files.copy](https://developers.google.com/drive/v3/reference/files/copy)
#' endpoint.
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
#'   file,
#'   name = "BioC_mirrors",
#'   mimeType = drive_mime_type("spreadsheet")
#' )
#'
#' ## go see the new Sheet in the browser
#' ## drive_browse(mirrors_sheet)
#'
#' ## clean up
#' drive_rm(csv_file)
#' drive_rm(mirrors_sheet)
#' }
#' @export
drive_cp <- function(file, path = NULL, name = NULL, ..., verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)
  if (is_folder(file)) {
    stop("The Drive API does not copy folders.", call. = FALSE)
  }

  if (!is.null(name)) {
    stopifnot(is_path(name), length(name) == 1)
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  name <- name %||% glue("Copy of {file$name}")

  dots <- list(...)
  dots$fields <- dots$fields %||% "*"
  params <- c(
    fileId = file$id,
    dots
  )

  ## if copying to a specific directory, specify the parent
  if (!is.null(path)) {
    path <- as_dribble(path)
    if (!some_files(path)) {
      stop_glue("Requested parent folder does not exist.")
    }
    if (!single_file(path)) {
      paths <- glue_data(path, "  * {name}: {id}")
      stop_collapse(
        c("Requested parent folder identifies multiple files:", paths)
      )
    }
    ## if path was input as a dribble or id, still need to be sure it's a folder
    if (!is_folder(path)) {
      stop_glue("\n`path` specifies a file that is not a folder:\n * {path$name}")
    }
    params[["parents"]] <- list(path$id)
  }


  ## if new name is specified, send it
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
