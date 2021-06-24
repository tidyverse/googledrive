#' Extract and/or mark as file id
#'
#' @description Gets file ids from various inputs and marks them as such, to
#'   distinguish them from file names or paths.
#'
#' @description This is a generic function.
#'
#' @param x A character vector of file or shared drive ids or URLs, a
#'   [`dribble`], or a suitable data frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @return A character vector bearing the S3 class `drive_id`.
#' @export
#' @examplesIf drive_has_token()
#' as_id("123abc")
#' as_id("https://docs.google.com/spreadsheets/d/qawsedrf16273849/edit#gid=12345")
#'
#' x <- drive_find(n_max = 3)
#' as_id(x)
as_id <- function(x, ...) UseMethod("as_id")

#' @export
as_id.default <- function(x, ...) {
  drive_abort("
    Don't know how to coerce an object of class {.cls {class(x)}} into \\
    a {.cls drive_id}.")
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
  structure(map_chr(x, get_one_id), class = "drive_id")
}

## we anticipate file-id-containing URLs in these forms:
##       /d/FILE_ID   Drive file
## /folders/FILE_ID   Drive folder
##       id=FILE_ID   uploaded blob
id_regexp <- "(/d/|/folders/|id=)[^/]+"

is_drive_url <- function(x) grepl("^http", x) & grepl(id_regexp, x)

get_one_id <- function(x) {
  if (!grepl("^http|/", x)) return(x)

  id_loc <- regexpr(id_regexp, x)
  if (id_loc == -1) {
    NA_character_
  } else {
    gsub("/d/|/folders/|id=", "", regmatches(x, id_loc))
  }
}
