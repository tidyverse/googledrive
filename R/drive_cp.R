#' Copy a Drive file.
#'
#' @seealso Wraps the
#' [drive.files.copy](https://developers.google.com/drive/v3/reference/files/copy)
#' endpoint
#'
#' @template file
#' @template path
#' @param name Character, new file name if not specified as part of `path`. This
#'   will force `path` to be treated as a folder, even if it is character and lacks
#'   a trailing slash. Defaults to "Copy of {CURRENT-FILE-NAME}."
#' @template verbose
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## create a file to copy
#' file <- drive_upload(system.file("DESCRIPTION"), "DESC")
#'
#' ## Make a "Copy of" copy in same folder as the original
#' drive_cp("DESC")
#'
#' ## Make an explicitly named copy in same folder as the original
#' drive_cp("DESC", "DESC-two")
#'
#' ## Make an explicitly named copy in a different folder
#' folder <- drive_mkdir("new-folder")
#' drive_cp("DESC", folder, "DESC-three")
#'
#' ## Behold all of our copies!
#' drive_find("DESC")
#'
#' ## Delete all of our copies and the new folder!
#' drive_find("DESC") %>% drive_rm()
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
    if (is.null(name) && !has_slash(path) && drive_path_exists(append_slash(path))) {
      stop(
        "Unclear if `path` specifies parent folder or full path\n",
        "to the new file, including its name. ",
        "See ?as_dribble() for details.",
        call. = FALSE
      )
    }
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  name <- name %||% glue("Copy of {file$name}")

  params <- list(
    fileId = file$id,
    fields = "*"
  )

  ## if copying to a specific directory, specify the parent
  if (!is.null(path)) {
    path <- as_dribble(path)
    if (!some_files(path)) {
      stop("Requested parent folder does not exist.", call. = FALSE)
    }
    if (!single_file(path)) {
      paths <- glue_data(path, "  * {name}: {id}")
      stop(
        collapse(
          c("Requested parent folder identifies multiple files:", paths),
          sep = "\n"
          ),
        call. = FALSE
      )
    }
    ## if path was input as a dribble or id, still need to be sure it's a folder
    if (!is_folder(path)) {
      stop(
        glue("\n`path` specifies a file that is not a folder:\n * {path$name}"),
        call. = FALSE
      )
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
    message(glue("\nFile copied:\n  * {file$name} -> {new_path}"))
  }
  invisible(out)
}
