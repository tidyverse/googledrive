#' Identify files on Google Drive.
#'
#' Converts various representations of Google Drive files into a [`dribble`],
#' the object used by googledrive to hold Drive file metadata. Files can be
#' specified via
#'   * File path
#'   * File id (be sure to mark with [drive_id()] to distinguish from file path!)
#'   * List representing [Files resource](https://developers.google.com/drive/v3/reference/files#resource)
#'     objects (for internal use)
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
as_dribble.default <- function(x, ...) {
  stop(
    "Don't know how to coerce object of class ",
    paste(class(x), collapse = "/"), " into a dribble",
    call. = FALSE
  )
}

#' @export
#' @rdname as_dribble
as_dribble.NULL <- function(x, ...) dribble()

#' @export
#' @rdname as_dribble
as_dribble.character <- function(x, ...) drive_paths(x)

#' @export
#' @rdname as_dribble
as_dribble.drive_id <- function(x, ...) drive_get(x)

#' @export
#' @rdname as_dribble
as_dribble.list <- function(x, ...) {
  if (length(x) == 0) return(dribble())

  required_nms <- c("name", "id", "kind")
  stopifnot(purrr::map_lgl(x, ~ all(required_nms %in% names(.x))))

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
  required_nms <- c("name", "id", "files_resource")
  if (!all(required_nms %in% colnames(x))) {
    msg <- glue::glue("Invalid dribble. These column names are required:\n{x}",
                      x = glue::collapse(required_nms, "\n"))
    stop(msg, call. = FALSE)
  }

  if (!all(is.character(x$name) &&
           is.character(x$id) &&
           inherits(x$files_resource, "list"))) {
    stop("Invalid dribble. Column types are incorrect.", call. = FALSE)
  }

  kind <- purrr::map_chr(x$files_resource, "kind", .null = NA_character_)
  stopifnot(all(kind == "drive#file"))

  structure(x, class = c("dribble", "tbl_df", "tbl", "data.frame"))
}
