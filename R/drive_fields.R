#' Request partial resources
#'
#' You may be able to improve the performance of your API calls by requesting
#' only the metadata that you actually need. This function is primarily for
#' internal use and is geared towards the
#' [Files resource](https://developers.google.com/drive/v3/reference/files).
#' Assuming that `resource = "files"`, `drive_fields()` returns the `default`
#' fields, `all` fields, or, if `fields` is non-`NULL`, the subset of the input
#' fields that are recognized as valid fields. `prep_fields()` prepares fields
#' for inclusion as query parameters.
#'
#' @seealso [Working with partial resources](https://developers.google.com/drive/v3/web/performance#partial),
#'   in the Drive API documentation
#'
#' @param fields Character vector of field names. Optional.
#' @param resource Character, naming the API resource of interest.
#' @param which Consulted only when `resource = "files"` and `fields = NULL`,
#'   dictates whether all fields are returned or the googledrive defaults.
#'
#' @return Character vector of field names or a single string.
#' @export
#'
#' @examples
#' ## to get default fields or all fields for the Files resource
#' drive_fields()
#' drive_fields(which = "all")
#'
#' ## invalid fields are removed and throw warning
#' drive_fields(c("name", "parents", "ownedByMe", "pancakes!"))
#'
#' ## fields for query
#' prep_fields(c("name", "parents", "ownedByMe"))
drive_fields <- function(fields = NULL,
                         resource = "files",
                         which = c("default", "all")) {
  which <- match.arg(which)

  if (is.null(fields)) {
    return(
      switch(
        which,
        default = .drive$files_fields$name[.drive$files_fields$default],
        all = .drive$files_fields$name
      )
    )
  }

  stopifnot(is.character(fields))
  if (!identical(resource, "files")) {
    return(fields)
  }

  out <- intersect(fields, .drive$files_fields$name)
  if (!setequal(fields, out)) {
    warning(
      collapse(
        c("Ignoring fields that are non-standard for the Files resource:",
          setdiff(fields, out)),
        sep = "\n"
      )
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
