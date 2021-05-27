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

#' @eval param_path_known_parent("shortcut")
#' @eval param_name(
#'   thing = "shortcut",
#'   default_notes = "By default, the shortcut starts out with the same name as
#'     the target `file`. As a consequence, if you want to use
#'     `overwrite = TRUE` or `overwrite = FALSE`, you **must** explicitly
#'     specify the shortcut's `name`."
#' )

#' @template overwrite
#' @eval return_dribble()
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
    drive_abort("
      You must specify the shortcut's {.arg name} in order to specify \\
      {.arg overwrite} behaviour.")
  }

  drive_create(
    name = name,
    path = path,
    type = "shortcut",
    shortcutDetails = list(targetId = target$id),
    overwrite = overwrite
  )
}

#' Resolve shortcuts to their targets
#'
#' Retrieves the metadata for the Drive file that a shortcut refers to, i.e. the
#' shortcut's target. The returned [`dribble`] has the usual columns (`name`,
#' `id`, `drive_resource`), which refer to the target. It will also include the
#' columns `name_shortcut` and `id_shortcut`, which refer to the original
#' shortcut. There are 3 possible scenarios:

#' 1. `file` is a shortcut and user can [drive_get()] the target. All is simple
#'    and well.
#' 1. `file` is a shortcut, but [drive_get()] fails for the target. This can
#'    happen if the user can see the shortcut, but does not have read access
#'    to the target. It can also happen if the target has been trashed or
#'    deleted. In such cases, all of the target's metadata, except for `id`,
#'    will be missing. Call `drive_get()` on a problematic `id` to see the
#'    specific error.
#' 1. `file` is not a shortcut. `name_shortcut` and `id_shortcut` will both be
#'    `NA`.
#'
#' @template file-plural
#'
#' @eval return_dribble(extras = "Extra columns `name_shortcut` and
#'   `id_shortcut` refer to the original shortcut.")
#' @export
#'
#' @examplesIf drive_has_token()
#' # Create a file to make a shortcut to
#' file <- drive_upload(
#'   drive_example("chicken.csv"),
#'   name = "chicken-sheet-for-shortcut",
#'   type = "spreadsheet"
#' )
#'
#' # Create a shortcut
#' sc1 <- file %>%
#'   shortcut_create(name = "shortcut-1")
#'
#' # Create a second shortcut by copying the first
#' sc1 <- sc1 %>%
#'   drive_cp(name = "shortcut-2")
#'
#' # Get the shortcuts
#' (sc_dat <- drive_find("-[12]$", type = "shortcut"))
#'
#' # Resolve them
#' (resolved <- shortcut_resolve(sc_dat))
#'
#' resolved$id
#' file$id
#'
#' # Delete the target file
#' drive_rm(file)
#'
#' # (Try to) resolve the shortcuts again
#' shortcut_resolve(sc_dat)
#' # No error, but resolution is unsuccessful due to non-existent target
#'
#' # Clean-up
#' drive_rm(sc_dat)
shortcut_resolve <- function(file) {
  file <- as_dribble(file)
  out <- purrr::pmap(file, resolve_one)
  out <- vec_rbind(!!!out)

  is_sc <- !is.na(out$name_shortcut)
  n_shortcuts <- sum(is_sc)
  n_resolved <- sum(is_sc & !is.na(out$name))

  if (n_shortcuts == 0) {
    drive_bullets(c(
      "i" = "No shortcuts found."
    ))
  } else {
    drive_bullets(c(
      i = if (n_shortcuts == n_resolved) {
        "Resolved {n_resolved} shortcut{?s} found in {nrow(out)} file{?s}:"
      } else {
        "Resolved {n_resolved} of {n_shortcuts} shortcut{?s} found \\
         in {nrow(out)} file{?s}:"
      },
      bulletize(map_cli(
        out[is_sc, ],
        template = c(
          id_shortcut_string = "<id:\u00a0<<id_shortcut>>>",
          id_string = "<id:\u00a0<<id>>>",
          out = "{.drivepath <<name_shortcut>>} \\
                 {cli::col_grey('<<id_shortcut_string>>')} \\
                 -> {.drivepath <<name>>} {cli::col_grey('<<id_string>>')}"
        )
      ))
    ))
  }

  out
}

# TODO: why does this have such an annoying signature? why not dribble in,
# dribble out?
resolve_one <- function(name, id, drive_resource, ...) {
  target_id <- pluck(drive_resource, "shortcutDetails", "targetId")
  if (is_null(target_id)) {
    return(
      list(drive_resource) %>%
        as_dribble() %>%
        put_column(nm = "id_shortcut", val = NA_character_, .after = "id") %>%
        put_column(nm = "name_shortcut", val = NA_character_, .after = "id")
    )
  }
  out <- tryCatch(
    drive_get(as_id(target_id)),
    gargle_error_request_failed = function(e) bad_target(target_id)
  )
  out %>%
    put_column(nm = "id_shortcut", val = id, .after = "id") %>%
    put_column(nm = "name_shortcut", val = name, .after = "id")
}

bad_target <- function(id) {
  as_dribble(list(
    list(
      name = NA_character_,
      id = id,
      kind = "drive#file"
    )
  ))
}
