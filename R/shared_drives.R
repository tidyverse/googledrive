#' Access shared drives
#'
#' @description

#' A shared drive supports files owned by an organization rather than an
#' individual user. Shared drives follow different sharing and ownership models
#' from a specific user's "My Drive". Shared drives are the successors to the
#' earlier concept of Team Drives.



#' @description How to capture a shared drive or files/folders that live on a
#'   shared drive for downstream use:

#' * [shared_drive_find()] and [shared_drive_get()] return a [`dribble`] with
#' metadata on shared drives themselves. You will need this in order to use a
#' shared drive in certain file operations. For example, you can specify a
#' shared drive as the parent folder via the `path` argument for upload, move,
#' copy, etc. In that context, the id of a shared drive functions like the id of
#' its top-level or root folder.

#' * [drive_find()] and [drive_get()] return a [`dribble`] with metadata on
#' files, including folders. Both can be directed to search for files on shared
#' drives using the optional arguments `shared_drive` or `corpus` (documented
#' below).
#'

#' @description Regard the functions mentioned above as the official "port of
#'   entry" for working with shared drives. Use these functions to capture your
#'   target(s) in a [`dribble`] to pass along to other googledrive functions.
#'   The flexibility to refer to files by name or path does not apply as broadly
#'   to shared drives. While it's always a good idea to get things into a
#'   [`dribble`] early, for shared drives it's often required.
#'

#' @section Specific shared drive:
#' To search one specific shared drive, pass its name, marked id, or
#' [`dribble`] to `shared_drive` somewhere in the call, like so:
#' ```
#' drive_find(..., shared_drive = "i_am_a_shared_drive_name")
#' drive_find(..., shared_drive = as_id("i_am_a_shared_drive_id"))
#' drive_find(..., shared_drive = i_am_a_shared_drive_dribble)
#' ```
#' The value provided to `shared_drive` is pre-processed with
#' [as_shared_drive()].

#' @section Other collections:
#' To search other collections, pass the `corpus` parameter somewhere in the
#' call, like so:
#' ```
#' drive_find(..., corpus = "user")
#' drive_find(..., corpus = "allDrives")
#' drive_find(..., corpus = "domain")
#' ```
#' Possible values of `corpus` and what they mean:
#' * `"user"`: Queries files that the user has accessed, including both shared
#'   drive and My Drive files.
#' * `"drive"`: Queries all items in the shared drive specified via
#'   `shared_drive`. googledrive automatically fills this in whenever
#'   `shared_drive` is not `NULL`.
#' * `"allDrives"`: Queries files that the user has accessed and all shared
#'   drives in which they are a member. Note that the response may include
#'   `incompleteSearch : true`, indicating that some corpora were not searched
#'   for this request (currently, googledrive does not surface this). Prefer
#'   `"user"` or `"drive"` to `"allDrives"` for efficiency.
#' * `"domain"`: Queries files that are shared to the domain, including both
#'   shared drive and My Drive files.

#' @section Google blogs and docs:
#' Here is some of the best official Google reading about shared drives:
#' * [Team Drives is being renamed to shared drives](https://workspaceupdates.googleblog.com/2019/04/shared-drives.html) from Google Workspace blog
#' * [Upcoming changes to the Google Drive API and Google Picker API](https://cloud.google.com/blog/products/application-development/upcoming-changes-to-the-google-drive-api-and-google-picker-api) from the Google Cloud blog
#' * <https://developers.google.com/drive/api/v3/about-shareddrives>
#' * <https://developers.google.com/drive/api/v3/shared-drives-diffs>
#' * [Get started with shared drives](https://support.google.com/a/users/answer/9310351) from Google Workspace Learning Center
#' * [Best practices for shared drives](https://support.google.com/a/users/answer/9310156) from Google Workspace Learning Center


#' @section API docs:
#' googledrive implements shared drive support as outlined here:
#' * <https://developers.google.com/drive/api/v3/enable-shareddrives>
#'
#' Users shouldn't need to know any of this, but here are details for the
#' curious. The extra information needed to search shared drives consists of the
#' following query parameters:
#' * `corpora`: Where to search? Formed from googledrive's `corpus` argument.
#' * `driveId`: The id of a specific shared drive. Only allowed -- and also
#'   absolutely required -- when `corpora = "drive"`. When user specifies a
#'   `shared_drive`, googledrive sends its id and also infers that `corpora`
#'   should be set to `"drive"`.
#' * `includeItemsFromAllDrives`: Do you want to see shared drive items?
#'   Obviously, this should be `TRUE` and googledrive sends this whenever shared
#'   drive parameters are detected.
#' * `supportsAllDrives`: Does the sending application (googledrive, in this
#'   case) know about shared drive? Obviously, this should be `TRUE` and
#'   googledrive sends it for all applicable endpoints, all the time.
#'
#' @name shared_drives
NULL

