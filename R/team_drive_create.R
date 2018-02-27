#' Create a new Team Drive
#'
#' @template team-drives-description
#'
#' @seealso Wraps the `teamdrives.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/teamdrives/create>
#'
#' @param name Character. Name of the new Team Drive. Must be non-empty and not
#'   entirely whitespace.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' team_drive_create("my-awesome-team-drive")
#'
#' ## clean up
#' team_drive_rm("my-awesome-team-drive")
#' }
team_drive_create <- function(name, verbose = TRUE) {
  stopifnot(is_string(name), isTRUE(nzchar(name)))
  request <- generate_request(
    "drive.teamdrives.create",
    params = list(
      requestId = uuid::UUIDgenerate(),
      name = name,
      fields = "*"
    )
  )
  response <- make_request(request, encode = "json")
  out <- as_dribble(list(process_response(response)))

  if (verbose) {
    message_glue("\nTeam Drive created:\n  * {out$name}: {out$id}")
  }
  invisible(out)
}
