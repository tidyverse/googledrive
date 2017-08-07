#' Access a Team Drive
#'
#' @description The Drive API requires extra information in order to look for
#'   files on a Team Drive. [drive_find()] and [drive_get()] accept this
#'   information via `...` and should be used to capture Team Drives files in a
#'   [`dribble`], suitable for use in other googledrive functions.
#'
#' @template teamdrives-description
#'
#' @description If you want to search a specific Team Drive, provide its id
#' somewhere in the call, like so:
#' ```
#' drive_find(..., teamDriveId = "XXXXXXXXX")
#' ```
#'
#' To search other collections, pass the `corpora` parameter somewhere in the
#' call, like so:
#' ```
#' drive_find(..., corpora = "user,allTeamDrives")
#' ```
#'
#' Possible values of `corpora` and what they mean:
#'   * `"user"`: Queries files that the user has accessed, including both Team
#'    and non-Team Drive files.
#'   * `"teamDrive"`: Queries all items in one specific Team Drive.
#'   `teamDriveId` must be also specified in the request. In fact, googledrive
#'   infers the need to send `corpora = "teamDrive"` whenever `teamDriveId` is
#'   set.
#'   * `"user,allTeamDrives"`: Queries files that the user has accessed and all
#'   Team Drives in which they are a member. Note that both `"user"` and
#'   `"teamDrive"` are preferable to `"allTeamDrives"`, in terms of efficiency.
#'   * `"domain"`: Queries files that are shared to the domain, including both
#'   Team Drive and non-Team Drive files.
#'
#' @details Team Drive support:
#' googledrive implements Team Drive support as outlined here:
#'   * <https://developers.google.com/drive/v3/web/enable-teamdrives#including_team_drive_content_fileslist>
#'
#' Users shouldn't need to know any of this, but here are details for the
#' curious. The extra information needed to search Team Drives consists of:
#'   * `corpora`: Where to search? Described above.
#'   * `teamDriveId`: The id of a specific Team Drive. Only allowed -- and also
#'     absolutely required -- when `corpora = "teamDrive"`. When user passes a
#'     `teamDriveId`, googledrive sends it and also infers that `corpora` should
#'     be set to `"teamDrive"` and sent.
#'   * `includeTeamDriveItems`: Do you want to see Team Drive items? Obviously,
#'     this should be `TRUE` and googledrive sends this whenever Team Drive
#'     parameters are detected
#'   * `supportsTeamDrives`: Does the sending application (googledrive, in this
#'     case) know about Team Drives? Obviously, this should be `TRUE` and
#'     googledrive sends it for all applicable endpoints, all the time.
#' @seealso [drive_find()]
#' @name teamdrives
NULL

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
