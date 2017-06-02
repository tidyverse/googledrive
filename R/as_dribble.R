#' Coerce lists and character strings into Drive Files, dribbles.
#'
#' This is an S3 generic. dribble includes methods for
#' data frames and tibbles (adds `dribble` class), dribbles (returns
#' unchanged input), drive_ids, lists, and character vectors.
#' @param x A list.
#' @param ... Other arguments to pass on to individual methods.
#' @export
as_dribble <- function(x, ...) UseMethod("as_dribble")

#' @export
#' @rdname as_dribble
as_dribble.data.frame <- function(x, ...) {
  x <- check_dribble(x)
  structure(x, class = c("dribble", "tbl_df", "tbl", "data.frame"))
}

#' @export
#' @rdname as_dribble
as_dribble.dribble <- function(x, ...) x

#' @export
#' @rdname as_dribble
as_dribble.character <- function(x, ...) {
  structure(
    drive_path(x),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

#' @export
#' @rdname as_dribble
as_dribble.drive_id <- function(x, ...) {
  structure(
    drive_get(x),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
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
