#' Copy a Google Drive file.
#'
#' `drive_copy()` is an alias for `drive_cp()`.
#'
#' @seealso Wraps the
#' [drive.files.copy](https://developers.google.com/drive/v3/reference/files/copy)
#' endpoint
#'
#' @template file
#' @template path
#' @param name Character, new file name if not specified as part of `path`. Any
#'   name obtained from `path` overrides this argument. Defaults to "Copy of
#'   {CURRENT-FILE-NAME}."
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
#' drive_search("DESC")
#'
#' ## Delete all of our copies and the new folder!
#' drive_search("DESC") %>% drive_delete()
#' drive_delete(folder)
#' }
#' @export
drive_cp <- function(file = NULL, path = NULL, name = NULL,  verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)
  if (is_folder(file)) {
    stop("The Drive API does not copy folders.", call. = FALSE)
  }

  if (!is.null(name)) {
    stopifnot(is_path(name), length(name) == 1)
  }

  if (is_path(path)) {
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
    ## TO DO:
    ## if `parent = NULL`, we could check if there's a directory at the
    ## original path and infer we should copy into that directory, instead of
    ## onto a file of the same name
    ## i.e. detect this is an append_slash() case
  }

  name <- name %||% glue("Copy of {file$name}")

  params <- list(
    fileId = file$id,
    fields = "*"
  )

  ## if copying to a specific directory, specify the parent
  if (!is.null(path)) {
    path <- as_dribble(path)
    confirm_single_file(path)
    if (!is_folder(path)) {
      stop(
        glue(
          "Requested parent folder does not exist:\n{path$name}"
        ),
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
    ## not entirely sure why this placement of `\n` helps glue do the right
    ## thing and yet ... it does
    new_path <- paste0(append_slash(path$name), out$name)
    message(glue("\nFile copied:\n  * {file$name} -> {new_path}"))
  }
  invisible(out)
}

#' @rdname drive_cp
#' @export
drive_copy <- drive_cp
