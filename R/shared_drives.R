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
#' ## specify the name
#' as_shared_drive("abc")
#'
#' ## specify the id (substitute one of your own!)
#' as_shared_drive(as_id("0AOPK1X2jaNckUk9PVA"))
#' }
as_shared_drive <- function(x, ...) UseMethod("as_shared_drive")

#' @export
as_shared_drive.default <- function(x, ...) {
  stop_glue_data(
    list(x = glue_collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {x} into a dribble of shared drive(s)"
  )
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
    stop_glue("All rows of shared drive dribble must contain a shared drive")
  }
  x
}
