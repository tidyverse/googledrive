#' Delete Team Drives
#'
#' @template team-drives-description
#'
#' @seealso Wraps the `teamdrives.delete` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/teamdrives/delete>
#'
#' @template team_drive-plural
#' @template verbose
#'
#' @return Logical vector, indicating whether the delete succeeded.
#' @export
#' @examples
#' \dontrun{
#' ## Create Team Drives to remove in various ways
#' team_drive_create("testdrive-01")
#' td02 <- team_drive_create("testdrive-02")
#' team_drive_create("testdrive-03")
#' td04 <- team_drive_create("testdrive-04")
#'
#' ## remove by name
#' team_drive_rm("testdrive-01")
#' ## remove by id
#' team_drive_rm(as_id(td02))
#' ## remove by URL (or, rather, id found in URL)
#' team_drive_rm(as_id("https://drive.google.com/drive/u/0/folders/Q5DqUk9PVA"))
#' ## remove by dribble
#' team_drive_rm(td04)
#' }
team_drive_rm <- function(team_drive = NULL, verbose = TRUE) {
  team_drive <- as_team_drive(team_drive)
  if (no_file(team_drive) && verbose) {
    message("No such Team Drives found to delete.")
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(as_id(team_drive), delete_one_team_drive)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(team_drive[out, ], "  * {name}: {id}")
      message_collapse(c("Team Drives deleted:", successes))
    }
    if (any(!out)) {
      failures <- glue_data(team_drive[!out, ], "  * {name}: {id}")
      message_collapse(c("Team Drives NOT deleted:", failures))
    }
  }
  invisible(out)
}

delete_one_team_drive <- function(id) {
  request <- generate_request(
    endpoint = "drive.teamdrives.delete",
    params = list(teamDriveId = id)
  )
  response <- make_request(request)
  process_response(response)
}
