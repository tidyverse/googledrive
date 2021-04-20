#' Move a Drive file
#'
#' Move a Drive file to a different folder, give it a different name, or both.
#' Note that folders on Google Drive are not like folders on your local
#' filesystem. They are more like a label, which implies that a Drive file can
#' have multiple folders as direct parent! However, most people still use and
#' think of them like "regular" folders. When we say "move a Drive file", it
#' actually means: "add a new folder to this file's parents and remove the old
#' one".
#'
#' @template file-singular
#' @template path
#' @templateVar name file
#' @templateVar default {}
#' @template name
#' @templateVar name file
#' @templateVar default Defaults to current name.
#' @template overwrite
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## create a file to move
#' file <- drive_upload(drive_example("chicken.txt"), "chicken-mv.txt")
#'
#' ## rename it, but leave in current folder (root folder, in this case)
#' file <- drive_mv(file, "chicken-mv-renamed.txt")
#'
#' ## create a folder to move the file into
#' folder <- drive_mkdir("mv-folder")
#'
#' ## move the file and rename it again,
#' ## specify destination as a dribble
#' file <- drive_mv(file, path = folder, name = "chicken-mv-re-renamed.txt")
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
#' ## `overwrite = FALSE` errors if something already exists at target filepath
#' ## THIS WILL ERROR!
#' drive_create("name-squatter", path = "~/")
#' drive_mv(file, path = "~/", name = "name-squatter", overwrite = FALSE)
#'
#' ## `overwrite = TRUE` moves the existing item to trash, then proceeds
#' drive_mv(file, path = "~/", name = "name-squatter", overwrite = TRUE)
#'
#' ## Clean up
#' drive_rm(file, folder)
#' }
drive_mv <- function(file,
                     path = NULL,
                     name = NULL,
                     overwrite = NA,
                     verbose = deprecated()) {
  warn_for_verbose(verbose)

  file <- as_dribble(file)
  file <- confirm_single_file(file)

  if (is.null(path) && is.null(name)) {
    drive_memo(c(
      "!" = "Nothing to be done."
    ))
    return(invisible(file))
  }

  tmp <- rationalize_path_name(path, name)
  path <- tmp$path
  name <- tmp$name

  params <- list()

  # load (path, name) into params ... maybe
  parents_before <- purrr::pluck(file, "drive_resource", 1, "parents")
  n_parents_before <- length(parents_before)
  if (!is.null(path)) {
    path <- as_parent(path)
    if (!path$id %in% parents_before) {
      params[["addParents"]] <- path$id
      if (n_parents_before == 1) {
        params[["removeParents"]] <- parents_before
      } else if (n_parents_before > 1) {
        warning(
          "File started with multiple parents!\n",
          "New parent folder has been added, but no existing parent has ",
          "been removed.\n",
          "Not clear which parent(s) should be removed."
        )
      }
    }
  }
  if (!is.null(name) && name != file$name) {
    params[["name"]] <- name
  }

  if (length(params) == 0) {
    drive_memo(c(
      "!" = "Nothing to be done."
    ))
    return(invisible(file))
  }

  check_for_overwrite(
    parent = params[["addParents"]] %||% parents_before[[1]],
    name   = params[["name"]]       %||% file$name,
    overwrite = overwrite
  )

  params[["fields"]] <- "*"
  out <- drive_update_metadata(file, params)

  parent_added <- !is.null(params[["addParents"]])
  actions <- c(
    renamed = !identical(out$name, file$name),
    moved = parent_added && n_parents_before < 2,
    `added to folder` = parent_added && n_parents_before > 1
  )
  new_path <- paste0(append_slash(path$name), out$name)
  message_glue(
    "\nFile {action}:\n  * {file$name} -> {new_path}",
    action = glue_collapse(
      names(actions)[actions],
      sep = ",", last = " and "
    )
  )

  invisible(out)
}
