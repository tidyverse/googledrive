#' Update an existing Team Drive
#'
#' Update the metadata of an existing Team Drive, e.g. its background image or
#' theme.
#' @template teamdrives-description
#'
#' @seealso Wraps the `teamdrives.update` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/teamdrives/update>
#'
#' @template teamdrive
#' @param ... Named parameters to pass along to the Drive API. See the "Request
#'   body" section of the Drive API docs for the associated endpoint.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## create a Team Drive
#' td <- teamdrive_create("I love themes!")
#'
#' ## see the themes available to you
#' themes <- drive_user(fields = "teamDriveThemes")$teamDriveThemes
#' purrr::map_chr(themes, "id")
#'
#' ## cycle through various themes for this Team Drive
#' td <- teamdrive_update(td, themeId = "bok_choy")
#' td <- teamdrive_update(td, themeId = "cocktails")
#'
#' ## clean up
#' teamdrive_rm(td)
#' }
teamdrive_update <- function(teamdrive, ..., verbose = TRUE) {
  teamdrive <- as_teamdrive_dribble(teamdrive)
  if (no_file(teamdrive) && verbose) {
    message("No such Team Drives found to update.")
    return(invisible(dribble()))
  }
  if (!single_file(teamdrive)) {
    drives <- glue_data(teamdrive, "  * {name}: {id}")
    stop_collapse(c("Can't update multiple Team Drives at once:", teamdrive))
  }

  meta <- list(...)
  if (length(meta) == 0) {
    if (verbose) message("No updates specified.")
    return(invisible(teamdrive))
  }

  meta$fields <- meta$fields %||% "*"
  request <- generate_request(
    endpoint = "drive.teamdrives.update",
    params = c(
      teamDriveId = teamdrive$id,
      meta
    )
  )
  response <- make_request(request, encode = "json")
  out <- as_dribble(list(process_response(response)))

  if (verbose) {
    message_glue("\nTeam Drive updated:\n  * {out$name}: {out$id}")
  }

  invisible(out)
}
