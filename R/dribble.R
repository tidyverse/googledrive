#' dribble object
#'
#' @description googledrive stores the metadata for one or more Drive files as a
#'   `dribble`. It is a "Drive [tibble][tibble::tibble-package]" with one row
#'   per file and, at a minimum, these variables:
#'   * `name`: a character variable containing file names
#'   * `id`: a character variable of Drive file ids
#'   * `files_resource`: a list-column of
#'   [Files resource](https://developers.google.com/drive/v3/reference/files#resource)
#'   objects. Note there is no guarantee that all documented fields are always
#'   present. We do check if the `kind` field is present and equal to
#'   `drive#file`.
#'
#' @description In general, the dribble class will be retained even after
#'   subsetting, as long as the required variables are present and of the
#'   correct type.
#'
#' @export
#' @name dribble
#' @seealso [as_dribble()]
NULL

## implementing dribble as advised here:
## https://github.com/hadley/adv-r/blob/master/S3.Rmd

new_dribble <- function(x) {
  stopifnot(inherits(x, "data.frame"))
  structure(x, class = c("dribble", "tbl_df", "tbl", "data.frame"))
}

validate_dribble <- function(x) {
  stopifnot(inherits(x, "dribble"))

  if (!has_dribble_cols(x)) {
    missing_cols <- setdiff(dribble_cols, colnames(x))
    stop_collapse(
      c("Invalid dribble. These required column names are missing:",
        missing_cols)
    )
  }

  if (!has_dribble_coltypes(x)) {
    mistyped_cols <- dribble_cols[!dribble_coltypes_ok(x)]
    stop_collapse(
      c("Invalid dribble. These columns have the wrong type:",
        mistyped_cols)
    )
  }

  if (!has_files_resource(x)) {
    stop_glue(
      "Invalid dribble. Can't confirm `kind = \"drive#file\"` ",
      "for all elements of the nominal `files_resource` column"
    )
  }
  x
}

dribble <- function(x = NULL) {
  x <- x %||% tibble::tibble(
    name = character(),
    id = character(),
    files_resource = list()
  )
  validate_dribble(new_dribble(x))
}

#' @export
`[.dribble` <- function(x, i, j, drop = FALSE) {
  maybe_dribble(NextMethod())
}

maybe_dribble <- function(x) {
  if (is.data.frame(x) &&
      has_dribble_cols(x) &&
      has_dribble_coltypes(x) &&
      has_files_resource(x)) {
    new_dribble(x)
  } else {
    as_tibble(x)
  }
}

#' @export
#' @importFrom tibble as_tibble
as_tibble.dribble <- function(x) {
  as_tibble(
    structure(x, class = class(tibble::tibble())),
    validate = TRUE
  )
}

dribble_cols <- c("name", "id", "files_resource")

has_dribble_cols <- function(x) {
  all(dribble_cols %in% colnames(x))
}

dribble_coltypes_ok <- function(x) {
  c(name = is.character(x$name),
    id = is.character(x$id),
    files_resource = inherits(x$files_resource, "list"))
}

has_dribble_coltypes <- function(x) {
  all(dribble_coltypes_ok(x))
}

has_files_resource <- function(x) {
  kind <- purrr::map_chr(x$files_resource, "kind", .null = NA_character_)
  all(!is.na(kind) & kind == "drive#file")
}

#' Check facts about a dribble
#'
#' Sometimes you need to check things about a dribble or about the files it
#' represents, such as:
#'   * Is it even a dribble?
#'   * Size: Does the dribble hold exactly one file? At least one file? No file?
#'   * File type: Is this file a folder?
#'   * File ownership and access: Is it mine? Published? Shared?
#'
#' @name dribble-checks
#' @param d A [`dribble`].
#' @examples
#' \dontrun{
#' ## most of us have multiple files or folders on Google Drive
#' d <- drive_find()
#' is_dribble(d)
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
is_dribble <- function(d) {
  inherits(d, "dribble")
}

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
    stop(
      "Input does not hold exactly one Drive file:\n",
      deparse(substitute(d)),
      call. = FALSE
    )
  }
  d
}

#' @export
#' @rdname dribble-checks
confirm_some_files <- function(d) {
  if (!some_files(d)) {
    stop(
      "Input does not hold at least one Drive file:\n",
      deparse(substitute(d)),
      call. = FALSE
    )
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


## promote an element in files_resource into a top-level variable
## it will be the second column, presumably after `name``
promote <- function(d, elem) {
  present <- any(purrr::map_lgl(d$files_resource, ~ elem %in% names(.x)))
  if (present) {
    new <- purrr::simplify(purrr::map(d$files_resource, elem))
  } else {
    ## TO DO: do we really want promote() to be this forgiving?
    ## adds a placeholder column for elem if not present in files_resource
    ## ensure elem is added, even if there are zero rows
    new <- rep_len(list(NULL), nrow(d))
    ## TO DO: find a way to emulate .default behavior from type-specific
    ## mappers ... might need to create my own simplify()
    ## https://github.com/tidyverse/purrr/issues/336
    ## as this stands, you will get a list-column whenever there is at
    ## least one NULL
  }
  d <- tibble::add_column(d, new, .after = 1)
  names(d)[2] <- elem
  d
}
