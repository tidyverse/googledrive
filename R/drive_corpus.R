#' Access Team Drive files
#'
#' @description The Drive API requires extra information in order to look for
#'   files on a Team Drive. [drive_find()] and [drive_get()] accept this extra
#'   information via `team_drive` and/or `corpora`. Regard these two functions
#'   as the official "port of entry" for Team Drive files and folders. Use them
#'   to capture your target(s) in a [`dribble`] to pass along to other
#'   googledrive functions. The general flexibility to refer to files by name,
#'   path, or id does not apply to Team Drive files. While it's always a good
#'   idea to get things into a [`dribble`] early, for files on a Team Drive,
#'   it's a requirement.
#'
#' `team_drive` and/or `corpora` are pre-processed by `drive_corpus()` to obtain
#' query parameters.
#'
#' @template teamdrives-description
#'
#' @description If you want to search one specific Team Drive, pass its name,
#' id, or [`dribble`] to `team_drive` somewhere in the call, like so:
#' ```
#' drive_find(..., team_drive = "i-am-a-teamdrive-name")
#' drive_find(..., team_drive = as_id("i-am-a-teamdrive-id"))
#' drive_find(..., team_drive = teamdrive_dribble)
#' ```
#' The value of `team_drive` is pre-processed with [as_teamdrive()].
#'
#' To search other collections, pass the `corpora` parameter somewhere in the
#' call, like so:
#' ```
#' drive_find(..., corpora = "user,allTeamDrives")
#' ```
#' Possible values of `corpora` and what they mean:
#'   * `"user"`: Queries files that the user has accessed, including both Team
#'    and non-Team Drive files.
#'   * `"user,allTeamDrives"`: Queries files that the user has accessed and all
#'   Team Drives in which they are a member. Note that both `"user"` and
#'   `"teamDrive"` are preferable to `"allTeamDrives"`, in terms of efficiency.
#'   * `"domain"`: Queries files that are shared to the domain, including both
#'   Team Drive and non-Team Drive files.
#'   * `"teamDrive"`: Queries all items in one specific Team Drive.
#'   `teamDriveId` must be also specified elsewhere in the request. The
#'   googledrive workflow in this case is to use the `team_drive` argument as
#'   described above and allow googledrive to infer the need to send
#'   `corpora = "teamDrive"`.
#'
#' @details Team Drive support:
#' googledrive implements Team Drive support as outlined here:
#'   * <https://developers.google.com/drive/v3/web/enable-teamdrives#including_team_drive_content_fileslist>
#'
#' Users shouldn't need to know any of this, but here are details for the
#' curious. The extra information needed to search Team Drives consists of:
#'   * `corpora`: Where to search? Described above.
#'   * `teamDriveId`: The id of a specific Team Drive. Only allowed -- and also
#'     absolutely required -- when `corpora = "teamDrive"`. When user specifies
#'     a Team Drive, googledrive sends its id and also infers that `corpora`
#'     should be set to `"teamDrive"` and sent.
#'   * `includeTeamDriveItems`: Do you want to see Team Drive items? Obviously,
#'     this should be `TRUE` and googledrive sends this whenever Team Drive
#'     parameters are detected
#'   * `supportsTeamDrives`: Does the sending application (googledrive, in this
#'     case) know about Team Drives? Obviously, this should be `TRUE` and
#'     googledrive sends it for all applicable endpoints, all the time.
#' @seealso [drive_find()]
#' @export
#' @param teamDriveId Character, a Team Drive id.
#' @template corpora
#' @param includeTeamDriveItems Logical, googledrive always sets this to `TRUE`.
#' @examples
#' drive_corpus(teamDriveId = "123456789")
#' drive_corpus(corpora = "user")
#' drive_corpus(corpora = "user,allTeamDrives")
#' drive_corpus(corpora = "domain")
#'
#' \dontrun{
#' ## this will error because `corpora = "teamDrive"` also requires the id
#' drive_corpus(corpora = "teamDrive")
#'
#' ## this will error because `corpora = "domain"` forbids inclusion of id
#' drive_corpus(corpora = "domain", teamDriveId = "123456789")
#' }
drive_corpus <- function(teamDriveId = NULL,
                         corpora = NULL,
                         includeTeamDriveItems = NULL) {
  rationalize_corpus(
    new_corpus(
      teamDriveId, corpora, includeTeamDriveItems
    )
  )
}

new_corpus <- function(teamDriveId = NULL,
                       corpora = NULL,
                       includeTeamDriveItems = NULL) {

  if (!is.null(teamDriveId)) {
    ## can't use is_string() because object of class drive_id IS acceptable
    stopifnot(is.character(teamDriveId), length(teamDriveId) == 1)
  }
  if (!is.null(corpora)) {
    stopifnot(is_string(corpora))
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
    class = "corpus"
  )
}

## this isn't a classic validator, because it fills in some gaps
## there is, however, no magic
## there is user input that is unambiguous but still won't satisfy the API
##   1. if `teamDriveId` is provided and `corpora` is not, we fill in
##      `corpora = "teamDrive"`
##   2. we always send `includeTeamDriveItems = TRUE`
rationalize_corpus <- function(corpus) {
  stopifnot(inherits(corpus, "corpus"))

  if (!is.null(corpus[["teamDriveId"]])) {
    corpus[["corpora"]] <- corpus[["corpora"]] %||% "teamDrive"
  }

  validate_corpora(corpus[["corpora"]])

  if (corpus[["corpora"]] == "teamDrive" && is.null(corpus[["teamDriveId"]])) {
    stop_glue("When `corpora = \"teamDrive\"`, `team_drive` cannot be NULL.")
  }

  if (corpus[["corpora"]] != "teamDrive" && !is.null(corpus[["teamDriveId"]])) {
    stop_glue("When `corpora != \"teamDrive\"`, don't specify a Team Drive.")
  }

  corpus[["includeTeamDriveItems"]] <- TRUE

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
  invisible(corpora)
}
