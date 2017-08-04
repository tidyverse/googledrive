#' Move a Drive file.
#'
#' Move a Drive file to a different folder, give it a different name, or both.
#' Note that folders on Google Drive are not like folders on your local
#' filesystem. They are more like a label, which implies that a Drive file can
#' have multiple folders as direct parent! However, most people still use and
#' think of them like "regular" folders. When we say "move a Drive file", it
#' actually means: "add a new folder to this file's parents and remove the old
#' one".
#'
#' @template file
#' @template path
#' @templateVar name file
#' @templateVar default {}
#' @template name
#' @templateVar name file
#' @templateVar default Defaults to current name.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## create a file to move
#' file <- drive_upload(system.file("DESCRIPTION"), "DESC-mv")
#'
#' ## rename it, but leave in current folder (root folder, in this case)
#' file <- drive_mv(file, "DESC-mv-renamed")
#'
#' ## create a folder to move the file into
#' folder <- drive_mkdir("mv-folder")
#'
#' ## move the file and rename it again,
#' ## specify destination as a dribble
#' file <- drive_mv(file, path = folder, name = "DESC-mv-re-renamed")
#'
#' ## verify renamed file is now in the folder
#' drive_ls(folder)
#'
#' ## move the file back to root folder
#' file <- drive_mv(file, "~/")
#'
#' ## move it again
#' ## specify destination as path with trailing slash
#' ## to ensure we get a move vs. renaming it to "mv-folder"
#' file <- drive_mv(file, "mv-folder/")
#'
#' ## Clean up
#' drive_rm(file)
#' drive_rm(folder)
#' }
drive_mv <- function(file, path = NULL, name = NULL, verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_some_files(file)

  if (!single_file(file)) {
    files <- glue_data(file, "  * {name}: {id}")
    stop_collapse(c("Path to move is not unique:", files))
  }

  if (!is_mine(file)) {
    stop_glue("\nCan't move this file because you don't own it:\n  * {file$name}")
  }

  if (is.null(path) && is.null(name)) {
    if (verbose) message("Nothing to be done.")
    return(invisible(file))
  }

  if (!is.null(name)) {
    stopifnot(is_string(name))
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name %||% file$name
  }

  meta <- list()

  if (!is.null(name)) {
    meta[["name"]] <- name
  }

  ## if moving the file, modify the parent
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
    if (!is_folder(path)) {
      stop_glue("Requested parent folder does not exist:\n{path$name}")
    }
    current_parents <- file$drive_resource[[1]][["parents"]]
    if (!path$id %in% current_parents) {
      meta[["addParents"]] <- path$id
      if (length(current_parents) == 1) {
        meta[["removeParents"]] <- current_parents
      } else {
        warning(
          "File started with multiple parents!\n",
          "New parent folder has been added, but no existing parent has been removed.\n",
          "Not clear which parent(s) should be removed."
        )
      }
    }
  }

  if (length(meta) == 0) {
    if (verbose) message("Nothing to be done.")
    return(invisible(file))
  }
  out <- drive_update_metadata(file, meta)

  if (verbose) {
    actions <- c(
      renamed = !identical(out$name, file$name),
      moved = !is.null(meta[["removeParents"]])
    )
    new_path <- paste0(append_slash(path$name), out$name)
    message_glue(
      "\nFile {action}:\n  * {file$name} -> {new_path}",
      action = collapse(names(actions)[actions], last = " and ")
    )
  }
  invisible(out)
}
