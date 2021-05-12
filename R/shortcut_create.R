#' Create a shortcut to a Drive file
#'
#' Creates a shortcut to the target Drive `file`, which could be a folder. A
#' Drive shortcut functions like a symbolic or "soft" link and is primarily
#' useful for creating a specific Drive user experience in the browser, i.e. to
#' make a Drive file or folder appear in more than 1 place. Shortcuts are a
#' relatively new feature in Drive; they were introduced when Drive stopped
#' allowing a file to have more than 1 parent folder.
#'
#' @template file-singular

#' @eval param_path(
#'   thing = "shortcut",
#'   default_notes = "By default, the shortcut is created in the current
#'     user's \"My Drive\" root folder."
#' )
#' @eval param_name(
#'   thing = "shortcut",
#'   default_notes = "By default, the shortcut starts out with the same name as
#'     the target `file`. As a consequence, if you want to use
#'     `overwrite = TRUE` or `overwrite = FALSE`, you **must** explicitly
#'     specify the shortcut's `name`."
#' )

#' @template overwrite
#' @template dribble-return
#' @export

#' @seealso
#'   * <https://developers.google.com/drive/api/v3/shortcuts>

#'
#' @examplesIf drive_has_token()
#' # Create a file to make a shortcut to
#' file <- drive_upload(
#'   drive_example("chicken.csv"),
#'   name = "chicken-sheet-for-shortcut",
#'   type = "spreadsheet"
#' )
#'
#' # Create a shortcut in the default location with the default name
#' sc1 <- shortcut_create(file)
#' # This shortcut could now be moved, renamed, etc., which is probably a good
#' # idea, since it's confusing to have a file and same-named shortcut
#' # in the same place!
#'
#' # Create a shortcut in the default location with a custom name
#' sc2 <- file %>%
#'   shortcut_create(name = "chicken-sheet-second-shortcut")
#'
#' # Create a folder, then put a shortcut there, with default name
#' folder <- drive_mkdir("chicken-sheet-shortcut-folder")
#' sc3 = file %>%
#'   shortcut_create(folder)
#'
#' # Look at all these shortcuts
#' (dat <- drive_find("chicken-sheet", type = "shortcut"))
#'
#' # Get the id of the original file from the shortcuts
#' dat <- dat %>%
#'   drive_reveal("shortcut_details")
#' purrr::map_chr(dat$shortcut_details, "targetId")
#' as_id(file)
#'
#' # Clean up
#' drive_rm(sc1, sc2, sc3, file, folder)
shortcut_create <- function(file,
                            path = NULL,
                            name = NULL,
                            overwrite = NA) {
  target <- as_dribble(file)
  target <- confirm_single_file(target)

  if (is.null(name) && (isTRUE(overwrite) || isFALSE(overwrite))) {
    # TODO: I'm phoning this message in, since I know I will merge the
    # abort+cli stuff soon
    stop_glue(
      "You must specify the shortcut's `name` in order to specify `overwrite` behaviour."
    )
  }

  drive_create(
    name = name,
    path = path,
    type = "shortcut",
    shortcutDetails = list(targetId = target$id),
    overwrite = overwrite
  )
}
