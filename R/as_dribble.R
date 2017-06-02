#' Identify files on Google Drive.
#'
#' Converts various representations of Google Drive files into a [`dribble`],
#' the object used by googledrive to hold Drive file metadata. Files can be
#' specified via
#'   * File path
#'   * File id (be sure to mark with [drive_id()] to distinguish from file path!)
#'   * List representing a [Files resource](https://developers.google.com/drive/v3/reference/files#resource)
#'     object (for internal use)
#'   * Data frame or [`dribble`] (for internal use)
#'
#' This is a generic function.

#' @param x A vector of Drive file paths, a vector of file ids marked
#'   with [drive_id()], a list of Files Resource objects, or a suitable data
#'   frame.
#' @param ... Other arguments passed down to methods.
#' @export
#' @examples
#' \dontrun{
#' ## specify the path
#' as_dribble("abc")
#' as_dribble("abc/def")
#'
#' ## specify the file id (substitute one of your own!)
#' as_dribble(drive_id("0B0Gh-SuuA2nTOGZVTXZTREgwZ2M"))
#' }
as_dribble <- function(x, ...) UseMethod("as_dribble")

#' @export
#' @rdname as_dribble
as_dribble.dribble <- function(x, ...) x

#' @export
#' @rdname as_dribble
as_dribble.character <- function(x, ...) {
  ## TO DO: we should accept x with length > 1
  drive_path(x)
}

#' @export
#' @rdname as_dribble
as_dribble.drive_id <- function(x, ...) {
  ## TO DO: we should accept x with length > 1
  drive_get(x)
}

#' @export
#' @rdname as_dribble
as_dribble.list <- function(x, ...) {
  if (length(x) == 0) return(dribble())

  kind <- purrr::map_chr(x, "kind", .null = NA_character_)
  stopifnot(all(kind == "drive#file"))

  structure(
    tibble::tibble(
      name = purrr::map_chr(x, "name"),
      id = purrr::map_chr(x, "id"),
      files_resource = x
    ),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

#' @export
#' @rdname as_dribble
as_dribble.data.frame <- function(x, ...) {
  x <- check_dribble(x)
  structure(x, class = c("dribble", "tbl_df", "tbl", "data.frame"))
}

