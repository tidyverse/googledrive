#' dribble object
#'
#' googledrive stores the metadata for one or more Google Drive files as a
#' `dribble`. It is a [tibble][tibble::tibble-package] with one row per file
#' and, at a minimum, character variables containing file name and id and a
#' list-column of [Files resource](https://developers.google.com/drive/v3/reference/files#resource)
#' objects (possibly incomplete).
#'
#' @export
#' @name dribble
NULL

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



is_folder <- function(x) {
  stopifnot(inherits(x, "dribble"))
  purrr::map_chr(x$files_resource, "mimeType") ==
    "application/vnd.google-apps.folder"
}

is_mine <- function(x) {
  stopifnot(inherits(x, "dribble"))
  purrr::map_lgl(x$files_resource, list("owners", 1, "me"))
}

#' Confirm that dribble contains exactly one Drive file.
#'
#' This will return the input `dribble` if it contains exactly
#' one Drive file, and will error otherwise.
#' @template file
#' @param .what Character, description of intput for informative
#'   error message.
#'
#' @export
is_one <- function(file, .what = "file") {
  stopifnot(inherits(file, "dribble"))
  if (!(nrow(file) == 1)) {
    stop(glue::glue("Input must specify exactly 1 Drive {.what}."), call. = FALSE)
  }
  file
}

is_any <- function(x) {
  stopifnot(inherits(x, "dribble"))
  if (nrow(x) == 0L) {
    stop("There are no Drive files that match your input.", call. = FALSE)
  }
  x
}

## promote elements in files_resource into a top-level variable
promote <- function(x, pull) {

  present <- any(purrr::map_lgl(x$files_resource, ~ pull %in% names(.x)))

  ## TO DO: do we really want promote() to be this forgiving?
  ## add a placeholder column for pull
  if (!present) {
    ## ensure pull is added, even if there are zero rows
    x[[pull]] <- rep_len(list(NULL), nrow(x))
    return(x)
  }

  mp <- list(
    character = purrr::map_chr,
    numeric = purrr::map_dbl,
    list = purrr::map,
    logical = purrr::map_lgl
  )
  ## TO DO: should be using .default in the above fxns
  cl <- class(x$files_resource[[1]][[pull]])

  fn <- mp[[cl]]
  x[[pull]] <- fn(x$files_resource, pull)
  x
}

