#' Coerce to Team Drive
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
#' @template team-drives-description
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
#' as_team_drive("abc")
#'
#' ## specify the id (substitute one of your own!)
#' as_team_drive(as_id("0AOPK1X2jaNckUk9PVA"))
#' }
as_team_drive <- function(x, ...) UseMethod("as_team_drive")

#' @export
as_team_drive.default <- function(x, ...) {
  stop_glue_data(
    list(x = collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {x} into a Team Drive dribble."
  )
}

#' @export
as_team_drive.NULL <- function(x, ...) dribble()

#' @export
as_team_drive.character <- function(x, ...) team_drive_get(name = x)

#' @export
as_team_drive.drive_id <- function(x, ...) team_drive_get(id = x)

#' @export
as_team_drive.dribble <- function(x, ...) validate_team_drive_dribble(x)

#' @export
as_team_drive.data.frame <- function(x, ...) {
  validate_team_drive_dribble(as_dribble(x))
}

#' @export
as_team_drive.list <- function(x, ...) {
  validate_team_drive_dribble(as_dribble(x))
}

validate_team_drive_dribble <- function(x) {
  stopifnot(inherits(x, "dribble"))
  if (!all(is_team_drive(x))) {
    stop_glue("All rows of Team Drive dribble must contain a Team Drive.")
  }
  x
}
