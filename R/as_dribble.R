#' Identify files on Google Drive
#'
#' @description Converts various representations of Google Drive files into a
#'   [`dribble`], the object used by googledrive to hold Drive file metadata.
#'   Files can be specified via
#'   * File path. File name is an important special case.
#'   * File id. Mark with [as_id()] to distinguish from file path.
#'   * Data frame or [`dribble`]. Once you've successfully used googledrive to
#'     identify the files of interest, you'll have a [`dribble`]. Pass it into
#'     downstream functions.
#'   * List representing [Files resource](https://developers.google.com/drive/v3/reference/files#resource)
#'     objects. Mostly for internal use.
#'
#' @description This is a generic function.
#'
#' For maximum clarity, get your files into a [`dribble`] (or capture file id)
#' as early as possible. When specifying via path, it's best to include the
#' trailing slash when you're targetting a folder. If you want the folder `foo`,
#' say `foo/`, not `foo`.
#'
#' Some functions, such as [drive_cp()], [drive_mkdir()], [drive_mv()], and
#' [drive_upload()], can accept the new file or folder name as the last part of
#' `path`, when `name` is not given. But if you say `a/b/c` (no trailing slash)
#' and a folder `a/b/c/` already exists, it's unclear what you want. A file
#' named `c` in `a/b/` or a file with default name in `a/b/c/`? You get an
#' error and must make your intent clear.
#'
#' @param x A vector of Drive file paths, a vector of file ids marked
#'   with [as_id()], a list of Files Resource objects, or a suitable data
#'   frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @export
#' @examples
#' \dontrun{
#' ## specify the path
#' as_dribble("abc")
#' as_dribble("abc/def")
#'
#' ## specify the file id (substitute one of your own!)
#' as_dribble(as_id("0B0Gh-SuuA2nTOGZVTXZTREgwZ2M"))
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
as_dribble.character <- function(x, ...) drive_get(path = x)

#' @export
#' @rdname as_dribble
as_dribble.drive_id <- function(x, ...) drive_get(id = x)

#' @export
#' @rdname as_dribble
as_dribble.data.frame <- function(x, ...) validate_dribble(new_dribble(x))

#' @export
#' @rdname as_dribble
as_dribble.list <- function(x, ...) {
  if (length(x) == 0) return(dribble())

  required_nms <- c("name", "id", "kind")
  stopifnot(purrr::map_lgl(x, ~ all(required_nms %in% names(.x))))

  as_dribble(
    tibble::tibble(
      name = purrr::map_chr(x, "name"),
      id = purrr::map_chr(x, "id"),
      files_resource = x
    )
  )
}
