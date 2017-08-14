#' Update an existing Team Drive
#'
#' Update the metadata of an existing Team Drive, e.g. its background image or
#' theme.
#' @template team-drives-description
#'
#' @seealso Wraps the `teamdrives.update` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/teamdrives/update>
#'
#' @template team_drive-singular
#' @param ... Named parameters to pass along to the Drive API. See the "Request
#'   body" section of the Drive API docs for the associated endpoint.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## create a Team Drive
#' td <- team_drive_create("I love themes!")
#'
#' ## see the themes available to you
#' themes <- drive_user(fields = "teamDriveThemes")$teamDriveThemes
#' purrr::map_chr(themes, "id")
#'
#' ## cycle through various themes for this Team Drive
#' td <- team_drive_update(td, themeId = "bok_choy")
#' td <- team_drive_update(td, themeId = "cocktails")
#'
#' ## clean up
#' team_drive_rm(td)
#' }
team_drive_update <- function(team_drive, ..., verbose = TRUE) {
  team_drive <- as_team_drive(team_drive)
  if (no_file(team_drive) && verbose) {
    message("No such Team Drives found to update.")
    return(invisible(dribble()))
  }
  if (!single_file(team_drive)) {
    drives <- glue_data(team_drive, "  * {name}: {id}")
    stop_collapse(c("Can't update multiple Team Drives at once:", team_drive))
  }

  meta <- toCamel(list(...))
  if (length(meta) == 0) {
    if (verbose) message("No updates specified.")
    return(invisible(team_drive))
  }

  meta$fields <- meta$fields %||% "*"
  request <- generate_request(
    endpoint = "drive.teamdrives.update",
    params = c(
      teamDriveId = as_id(team_drive),
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
