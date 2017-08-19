#' dribble object
#'
#' @description googledrive stores the metadata for one or more Drive files or
#'   Team Drives as a `dribble`. It is a "Drive
#'   [tibble][tibble::tibble-package]" with one row per file or Team Drive and,
#'   at a minimum, these variables:
#'   * `name`: a character variable containing file or Team Drive names
#'   * `id`: a character variable of file or Team Drive ids
#'   * `drive_resource`: a list-column, each element of which is either a
#'   [Files resource](https://developers.google.com/drive/v3/reference/files#resource-representations)
#'   or [Team Drive resource](https://developers.google.com/drive/v3/reference/teamdrives#resource-representations)
#'   object. Note there is no guarantee that all documented fields are always
#'   present. We do check if the `kind` field is present and equal to one of
#'   `drive#file` or `drive#teamDrive`.
#'
#' @description In general, the dribble class will be retained even after
#'   subsetting, as long as the required variables are present and of the
#'   correct type.
#'
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

  if (!has_drive_resource(x)) {
    stop_glue(
      "Invalid dribble. Can't confirm `kind = \"drive#file\"` or ",
      "`kind = \"drive#teamDrive\"` for all elements of the nominal ",
      "`drive_resource` column"
    )
  }
  x
}

dribble <- function(x = NULL) {
  x <- x %||% tibble::tibble(
    name = character(),
    id = character(),
    drive_resource = list()
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
      has_drive_resource(x)) {
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

dribble_cols <- c("name", "id", "drive_resource")

has_dribble_cols <- function(x) {
  all(dribble_cols %in% colnames(x))
}

dribble_coltypes_ok <- function(x) {
  c(name = is.character(x$name),
    id = is.character(x$id),
    drive_resource = inherits(x$drive_resource, "list"))
}

has_dribble_coltypes <- function(x) {
  all(dribble_coltypes_ok(x))
}

has_drive_resource <- function(x) {
  kind <- purrr::map_chr(x$drive_resource, "kind", .null = NA_character_)
  all(!is.na(kind) & kind %in% c("drive#file", "drive#teamDrive"))
}

## used across several functions that create a file or modify "parentage"
## processes a putative parent folder or Team Drive
as_parent <- function(d) {
  in_var <- deparse(substitute(d))
  d <- as_dribble(d)
  ## wording chosen to work for folder and Team Drive
  if (no_file(d)) {
    stop_glue("Parent specified via {sq(in_var)} does not exist.")
  }
  if (!single_file(d)) {
    stop_glue(
      "Parent specified via {sq(in_var)} doesn't uniquely ",
      "identify exactly one folder or Team Drive."
    )
  }
  if (!is_parental(d)) {
    stop_glue(
      "Requested parent {sq(in_var)} is invalid: neither a folder ",
      "nor a Team Drive.")
  }
  d
}

#' Check facts about a dribble
#'
#' Sometimes you need to check things about a [`dribble`]` or about the files it
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
confirm_dribble <- function(d) {
  if (!is_dribble(d)) {
    stop_glue("Input is not a dribble.")
  }
  d
}

#' @export
#' @rdname dribble-checks
confirm_single_file <- function(d) {
  in_var <- deparse(substitute(d))
  if (no_file(d)) {
    stop_glue("{sq(in_var)} does not identify at least one Drive file.")
  }
  if (!single_file(d)) {
    stop_glue("{sq(in_var)} identifies more than one Drive file.")
  }
  d
}

#' @export
#' @rdname dribble-checks
confirm_some_files <- function(d) {
  in_var <- deparse(substitute(d))
  if (no_file(d)) {
    stop_glue("{sq(in_var)} does not identify at least one Drive file.")
  }
  d
}

#' @export
#' @rdname dribble-checks
is_folder <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_chr(d$drive_resource, "mimeType") ==
    "application/vnd.google-apps.folder"
}

#' @export
#' @rdname dribble-checks
is_parental <- function(d) {
  stopifnot(inherits(d, "dribble"))
  kind <- purrr::map_chr(d$drive_resource, "kind")
  mime_type <- purrr::map_chr(d$drive_resource, "mimeType", .default = NA)
  kind == "drive#teamDrive" | mime_type == "application/vnd.google-apps.folder"
}

#' @export
#' @rdname dribble-checks
## TO DO: handle team drives here
is_mine <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_lgl(d$drive_resource, list("owners", 1, "me"))
}

#' @export
#' @rdname dribble-checks
is_team_drive <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_chr(d$drive_resource, "kind") == "drive#teamDrive"
}

#' @export
#' @rdname dribble-checks
is_team_drivy <- function(d) {
  stopifnot(inherits(d, "dribble"))
  is_team_drive(d) |
    purrr::map_lgl(d$drive_resource, ~ !is.null(.x[["teamDriveId"]]))
}

## promote an element in drive_resource into a top-level variable
## if new, it will be the second column, presumably after `name`
## if variable by that name already exists, it is overwritten in place
promote <- function(d, elem) {
  present <- any(purrr::map_lgl(d$drive_resource, ~ elem %in% names(.x)))
  if (present) {
    new <- purrr::simplify(purrr::map(d$drive_resource, elem))
  } else {
    ## TO DO: do we really want promote() to be this forgiving?
    ## adds a placeholder column for elem if not present in drive_resource
    ## ensure elem is added, even if there are zero rows
    new <- rep_len(list(NULL), nrow(d))
    ## TO DO: find a way to emulate .default behavior from type-specific
    ## mappers ... might need to create my own simplify()
    ## https://github.com/tidyverse/purrr/issues/336
    ## as this stands, you will get a list-column whenever there is at
    ## least one NULL
  }

  pos <- match(elem, names(d))
  if (is.na(pos)) {
    d <- tibble::add_column(d, new, .after = 1)
    names(d)[2] <- elem
  } else {
    d[[pos]] <- new
  }

  d
}
