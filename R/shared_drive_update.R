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
#' @template verbose
#'
#' @template dribble-return
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
#' ## cycle through various themes for this Team Drive
#' sd <- shared_drive_update(sd, themeId = "bok_choy")
#' sd <- shared_drive_update(sd, themeId = "cocktails")
#'
#' ## clean up
#' shared_drive_rm(sd)
#' }
shared_drive_update <- function(drive, ..., verbose = TRUE) {
  shared_drive <- as_shared_drive(drive)
  if (no_file(shared_drive) && verbose) {
    message("No such shared drive found to update.")
    return(invisible(dribble()))
  }
  if (!single_file(shared_drive)) {
    drives <- glue_data(shared_drive, "  * {name}: {id}")
    stop_collapse(c("Can't update multiple shared drives at once:", drives))
  }

  meta <- toCamel(rlang::list2(...))
  if (length(meta) == 0) {
    if (verbose) message("No updates specified.")
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
  response <- request_make(request, encode = "json")
  out <- as_dribble(list(gargle::response_process(response)))

  if (verbose) {
    message_glue("\nShared drive updated:\n  * {out$name}: {out$id}")
  }

  invisible(out)
}
