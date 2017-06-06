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

#' Check facts about a dribble
#'
#' Sometimes you need to check things about a dribble or about the files it
#' represents, such as:
#'   * Size: Does the dribble hold exactly one file? At least one file? No file?
#'   * File type: Is this file a folder?
#'   * File ownership and access: Is it mine? Published? Shared?
#'
#' @name dribble-checks
#' @param d A [`dribble`].
#' @examples
#' \dontrun{
#' ## most of us have multiple files or folders on Google Drive
#' d <- drive_search()
#' no_file(d)
#' single_file(d)
#' some_files(d)
#' confirm_single_file(d)
#' confirm_some_files(d)
#' is_folder(d)
#' is_mine(d)
#' }
NULL

#' @export
#' @rdname dribble-checks
no_file <- function(d) {
  stopifnot(inherits(d, "dribble"))
  nrow(d) == 0
}

#' @export
#' @rdname dribble-checks
single_file <- function(d) {
  stopifnot(inherits(d, "dribble"))
  nrow(d) == 1
}

#' @export
#' @rdname dribble-checks
some_files <- function(d) {
  stopifnot(inherits(d, "dribble"))
  nrow(d) > 0
}

#' @export
#' @rdname dribble-checks
confirm_single_file <- function(d) {
  if (!single_file(d)) {
    stop("Input does not hold exactly one Drive file:\n", deparse(substitute(d)),
         call. = FALSE)
  }
  d
}

#' @export
#' @rdname dribble-checks
confirm_some_files <- function(d) {
  if (!some_files(d)) {
    stop("Input does not hold at least one Drive file:\n", deparse(substitute(d)),
         call. = FALSE)
  }
  d
}

#' @export
#' @rdname dribble-checks
is_folder <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_chr(d$files_resource, "mimeType") ==
    "application/vnd.google-apps.folder"
}

#' @export
#' @rdname dribble-checks
is_mine <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_lgl(d$files_resource, list("owners", 1, "me"))
}


## promote elements in files_resource into a top-level variable
promote <- function(d, elem) {

  present <- any(purrr::map_lgl(d$files_resource, ~ elem %in% names(.x)))

  ## TO DO: do we really want promote() to be this forgiving?
  ## add a placeholder column for elem
  if (!present) {
    ## ensure elem is added, even if there are zero rows
    d[[elem]] <- rep_len(list(NULL), nrow(d))
    return(d)
  }

  mp <- list(
    character = purrr::map_chr,
    numeric = purrr::map_dbl,
    list = purrr::map,
    logical = purrr::map_lgl
  )
  ## TO DO: should be using .default in the above fxns
  cl <- class(d$files_resource[[1]][[elem]])

  fn <- mp[[cl]]
  d[[elem]] <- fn(d$files_resource, elem)
  d
}
