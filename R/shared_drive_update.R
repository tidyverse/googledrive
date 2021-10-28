#' Update a shared drive
#'
#' Update the metadata of an existing shared drive, e.g. its background image or
#' theme.
#' @template shared-drive-description
#'
#' @seealso Wraps the `drives.update` endpoint:
#'   * <https://developers.google.com/drive/api/v3/reference/drives/update>
#'
#' @template shared_drive-singular
#' @param ... Properties to set in `name = value` form. See the "Request
#'   body" section of the Drive API docs for this endpoint.
#'
#' @eval return_dribble("shared drive")
#' @export
#' @examples
#' \dontrun{
#' # create a shared drive
#' sd <- shared_drive_create("I love themes!")
#'
#' # see the themes available to you
#' themes <- drive_about()$driveThemes
#' purrr::map_chr(themes, "id")
#'
#' # cycle through various themes for this shared drive
#' sd <- shared_drive_update(sd, themeId = "bok_choy")
#' sd <- shared_drive_update(sd, themeId = "cocktails")
#'
#' # Clean up
#' shared_drive_rm(sd)
#' }
shared_drive_update <- function(shared_drive, ...) {
  shared_drive <- as_shared_drive(shared_drive)
  if (no_file(shared_drive)) {
    drive_bullets(c(
      "!" = "No such shared drive found to update."
    ))
    return(invisible(dribble()))
  }
  if (!single_file(shared_drive)) {
    drive_abort(c(
      "Can't update multiple shared drives at once:",
      bulletize(gargle_map_cli(shared_drive))
    ))
  }

  meta <- toCamel(list2(...))
  if (length(meta) == 0) {
    drive_bullets(c(
      "!" = "No updates specified."
    ))
    return(invisible(shared_drive))
  }

  meta$fields <- meta$fields %||% "*"
  request <- request_generate(
    endpoint = "drive.drives.update",
    params = c(
      driveId = as_id(shared_drive),
      meta
    )
  )
  response <- request_make(request)
  out <- as_dribble(list(gargle::response_process(response)))

  drive_bullets(c("Shared drive updated:", bulletize(gargle_map_cli(out))))

  invisible(out)
}
