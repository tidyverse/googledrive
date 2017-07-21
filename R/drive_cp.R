#' Copy a Drive file.
#'
#' @seealso Wraps the
#' [drive.files.copy](https://developers.google.com/drive/v3/reference/files/copy)
#' endpoint
#'
#' @template file
#' @template path
#' @templateVar name file
#' @templateVar default If not given or unknown, will default to the `file`'s current folder.
#' @template name
#' @templateVar name file
#' @templateVar default Defaults to "Copy of `FILE-NAME`".
#' @template verbose
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## create a file to copy
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
#' ## Behold all of our copies!
#' drive_find("DESC-ex")
#'
#' ## Delete all of our copies and the new folder!
#' drive_find("DESC-ex") %>% drive_rm()
#' drive_rm(folder)
#' }
#' @export
drive_cp <- function(file, path = NULL, name = NULL, verbose = TRUE) {
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

  name <- name %||% glue::glue("Copy of {file$name}")

  params <- list(
    fileId = file$id,
    fields = "*"
  )

  ## if copying to a specific directory, specify the parent
  ## defaults to the current file's directory
  path <- path %||% as_id(file$files_resource[[1]]$parents[[1]])
  path <- as_dribble(path)
  if (!single_file(path)) {
    paths <- glue::glue_data(path, "  * {name}: {id}")
    scollapse(
      c("Requested parent folder identifies multiple files:", paths),
      sep = "\n"
    )
  }
  ## if path was input as a dribble or id, still need to be sure it's a folder
  if (!is_folder(path)) {
    sglue("\n`path` specifies a file that is not a folder:\n * {path$name}")
  }
  params[["parents"]] <- list(path$id)


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
    mglue("\nFile copied:\n  * {file$name} -> {new_path}")
  }
  invisible(out)
}
