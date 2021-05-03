#' dribble object
#'
#' @description googledrive stores the metadata for one or more Drive files or
#'   shared drives as a `dribble`. It is a "Drive
#'   [tibble][tibble::tibble-package]" with one row per file or shared drive
#'   and, at a minimum, these columns:
#'   * `name`: a character column containing file or shared drive names
#'   * `id`: a character column of file or shared drive ids
#'   * `drive_resource`: a list-column, each element of which is either a
#'   [Files resource](https://developers.google.com/drive/api/v3/reference/files#resource-representations)
#'   or a [Drives resource](https://developers.google.com/drive/api/v3/reference/drives#resource-representations)
#'   object. Note there is no guarantee that all documented fields are always
#'   present. We do check if the `kind` field is present and equal to one of
#'   `drive#file` or `drive#drive`.
#'
#' @description The `dribble` format is handy because it exposes the file name,
#'   which is good for humans, but keeps it bundled with the file's unique id
#'   and other metadata, which are needed for API calls.
#'
#' @description In general, the dribble class will be retained even after
#'   subsetting, as long as the required variables are present and of the
#'   correct type.
#'
#' @name dribble
#' @seealso [as_dribble()]
NULL

# implementing dribble as advised here:
# https://github.com/hadley/adv-r/blob/master/S3.Rmd

new_dribble <- function(x) {
  stopifnot(inherits(x, "data.frame"))
  structure(x, class = c("dribble", "tbl_df", "tbl", "data.frame"))
}

validate_dribble <- function(x) {
  stopifnot(inherits(x, "dribble"))

  if (!has_dribble_cols(x)) {
    missing_cols <- setdiff(dribble_cols, colnames(x))
    abort(c(
      "Invalid {.cls dribble}. \\
       {cli::qty(length(missing_cols))}{?This/These} required column{?s} \\
       {?is/are} missing:",
      bulletize(missing_cols)
    ))
  }

  if (!has_dribble_coltypes(x)) {
    mistyped_cols <- dribble_cols[!dribble_coltypes_ok(x)]
    abort(c(
      "Invalid {.cls dribble}. \\
       {cli::qty(length(mistyped_cols))}{?This/These} column{?s} {?has/have} \\
       the wrong type:",
      bulletize(mistyped_cols)
    ))
  }

  if (!has_drive_resource(x)) {
    # \u00a0 is a nonbreaking space
    abort(c(
      'Invalid {.cls dribble}. Can\'t confirm \\
       {.code kind\u00a0=\u00a0"drive#file"} or \\
       {.code kind\u00a0=\u00a0"drive#drive"} \\
       for all elements of the {.code drive_resource} column.'
    ))
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
as_tibble.dribble <- function(x, ...) {
  as_tibble(
    structure(x, class = class(tibble::tibble())),
    ...
  )
}

dribble_cols <- c("name", "id", "drive_resource")

has_dribble_cols <- function(x) {
  all(dribble_cols %in% colnames(x))
}

dribble_coltypes_ok <- function(x) {
  c(
    name = is.character(x$name),
    id = is.character(x$id),
    drive_resource = inherits(x$drive_resource, "list")
  )
}

has_dribble_coltypes <- function(x) {
  all(dribble_coltypes_ok(x))
}

has_drive_resource <- function(x) {
  kind <- purrr::map_chr(x$drive_resource, "kind", .default = NA_character_)
  # TODO: remove `drive#teamDrive` here, when possible
  all(!is.na(kind) & kind %in% c("drive#file", "drive#drive", "drive#teamDrive"))
}

# used across several functions that create a file or modify "parentage"
# processes a putative parent folder or shared drive
as_parent <- function(d) {
  in_var <- deparse(substitute(d))
  d <- as_dribble(d)
  # wording chosen to work for folder and shared drive
  invalid_parent <- "Parent specified via {.arg {in_var}} is invalid:"
  if (no_file(d)) {
    abort(c(invalid_parent, x = "Does not exist."))
  }
  if (!single_file(d)) {
    abort(c(
      invalid_parent,
      x = "Doesn't uniquely identify exactly one folder or shared drive."
    ))
  }
  if (!is_parental(d)) {
    abort(c(
      invalid_parent,
      x = "Is neither a folder nor a shared drive."
    ))
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
#' @examplesIf drive_has_token()
#' ## most of us have multiple files or folders on Google Drive
#' d <- drive_find()
#' is_dribble(d)
#' no_file(d)
#' single_file(d)
#' some_files(d)
#'
#' # this will error
#' # confirm_single_file(d)
#'
#' confirm_some_files(d)
#' is_folder(d)
#' is_mine(d)
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
    abort("Input is not a {.cls dribble}.")
  }
  d
}

#' @export
#' @rdname dribble-checks
confirm_single_file <- function(d) {
  in_var <- deparse(substitute(d))
  if (no_file(d)) {
    abort("{.arg {in_var}} does not identify at least one Drive file.")
  }
  if (!single_file(d)) {
    abort("{.arg {in_var}} identifies more than one Drive file.")
  }
  d
}

#' @export
#' @rdname dribble-checks
confirm_some_files <- function(d) {
  in_var <- deparse(substitute(d))
  if (no_file(d)) {
    abort("{.arg {in_var}} does not identify at least one Drive file.")
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
is_native <- function(d) {
  stopifnot(inherits(d, "dribble"))
  d <- promote(d, "mimeType")
  grepl("application/vnd.google-apps.", d$mimeType) & !is_folder(d)
}

#' @export
#' @rdname dribble-checks
is_parental <- function(d) {
  stopifnot(inherits(d, "dribble"))
  kind <- purrr::map_chr(d$drive_resource, "kind")
  mime_type <- purrr::map_chr(d$drive_resource, "mimeType", .default = NA)
  # TODO: remove `drive#teamDrive` here, when possible
  kind == "drive#teamDrive" |
    kind == "drive#drive" |
    mime_type == "application/vnd.google-apps.folder"
}

#' @export
#' @rdname dribble-checks
## TO DO: do I need to do anything about shared drives here?
is_mine <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_lgl(d$drive_resource, list("owners", 1, "me"))
}

#' @export
#' @rdname dribble-checks
is_shared_drive <- function(d) {
  stopifnot(inherits(d, "dribble"))
  purrr::map_chr(d$drive_resource, "kind") == "drive#drive"
}

## promote an element in drive_resource into a top-level variable
## if new, it will be the second column, presumably after `name`
## if variable by that name already exists, it is overwritten in place
## if you request `this_var`, we look for `thisVar` in drive_resource
## but use `this_var` as the variable name
promote <- function(d, elem) {
  elem_orig <- elem
  elem <- camelCase(elem)
  present <- any(purrr::map_lgl(d$drive_resource, ~elem %in% names(.x)))
  if (present) {
    val <- purrr::simplify(purrr::map(d$drive_resource, elem))
    ## TO DO: find a way to emulate .default behavior from type-specific
    ## mappers ... might need to create my own simplify()
    ## https://github.com/tidyverse/purrr/issues/336
    ## as this stands, you will get a list-column whenever there is at
    ## least one NULL
  } else {
    ## TO DO: do we really want promote() to be this forgiving?
    ## adds a placeholder column for elem if not present in drive_resource
    ## ensure elem is added, even if there are zero rows
    val <- rep_len(list(NULL), nrow(d))
  }
  put_column(d, nm = elem_orig, val = val, .after = 1)
}
