#' Extract and/or mark as file id
#'
#' @description Gets file ids from various inputs and marks them as such, to
#'   distinguish them from file names or paths.
#'
#' @description This is a generic function.
#'
#' @param x A character vector of file or Team Drive ids or URLs, a [`dribble`]
#'   or a suitable data frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @return A character vector bearing the S3 class `drive_id`.
#' @export
#' @examples
#' as_id("123abc")
#' as_id("https://docs.google.com/spreadsheets/d/qawsedrf16273849/edit#gid=12345")
#'
#' \dontrun{
#' x <- drive_find(n_max = 3)
#' as_id(x)
#'
#' x <- drive_get("foofy")
#' as_id(x)
#'
#' x <- team_drive_find("work-stuff")
#' as_id(x)
#' }
as_id <- function(x, ...) UseMethod("as_id")

#' @export
as_id.default <- function(x, ...) {
  stop_glue_data(
    list(x = glue_collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {x} into a drive_id"
  )
}

#' @export
as_id.NULL <- function(x, ...) NULL

#' @export
as_id.drive_id <- function(x, ...) x

#' @export
as_id.dribble <- function(x, ...) as_id(x$id)

#' @export
as_id.data.frame <- function(x, ...) as_id(validate_dribble(new_dribble(x)))

#' @export
as_id.character <- function(x, ...) {
  if (length(x) == 0L) return(x)
  structure(purrr::map_chr(x, one_id), class = "drive_id")
}

one_id <- function(x) {
  if (!grepl("^http|/", x)) return(x)

  ## We expect the links to have /d/ before the file id, have /folders/
  ## before a folder id, or have id= before an uploaded blob
  id_loc <- regexpr("/d/([^/])+|/folders/([^/])+|id=([^/])+", x)
  if (id_loc == -1) {
    NA_character_
  } else {
    gsub("/d/|/folders/|id=", "", regmatches(x, id_loc))
  }
}
