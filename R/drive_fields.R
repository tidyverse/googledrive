#' Request partial resources
#'
#' @description You may be able to improve the performance of your API calls by
#'   requesting only the metadata that you actually need. This function is
#'   primarily for internal use and is currently focused on the
#'   [Files resource](https://developers.google.com/drive/v3/reference/files).
#' Note that high-level googledrive functions assume that the `name`, `id`, and
#' `kind` fields are included, at a bare minimum. Assuming that
#' `resource = "files"` (the default), input provided via `fields` is checked
#' for validity against the known field names and the validated fields are
#' returned. To see a tibble containing all possible fields and a short
#' description of each, call `drive_fields(expose())`.
#'
#' @description `prep_fields()` prepares fields for inclusion as query
#'   parameters.
#'
#' @seealso
#'   [Working with partial resources](https://developers.google.com/drive/v3/web/performance#partial),
#'   in the Drive API documentation.
#'
#' @param fields Character vector of field names. If `resource = "files"`, they
#'   are checked for validity. Otherwise, they are passed through.
#' @param resource Character, naming the API resource of interest. Currently,
#'   only the Files resource is anticipated.
#'
#' @return `drive_fields()`: Character vector of field names.
#' `prep_fields()`: a string.
#' @export
#'
#' @examples
#' ## get a tibble of all fields for the Files resource + indicator of defaults
#' drive_fields(expose())
#'
#' ## invalid fields are removed and throw warning
#' drive_fields(c("name", "parents", "ownedByMe", "pancakes!"))
#'
#' ## prepare fields for query
#' prep_fields(c("name", "parents", "kind"))
drive_fields <- function(fields = NULL,
                         resource = "files") {
  if (!identical(resource, "files")) {
    message("ALERT! Only fields for the `files` resource are built-in.")
  }
  if (is.null(fields)) {
    return(invisible(character()))
  }
  if (is_expose(fields)) {
    return(.drive$files_fields)
  }

  stopifnot(is.character(fields))
  if (!identical(resource, "files")) {
    return(fields)
  }

  out <- intersect(fields, .drive$files_fields$name)
  if (!setequal(fields, out)) {
    bad_fields <- setdiff(fields, out)
    warning_collapse(
      c("Ignoring fields that are non-standard for the Files resource:",
        glue("  * {bad_fields}"))
    )
  }
  out
}

#' @rdname drive_fields
#' @export
prep_fields <- function(fields, resource = "files") {
  resource <- glue("{resource}/")
  paste0(resource, fields, collapse = ",")
}
## usage:
## resource = NULL because we prepend "files/" when n > 1 items can come back
# request <- generate_request(
#   endpoint = "drive.files.get",
#   params = list(
#     fileId = two_files_search$id[1],
#     fields = prep_fields(c("name", "owners"), resource = NULL)
#   )
# )
# response <- make_request(request)
# process_response(response)
