#' Deprecated Team Drive functions
#'
#' @description
#' `r lifecycle::badge('deprecated')`
#' @template team-drives-description
#'
#' @inheritParams shared_drive_find
#' @inheritParams shared_drive_get
#' @inheritParams as_shared_drive
#' @inheritParams is_shared_drive
#' @template team_drive-plural
#'
#' @eval return_dribble("shared drive")
#'
#' @keywords internal
#' @name deprecated-team-drive-functions
NULL

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_find <- function(pattern = NULL,
                            n_max = Inf,
                            ...,
                            verbose = deprecated()) {
  warn_for_verbose(verbose)
  lifecycle::deprecate_warn("2.0.0", "team_drive_find()", "shared_drive_find()")
  shared_drive_find(pattern = pattern, n_max = n_max, ...)
}

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_get <- function(name = NULL, id = NULL, verbose = deprecated()) {
  warn_for_verbose(verbose)
  lifecycle::deprecate_warn("2.0.0", "team_drive_get()", "shared_drive_get()")
  shared_drive_get(name = name, id = id)
}

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_create <- function(name, verbose = deprecated()) {
  warn_for_verbose(verbose)
  lifecycle::deprecate_warn("2.0.0", "team_drive_create()", "shared_drive_create()")
  shared_drive_create(name = name)
}

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_rm <- function(team_drive = NULL, verbose = deprecated()) {
  warn_for_verbose(verbose)
  lifecycle::deprecate_warn("2.0.0", "team_drive_rm()", "shared_drive_rm()")
  shared_drive_rm(drive = team_drive)
}

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_update <- function(team_drive, ..., verbose = deprecated()) {
  warn_for_verbose(verbose)
  lifecycle::deprecate_warn("2.0.0", "team_drive_update()", "shared_drive_update()")
  shared_drive_update(drive = team_drive, ...)
}

#' @export
#' @rdname deprecated-team-drive-functions
 as_team_drive <- function(x, ...) {
  lifecycle::deprecate_warn("2.0.0", "as_team_drive()", "as_shared_drive()")
  as_shared_drive(x, ...)
 }

#' @export
#' @rdname deprecated-team-drive-functions
is_team_drive <- function(d) {
  stopifnot(inherits(d, "dribble"))
  map_chr(d$drive_resource, "kind") == "drive#teamDrive"
}
