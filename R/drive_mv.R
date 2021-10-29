#' Move a Drive file
#'
#' Move a Drive file to a different folder, give it a different name, or both.
#'

#' @seealso Makes a metadata-only request to the `files.update` endpoint:
#'   * <https://developers.google.com/drive/api/v3/reference/files/update>

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
#' @eval return_dribble()
#' @export
#' @examplesIf drive_has_token()
#' # create a file to move
#' file <- drive_example_remote("chicken.txt") %>%
#'   drive_cp("chicken-mv.txt")
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
#' drive_create("name-squatter-mv", path = "~/")
#' drive_mv(file, path = "~/", name = "name-squatter-mv", overwrite = FALSE)
#'
#' # `overwrite = TRUE` moves the existing item to trash, then proceeds
#' drive_mv(file, path = "~/", name = "name-squatter-mv", overwrite = TRUE)
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
  if (!is.null(path)) {
    path <- as_parent(path)
    if (!path$id %in% parents_before) {
      params[["addParents"]] <- path$id
      params[["removeParents"]] <- unlist(parents_before)
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

  actions <- c(
    renamed = !identical(out$name, file$name),
    moved = !is.null(params[["addParents"]])
  )
  action <- glue_collapse(names(actions)[actions], last = " and ")

  drive_bullets(c(
    "Original file:",
    bulletize(gargle_map_cli(file)),
    "Has been {action}:",
    # drive_reveal_path() puts immediate parent, if specified, in the `path`
    # then we reveal `path`, instead of `name`
    bulletize(gargle_map_cli(
      drive_reveal_path(out, ancestors = path),
      template = c(
        id_string = "<id:\u00a0<<id>>>", # \u00a0 is a nonbreaking space
        out = "{.drivepath <<path>>} {cli::col_grey('<<id_string>>')}"
      )
    ))
  ))

  invisible(out)
}
