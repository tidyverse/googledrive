#' Deprecated Team Drive functions
#'
#' @description
#' `r lifecycle::badge('deprecated')`
#' @template team-drives-description
#'
#' @template pattern
#' @template n_max
#' @param ... Other parameters to pass along in the request, such as `pageSize`.
#' @template verbose
#'
#' @template dribble-return
#'
#' @keywords internal
#' @name deprecated-team-drive-functions
#'
#' @examples
#' \dontrun{
#' team_drive_find()
#' }
NULL

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_find <- function(pattern = NULL,
                            n_max = Inf,
                            ...,
                            verbose = TRUE) {
  lifecycle::deprecate_warn("2.0.0", "team_drive_find()", "shared_drive_find()")
  # TODO: add something about verbosity once I deprecate that
  shared_drive_find(
    pattern = pattern,
    n_max = n_max,
    ...
  )
}

#' @export
#' @rdname deprecated-team-drive-functions
team_drive_get <- function(name = NULL, id = NULL, verbose = TRUE) {
  lifecycle::deprecate_warn("2.0.0", "team_drive_get()", "shared_drive_get()")
  # TODO: add something about verbosity once I deprecate that
  shared_drive_get(name = name, id = id)
}