# Shared drive and "file groupings" support
#
# Internal documentation!
#
# It is intentional that googledrive's two parameters `shared_drive` and
# `corpus` have NO OVERLAP with actual Drive query parameters: this way the
# googledrive high-level wrapping is option A but user could also pass raw
# params through `...` as option B.
#
# @param driveId Character, a shared drive id.
# @template corpus
# @param includeItemsFromAllDrives Logical, googledrive always sets this to
#   `TRUE`.
#
# @examples
# \dontrun{
# shared_drive_params(driveId = "123456789")
# shared_drive_params(corpora = "user")
# shared_drive_params(corpora = "allDrives")
# shared_drive_params(corpora = "domain")
#
# # this will error because `corpora = "drive"` also requires the id
# shared_drive_params(corpora = "drive")
#
# # this will error because `corpora = "domain"` forbids inclusion of id
# shared_drive_params(corpora = "domain", driveId = "123456789")
# }
shared_drive_params <- function(driveId = NULL,
                                corpora = NULL,
                                includeItemsFromAllDrives = NULL) {
  rationalize_corpus(
    new_corpus(
      driveId, corpora, includeItemsFromAllDrives
    )
  )
}

new_corpus <- function(driveId = NULL,
                       corpora = NULL,
                       includeItemsFromAllDrives = NULL) {
  if (!is.null(driveId)) {
    # can't use is_string() because object of class drive_id IS acceptable
    stopifnot(is.character(driveId), length(driveId) == 1)
  }
  if (!is.null(corpora)) {
    stopifnot(is_string(corpora))
  }
  if (!is.null(includeItemsFromAllDrives)) {
    stopifnot(
      is.logical(includeItemsFromAllDrives),
      length(includeItemsFromAllDrives) == 1
    )
  }
  structure(
    list(
      corpora = corpora,
      driveId = driveId,
      includeItemsFromAllDrives = includeItemsFromAllDrives
    ),
    class = "corpus"
  )
}

# this isn't a classic validator, because it fills in some gaps
# there is, however, no magic
# there is user input that is unambiguous but still won't satisfy the API
#   1. if `driveId` is provided and `corpora` is not, we fill in
#      `corpora = "drive"`
#   2. we always send `includeItemsFromAllDrives = TRUE`
rationalize_corpus <- function(corpus) {
  stopifnot(inherits(corpus, "corpus"))

  if (!is.null(corpus[["driveId"]])) {
    corpus[["corpora"]] <- corpus[["corpora"]] %||% "drive"
  }

  validate_corpora(corpus[["corpora"]])

  if (corpus[["corpora"]] == "drive" && is.null(corpus[["driveId"]])) {
    drive_abort('
      When {.code corpus = "drive"}, you must also specify \\
      the {.arg shared_drive}.')
  }

  if (corpus[["corpora"]] != "drive" && !is.null(corpus[["driveId"]])) {
    drive_abort('
      When {.code corpus != "drive"}, you must not specify \\
      a {.arg shared_drive}.')
  }

  corpus[["includeItemsFromAllDrives"]] <- TRUE

  corpus
}

valid_corpora <- c("user", "drive", "allDrives", "domain")

validate_corpora <- function(corpora) {
  if (!corpora %in% valid_corpora) {
    # yes, I intentionally use `corpus` in this message, even
    # though the actual API parameter is `corpora`
    # googledrive's user-facing functions have `corpus` in their signature and
    # the rationale is explained elsewhere in this file
    drive_abort(c(
      "Invalid value for {.arg corpus}:",
      bulletize(gargle_map_cli(corpora), bullet = "x"),
      "These are the only acceptable values:",
      bulletize(gargle_map_cli(valid_corpora))
    ))
  }
  invisible(corpora)
}

#' Coerce to shared drive
#'
#' @description Converts various representations of a shared drive into a
#'   [`dribble`], the object used by googledrive to hold Drive file metadata.
#'   Shared drives can be specified via
#'   * Name
#'   * Shared drive id, marked with [as_id()] to distinguish from name
#'   * Data frame or [`dribble`] consisting solely of shared drives
#'   * List representing [Drives resource](https://developers.google.com/drive/api/v3/reference/drives#resource-representations)
#'     objects (mostly for internal use)
#'
#' @template shared-drive-description
#'
#' @description This is a generic function.
#'
#' @param x A vector of shared drive names, a vector of shared drive ids marked
#'   with [as_id()], a list of Drives resource objects, or a suitable data
#'   frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @export
#' @examples
#' \dontrun{
#' # specify the name
#' as_shared_drive("abc")
#'
#' # specify the id (substitute one of your own!)
#' as_shared_drive(as_id("0AOPK1X2jaNckUk9PVA"))
#' }
as_shared_drive <- function(x, ...) UseMethod("as_shared_drive")

#' @export
as_shared_drive.default <- function(x, ...) {
  drive_abort("
    Don't know how to coerce an object of class {.cls {class(x)}} into \\
    a shared drive {.cls dribble}.")
}

#' @export
as_shared_drive.NULL <- function(x, ...) dribble()

#' @export
as_shared_drive.character <- function(x, ...) shared_drive_get(name = x)

#' @export
as_shared_drive.drive_id <- function(x, ...) shared_drive_get(id = x)

#' @export
as_shared_drive.dribble <- function(x, ...) validate_shared_drive_dribble(x)

#' @export
as_shared_drive.data.frame <- function(x, ...) {
  validate_shared_drive_dribble(as_dribble(x))
}

#' @export
as_shared_drive.list <- function(x, ...) {
  validate_shared_drive_dribble(as_dribble(x))
}

validate_shared_drive_dribble <- function(x) {
  stopifnot(inherits(x, "dribble"))
  if (!all(is_shared_drive(x))) {
    drive_abort("
      All rows of shared drive {.cls dribble} must contain a shared drive.")
  }
  x
}
