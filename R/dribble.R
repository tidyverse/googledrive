dribble <- function() {
  structure(
    tibble::tibble(
      name = character(),
      id = character(),
      files_resource = list()
    ),
    class = c("dribble", "tbl_df", "tbl", "data.frame")
  )
}

check_dribble <- function(x) {
  if (!all(c("name", "id", "files_resource") %in% colnames(x))) {
    stop("Invalid dribble. Must have `name`, `id`, and `file_resource` columns")
  }
  if (!all(inherits(x$name, "character") &&
           inherits(x$id, "character") &&
           inherits(x$files_resource, "list"))) {
    stop("Invalid dribble. Column types are misspecified.")
  }
  x
}


is_folder <- function(dribble) {
  if (inherits(dribble, "dribble") &&
      nrow(dribble) == 1 &&
      dribble$files_resource[[1]]$mimeType == "application/vnd.google-apps.folder") {
    TRUE
  } else FALSE
}

is_owner <- function(dribble) {
  if (inherits(dribble, "dribble") &&
      all(unlist(purrr::map(
        purrr::flatten(
          purrr::map(dribble$files_resource,"owners")
        ),"me")))) {
    TRUE
  } else FALSE
}

## this let's us pull things out of files_resource column that we'd like
## as a column in the main dribble
pull_into_dribble <- function(dribble, pull) {

  mp <- list(character = purrr::map_chr,
             numeric = purrr::map_dbl,
             list = purrr::map,
             logical = purrr::map_lgl
  )

  cl <- class(dribble$files_resource[[1]][[pull]])

  fn <- mp[[cl]]
  dribble[[pull]] <- fn(dribble$files_resource, pull)
  dribble
}

