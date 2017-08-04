## only for internal use ... at least for now
## I need to be able to turn various inputs into a dribble
## where I know each row is a Team Drive
## however I don't want to subclass dribble
as_teamdrive_dribble <- function(x, ...) UseMethod("as_teamdrive_dribble")

as_teamdrive_dribble.default <- function(x, ...) {
  stop_glue_data(
    list(x = collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {x} into a teamdrive dribble"
  )
}

as_teamdrive_dribble.NULL <- function(x, ...) dribble()
as_teamdrive_dribble.character <- function(x, ...) teamdrive_get(name = x)
as_teamdrive_dribble.drive_id <- function(x, ...) teamdrive_get(id = x)
as_teamdrive_dribble.dribble <- function(x, ...) validate_teamdrive_dribble(x)
as_teamdrive_dribble.data.frame <- function(x, ...) {
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
