#' Move a Drive file
#'
#' Move a Drive file to a different folder, give it a different name, or both.
#'
#' @template file-singular
#' @eval param_path(
#'   thing = "file",
#'   default_notes = "By default, the file stays in its current folder."
#' )
#' @eval param_name(
#'   thing = "file",
#'   default_notes = "By default, the file keeps its current name."
#' )
#' @template overwrite
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examplesIf drive_has_token()
#' # create a file to move
#' file <- drive_upload(drive_example("chicken.txt"), "chicken-mv.txt")
#'
#' # rename it, but leave in current folder (root folder, in this case)
#' file <- drive_mv(file, "chicken-mv-renamed.txt")
#'
#' # create a folder to move the file into
#' folder <- drive_mkdir("mv-folder")
#'
#' # move the file and rename it again,
#' # specify destination as a dribble
#' file <- drive_mv(file, path = folder, name = "chicken-mv-re-renamed.txt")
#'
#' # verify renamed file is now in the folder
#' drive_ls(folder)
#'
#' # move the file back to root folder
#' file <- drive_mv(file, "~/")
#'
#' # move it again
#' # specify destination as path with trailing slash
#' # to ensure we get a move vs. renaming it to "mv-folder"
#' file <- drive_mv(file, "mv-folder/")
#'
#' # `overwrite = FALSE` errors if something already exists at target filepath
#' # THIS WILL ERROR!
#' drive_create("name-squatter", path = "~/")
#' drive_mv(file, path = "~/", name = "name-squatter", overwrite = FALSE)
#'
#' # `overwrite = TRUE` moves the existing item to trash, then proceeds
#' drive_mv(file, path = "~/", name = "name-squatter", overwrite = TRUE)
#'
#' # Clean up
#' drive_rm(file, folder)
drive_mv <- function(file,
                     path = NULL,
                     name = NULL,
                     overwrite = NA,
                     verbose = deprecated()) {
  warn_for_verbose(verbose)

  file <- as_dribble(file)
  file <- confirm_single_file(file)

  if (is.null(path) && is.null(name)) {
    drive_bullets(c(
      "!" = "Nothing to be done."
    ))
    return(invisible(file))
  }

  tmp <- rationalize_path_name(path, name)
  path <- tmp$path
  name <- tmp$name

  params <- list()

  # load (path, name) into params ... maybe
  parents_before <- pluck(file, "drive_resource", 1, "parents")
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
    drive_bullets(c(
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
  action = glue_collapse(names(actions)[actions], sep = ",", last = " and ")

  drive_bullets(c(
    "Original file:",
    bulletize(map_cli(file)),
    "Has been {action}:",
    # drive_reveal_path() puts immediate parent in the path, if specified
    # TODO: still need to request that `path` is revealed, instead of `name`
    bulletize(map_cli(drive_reveal_path(out, ancestors = path)))
  ))

  invisible(out)
}
