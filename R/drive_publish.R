#' Publish native Google files
#'
#' Publish (or un-publish) native Google files to the web. Native Google files
#' include Google Docs, Google Sheets, and Google Slides. The returned
#' [`dribble`] will have extra columns, `published` and `revisions_resource`.
#' Read more in [drive_reveal()].
#'
#' @seealso Wraps the `revisions.update` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/revisions/update>
#'
#' @template file-plural
#' @param ... Name-value pairs to add to the API request body (see API docs
#' linked below for details). For `drive_publish()`, we include
#' `publishAuto = TRUE` and `publishedOutsideDomain = TRUE`, if user does not
#' specify other values.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Upload file to publish
#' file <- drive_upload(R.home('doc/BioC_mirrors.csv'),
#'   type = "spreadsheet")
#'
#' ## Publish file
#' file <- drive_publish(file)
#'
#' ## Unpublish file
#' file <- drive_unpublish(file)
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_publish <- function(file, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = TRUE, ..., verbose = verbose)
}

#' @rdname drive_publish
#' @export
drive_unpublish <- function(file, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = FALSE, ..., verbose = verbose)
}

drive_change_publish <- function(file,
                                 publish = TRUE,
                                 ...,
                                 verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  file <- promote(file, "mimeType")
  type_ok <- is_native(file)
  if (!all(type_ok)) {
    bad_mime_types <- glue_data(file[!type_ok, ], "  * {name}: {mimeType}")
    stop_collapse(c(
      "Only native Google files can be published.",
      "Files that do not qualify (or, at least, the first 10):",
      utils::head(bad_mime_types, 10),
      "Check out `drive_share()` to change sharing permissions."
    ))
  }
  file$mimeType <- NULL

  params <- toCamel(list(...))
  params[["published"]] <- publish
  params[["publishAuto"]] <- params[["publishAuto"]] %||% TRUE
  params[["publishedOutsideDomain"]] <-
    params[["publishedOutsideDomain"]] %||% TRUE
  params[["revisionId"]] <- "head"
  params[["fields"]] <- "*"

  revision_resource <- purrr::map(
    file$id,
    change_publish_one,
    params = params
  )
  if (verbose) {
    success <- glue_data(file, "  * {name}: {id}")
    message_collapse(c(
      glue("Files now {if (publish) '' else 'NOT '}published:\n"),
      success
    ))
  }
  invisible(drive_reveal(file, "published"))
}

change_publish_one <- function(id, params) {
  params[["fileId"]] <- id
  request <- generate_request(
    endpoint = "drive.revisions.update",
    params = params
  )
  response <- make_request(request, encode = "json")
  process_response(response)
}

drive_reveal_published <- function(file) {
  confirm_dribble(file)
  revision_resource <- purrr::map(file$id, get_publish_one)
  ## Remove the columns if they already exist
  file[["published"]] <- NULL
  file[["revision_resource"]] <- NULL
  file <- tibble::add_column(
    file,
    published = purrr::map_lgl(revision_resource, "published", .default = FALSE),
    .after = 1
  )
  tibble::add_column(
    file,
    revision_resource = revision_resource
  )
}

get_publish_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.revisions.get",
    params = list(
      fileId = id,
      revisionId = "head",
      fields = "*"
    )
  )
  response <- make_request(request)
  ## folders generate a 403
  if (httr::status_code(response) == 403) {
    return(NULL)
  }
  process_response(response)
}
