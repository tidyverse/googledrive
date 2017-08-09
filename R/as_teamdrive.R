#' Identify Team Drives
#'
#' @description Converts various representations of Team Drive into a
#'   [`dribble`], the object used by googledrive to hold Drive file metadata.
#'   Team Drives can be specified via
#'   * Name.
#'   * Team Drive id. Mark with [as_id()] to distinguish from name.
#'   * Data frame or [`dribble`] consisting solely of Team Drives.
#'   * List representing [Team Drive resource](https://developers.google.com/drive/v3/reference/teamdrives#resource-representations)
#'     objects. Mostly for internal use.
#'
#' @template teamdrives-description
#'
#' @description This is a generic function.
#'
#' @param x A vector of Team Drive names, a vector of Team Drive ids marked
#'   with [as_id()], a list of Team Drive Resource objects, or a suitable data
#'   frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @export
#' @examples
#' \dontrun{
#' ## specify the name
#' as_teamdrive("abc")
#'
#' ## specify the id (substitute one of your own!)
#' as_teamdrive(as_id("0AOPK1X2jaNckUk9PVA"))
#' }
as_teamdrive <- function(x, ...) UseMethod("as_teamdrive")

as_teamdrive.default <- function(x, ...) {
  stop_glue_data(
    list(x = collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {x} into a teamdrive dribble"
  )
}

as_teamdrive.NULL <- function(x, ...) dribble()
as_teamdrive.character <- function(x, ...) teamdrive_get(name = x)
as_teamdrive.drive_id <- function(x, ...) teamdrive_get(id = x)
as_teamdrive.dribble <- function(x, ...) validate_teamdrive_dribble(x)
as_teamdrive.data.frame <- function(x, ...) {
  validate_teamdrive_dribble(as_dribble(x))
}
as_teamdrive.dribble.list <- function(x, ...) {
  validate_teamdrive_dribble(as_dribble(x))
}

validate_teamdrive_dribble <- function(x) {
  stopifnot(inherits(x, "dribble"))
  if (!all(is_teamdrive(x))) {
    stop_glue("All rows of Team Drive dribble must contain a Team Drive.")
  }
  x
}
