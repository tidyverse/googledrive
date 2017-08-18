#' Publish native Google files
#'
#' Publish (or un-publish) native Google files to the web. Native Google files
#' include Google Docs, Google Sheets, and Google Slides. See the current status
#' with `drive_reveal("publishing")`.
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

  mime_types <- purrr::map_chr(file$drive_resource, "mimeType")
  if (!all(grepl("application/vnd.google-apps.", mime_types)) || any(is_folder(file))) {
    all_mime_types <- glue_data(file, "  * {name}: {mime_types}")
    stop_collapse(c(
      "\nOnly Google Drive type files can be published.",
      "Your file(s) are type:",
      all_mime_types,
      "Check out `drive_share()` to change sharing permissions."
    ))
  }

  params <- list(...)
  params[["published"]] <- publish
  params[["publishAuto"]] <- params[["publishAuto"]] %||% TRUE
  params[["publishedOutsideDomain"]] <- params[["publishedOutsideDomain"]] %||% TRUE
  params[["revisionId"]] <- "head"
  params[["fields"]] <- "*"

  revision_resource <- purrr::map(file$id,
                                  change_publish_one,
                                  params = params)
  ## should we re-register the file here? technically when you publish,
  ## the version increases by 1 (which is in drive_resource) so if
  ## we don't re-register, the version will be incorrect.
  file <- add_publish_cols(file, revision_resource)
  if (verbose) {
    success <- glue_data(file, "  * {name}: {id}")
    message_collapse(c(
      glue("\nFiles now {if (publish) '' else 'NOT '}published:\n"),
      success
    ))
  }
  invisible(file)
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

drive_show_publish <- function(file) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)
  revision_resource <- purrr::map(file$id, get_publish_one)
  add_publish_cols(file, revision_resource)
}

get_publish_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.revisions.get",
    params = list(fileId = id,
                  revisionId = "head",
                  fields = "*")
  )
  response <- make_request(request)
  process_response(response)
}

add_publish_cols <- function(d, x) {
  ## Remove the columns if they already exist
  d[["published"]] <- NULL
  d[["revision_resource"]] <- NULL
  tibble::add_column(
    d,
    published = purrr::map_lgl(x, "published"),
    revision_resource = x,
    .after = 1
  )
}
