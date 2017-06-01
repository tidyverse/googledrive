dribble <- function() {
  structure(
    tibble::tibble(
      name = character(),
      id = character(),
      file_resource = list()
    ),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

drive_id <- function(x) {
  stopifnot(is.character(x))
  structure(x, class = "drive_id")
}

as.dribble <- function(x, ...) UseMethod("as.dribble")

## TO DO: this is here because I don't have indexing,
## can probably get rid of after
as.dribble.tbl_df <- function(x, ...) {
  structure(x, class = c("dribble", "tbl_df", "tbl", "data.frame"))
}

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
      file_resource = x
    ),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

## this let's us pull things out of file_resource column that we'd like
## as a column in the main dribble
pull_into_dribble <- function(dribble, pull) {

  mp <- list(character = purrr::map_chr,
             numeric = purrr::map_dbl,
             list = purrr::map,
             logical = purrr::map_lgl
  )

  cl <- class(dribble$file_resource[[1]][[pull]])

  fn <- mp[[cl]]
  dribble[[pull]] <- fn(dribble$file_resource, pull)
  dribble
}

