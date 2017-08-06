#' Search for Team Drive content
#'
#' @description The Drive API requires extra information if you want to search
#'   for files within a specific Team Drive or across all Team Drives. This
#'   matters for more functions than you might think, since many googledrive
#'   calls do some file searching behind the scenes, for example, whenever there
#'   is a need to resolve a file id based on a file's name or path.
#'
#' The extra information consists of:
#'   * `corpora`: Where to search?
#'   * `teamDriveId`: The id of a specific Team Drive. Only relevant if
#'     `corpora = "teamDrive"`.
#'
#' Possible values of `corpora` and what they mean:
#'   * `"user"`: Queries files that the user has accessed, including both Team
#'    and non-Team Drive files.
#'   * `"teamDrive"`: Queries all items in one specific Team Drive.
#'   `teamDriveId` must be also specified in the request.
#'   * `"user,allTeamDrives"`: Queries files that the user has accessed and all
#'   Team Drives in which they are a member. Prefer `"user"` or `"teamDrive"`
#'   to ` "allTeamDrives"` for efficiency.
#'   * `"domain"`: Queries files that are shared to the domain, including both
#'   Team Drive and non-Team Drive files.
#' @description googledrive adds `includeTeamDriveItems = TRUE` to the query
#'    whenever `corpora` is specified. The user does not need to specify this
#'    and indeed should not.

#' @seealso Implements Team Drive access as described here:
#'   * <https://developers.google.com/drive/v3/web/enable-teamdrives#including_team_drive_content_fileslist>
#'

#' @param corpora Character. One of `"user"`, `"teamDrive"`,
#'   `"user,allTeamDrives"`, or `"domain"`
#' @param teamDriveId Character. Supply a Team Drive id here if and only if
#'   `corpora = "teamDrive"`.
#' @param includeTeamDriveItems Logical. Should always be `TRUE` when addressing
#'   Team Drives and, indeed, googledrive will make it so before calling the
#'   API.
#'
#' @return A list with class `drive_corpus`.
#' @export
#'
#' @examples
#' drive_corpus("user")
drive_corpus <- function(corpora = NULL,
                         teamDriveId = NULL,
                         includeTeamDriveItems = NULL) {
  rationalize_corpus(new_corpus(corpora, teamDriveId, includeTeamDriveItems))
}

new_corpus <- function(corpora = NULL,
                       teamDriveId = NULL,
                       includeTeamDriveItems = NULL) {

  if (!is.null(corpora)) {
    stopifnot(is_string(corpora))
  }
  if (!is.null(teamDriveId)) {
    stopifnot(is.character(teamDriveId), length(teamDriveId) == 1)
  }
  if (!is.null(includeTeamDriveItems)) {
    stopifnot(
      is.logical(includeTeamDriveItems),
      length(includeTeamDriveItems) == 1
    )
  }
  structure(
    list(
      corpora = corpora,
      teamDriveId = teamDriveId,
      includeTeamDriveItems = includeTeamDriveItems
    ),
    class = "drive_corpus"
  )
}

## this isn't a pure validator, because it fills in some gaps
## there is, however, no magic
## there is user input that is unambiguous but still won't satisfy the API
##   1. if `teamDriveId` is provided and `corpora` is not, we fill in
##      `corpora = "teamDrive"`
##   2. we always send `includeTeamDriveItems = TRUE`
rationalize_corpus <- function(corpus) {
  if (!is.null(corpus[["teamDriveId"]])) {
    corpus[["corpora"]] <- corpus[["corpora"]] %||% "teamDrive"
  }

  validate_corpora(corpus[["corpora"]])

  if (corpus[["corpora"]] == "teamDrive" && is.null(corpus[["teamDriveId"]])) {
    stop_glue("When `corpora = \"teamDrive\"`, a `teamDriveId` is required.")
  }

  if (corpus[["corpora"]] != "teamDrive" && !is.null(corpus[["teamDriveId"]])) {
    stop_glue("When `corpora != \"teamDrive\"`, don't provide a `teamDriveId`.")
  }

  if (!isTRUE(corpus[["includeTeamDriveItems"]])) {
    corpus[["includeTeamDriveItems"]] <- TRUE
  }

  corpus
}

valid_corpora <- c("user", "teamDrive", "user,allTeamDrives", "domain")

validate_corpora <- function(corpora) {
  if (!corpora %in% valid_corpora) {
    stop_collapse(c(
      "Invalid value for `corpora`:",
      glue("  * {corpora}"),
      "These are the only valid values:",
      glue("  * {valid_corpora}")
    ))
  }
  invisible()
}
