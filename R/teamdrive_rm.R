#' Delete Team Drives
#'
#' @template teamdrives-description
#'
#' @seealso Wraps the `teamdrives.delete` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/teamdrives/delete>
#'
#' @template teamdrive
#' @template verbose
#'
#' @return Logical vector, indicating whether the delete succeeded.
#' @export
#' @examples
#' \dontrun{
#' ## Create Team Drives to remove in various ways
#' teamdrive_create("testdrive-01")
#' td02 <- teamdrive_create("testdrive-02")
#' teamdrive_create("testdrive-03")
#' td04 <- teamdrive_create("testdrive-04")
#'
#' ## remove by name
#' teamdrive_rm("testdrive-01")
#' ## remove by id
#' teamdrive_rm(as_id(td02$id))
#' ## remove by URL (or, rather, id found in URL)
#' teamdrive_rm(as_id("https://drive.google.com/drive/u/0/folders/Q5DqUk9PVA"))
#' ## remove by dribble
#' teamdrive_rm(td03)
#' }
teamdrive_rm <- function(teamdrive = NULL, verbose = TRUE) {
  teamdrive <- as_teamdrive(teamdrive)
  if (no_file(teamdrive) && verbose) {
    message("No such Team Drives found to delete.")
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(teamdrive$id, delete_one_teamdrive)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(teamdrive[out, ], "  * {name}: {id}")
      message_collapse(c("Team Drives deleted:", successes))
    }
    if (any(!out)) {
      failures <- glue_data(teamdrive[!out, ], "  * {name}: {id}")
      message_collapse(c("Team Drives NOT deleted:", failures))
    }
  }
  invisible(out)
}

delete_one_teamdrive <- function(id) {
  request <- generate_request(
    endpoint = "drive.teamdrives.delete",
    params = list(teamDriveId = id)
  )
  response <- make_request(request)
  process_response(response)
}
