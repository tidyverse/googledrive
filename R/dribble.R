dribble <- function() {
  structure(
    tibble::tibble(
      name = character(),
      id = character(),
      drive_file = list()
    ),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

drive_id <- function(x) {
  stopifnot(is.character(x))
  structure(x, class = "drive_id")
}

as.dribble <- function(x, ...) UseMethod("as.dribble")

as.dribble.dribble <- function(x, ...) x

as.dribble.character <- function(x, ...) {
  structure(
    drive_path(x),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

as.dribble.drive_id <- function(x, ...) {
  structure(
    drive_get(x),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

as.dribble.list <- function(x, ...) {
  if (length(x) == 0) return(dribble())

  kind <- purrr::map_chr(x, "kind", .null = NA_character_)
  stopifnot(all(kind == "drive#file"))

  structure(
    tibble::tibble(
      name = purrr::map_chr(x, "name"),
      id = purrr::map_chr(x, "id"),
      drive_file = x
    ),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}
