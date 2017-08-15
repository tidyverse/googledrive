#' Access Team Drives
#'
#' @description How to capture a Team Drive or files/folders that live on a
#' Team Drive for downstream use:
#' * [drive_find()] and [drive_get()] return a [`dribble`] with metadata on
#' files, including folders. Both can be directed to search on Team Drives,
#' using the optional arguments `team_drive` or `corpus` (documented below).
#' * [team_drive_find()] and [team_drive_get()] return a [`dribble`] with
#' metadata on Team Drives themselves. You will need this in order to use a Team
#' Drive in certain file operations. For example, you can specify a Team Drive
#' as the parent folder via the `path` argument for upload, move, copy, etc.
#'
#' @description Regard the functions above as the official "port of entry" for
#'   Team Drives and Team Drive files and folders. Use them to capture your
#'   target(s) in a [`dribble`] to pass along to other googledrive functions.
#'   The general flexibility to refer to files by name, path, or id does not
#'   apply to Team Drive files. While it's always a good idea to get things into
#'   a [`dribble`] early, for Team Drives it's absolutely required.
#'
#' @template team-drives-description

#' @section Specific Team Drive:
#' To search one specific Team Drive, pass its name, marked id, or
#' [`dribble`] to `team_drive` somewhere in the call, like so:
#' ```
#' drive_find(..., team_drive = "i_am_a_team_drive_name")
#' drive_find(..., team_drive = as_id("i_am_a_team_drive_id"))
#' drive_find(..., team_drive = i_am_a_team_drive_dribble)
#' ```
#' The value of `team_drive` is pre-processed with [as_team_drive()].

#' @section Other collections:
#' To search other collections, pass the `corpus` parameter somewhere in the
#' call, like so:
#' ```
#' drive_find(..., corpus = "user")
#' drive_find(..., corpus = "all")
#' drive_find(..., corpus = "domain")
#' ```
#' Possible values of `corpus` and what they mean:
#' * `"user"`: Queries files that the user has accessed, including both Team and
#' non-Team Drive files.
#' * `"all"`: Queries files that the user has accessed and all Team Drives in
#' which they are a member. If you're reading the Drive API docs, this is a
#' googledrive convenience short cut for `"user,allTeamDrives"`.
#' * `"domain"`: Queries files that are shared to the domain, including both
#' Team Drive and non-Team Drive files.

#' @section API docs:
#' googledrive implements Team Drive support as outlined here:
#' * <https://developers.google.com/drive/v3/web/enable-teamdrives#including_team_drive_content_fileslist>
#'
#' Users shouldn't need to know any of this, but here are details for the
#' curious. The extra information needed to search Team Drives consists of the
#' following query parameters:
#' * `corpora`: Where to search? Formed from googledrive's `corpus` argument.
#' * `teamDriveId`: The id of a specific Team Drive. Only allowed -- and also
#' absolutely required -- when `corpora = "teamDrive"`. When user specifies a
#' Team Drive, googledrive sends its id and also infers that `corpora` should
#' be set to `"teamDrive"` and sent.
#' * `includeTeamDriveItems`: Do you want to see Team Drive items? Obviously,
#' this should be `TRUE` and googledrive sends this whenever Team Drive
#' parameters are detected
#' * `supportsTeamDrives`: Does the sending application (googledrive, in this
#' case) know about Team Drives? Obviously, this should be `TRUE` and
#' googledrive sends it for all applicable endpoints, all the time.
#'
#' @name team_drives
NULL

# Team Drive support
#
# Internal documentation! We refer to Team Drives everywhere as `team_drive`
# because the Drive API itself is inconsistent (teamdrive and teamDrive, both
# appear) and this seems the least of all evils. It is intentional that
# googledrive's two parameters `team_drive` and `corpus` have NO OVERLAP with
# actual Team Drive query parameters: this way the googledrive high-level
# wrapping is option A but user could also pass raw params through `...` as
# option B.
#
# @param teamDriveId Character, a Team Drive id.
# @template corpus
# @param includeTeamDriveItems Logical, googledrive always sets this to `TRUE`.
#
# @examples
# \dontrun{
# team_drive_params(teamDriveId = "123456789")
# team_drive_params(corpora = "user")
# team_drive_params(corpora = "user,allTeamDrives")
# team_drive_params(corpora = "domain")
#
# ## this will error because `corpora = "teamDrive"` also requires the id
# team_drive_params(corpora = "teamDrive")
#
# ## this will error because `corpora = "domain"` forbids inclusion of id
# team_drive_params(corpora = "domain", teamDriveId = "123456789")
# }
team_drive_params <- function(teamDriveId = NULL,
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
