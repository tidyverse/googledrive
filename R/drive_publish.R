#' Publish Google Drive file.
#'
#' @template file
#' @param ... Name-value pairs to add to the API request body, for example
#'   `publishAuto = FALSE` will ensure that each subsequent revision will not be
#'   automatically published (default here is `publishAuto = TRUE`).
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
#' drive_publish(file)
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_publish <- function(file, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = TRUE, ..., verbose = verbose)
}

#' Unpublish Google Drive file
#'
#' @template file
#' @param ... Name-value pairs to add to the API request body.
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_unpublish <- function(file, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = FALSE, ..., verbose = verbose)
}

drive_change_publish <- function(file,
                                 publish = TRUE,
                                 ...,
                                 verbose = TRUE) {
  file_update <- drive_is_published(file = file, verbose = FALSE)

  file_update <- confirm_single_file(file_update)

  x <- list(...)
  x$published <- publish
  if (!("publishAuto" %in% names(x))) {
    x$publishAuto <- TRUE
  }

  x$fileId <- file_update$id

  x$revisionId <- purrr::map_chr(file_update$publish, "revision")

  mime_type <- purrr::map_chr(file_update$files_resource, "mimeType")

  x$revisionId <- if (grepl("application/vnd.google-apps.spreadsheet", mime_type)) {
    1
  } else {
    x$revisionId
  }

  x$fields <- "*"

  request <- generate_request(
    endpoint = "drive.revisions.update",
    params = x
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  if (verbose) {
    if (httr::status_code(response) == 200L) {
      message_glue(
        "\nYou have changed the publication status of file:\n",
        "  * {sq(file_update$name)}"
      )
    } else
      message_glue(
        "\nSomething went wrong. You have NOT changed the publication status of file:\n",
        "  * {sq(file_update$name)}"
      )
  }

  ## if we want to autopublish, it must have already been published, so
  ## we need to run again
  if (isTRUE(x$published) && isTRUE(x$publishAuto)) {
    response <- make_request(request, encode = "json")
    proc_res <- process_response(response)
  }

  file_update$publish <- publish_tbl(proc_res)
  invisible(file_update)
}

#' Check if Google Drive file is published
#'
#' @template file
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Upload file to check publication status
#' file <- drive_upload(R.home('doc/BioC_mirrors.csv'),
#'   type = "spreadsheet")
#'
#' ## Check publication status
#' drive_is_published(file)
#'
#' ## Publish file
#' drive_publish(file)
#'
#' ## Check publication status agian
#' drive_is_published(file)
#'
#' ## Unpublish file
#' drive_unpublish(file)
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_is_published <- function(file, verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  mime_types <- purrr::map_chr(file$files_resource, "mimeType")
  if (!all(grepl("application/vnd.google-apps.", mime_types)) || is_folder(file)) {
    all_mime_types <- glue::glue_data(file, "  * {name}: {mime_types}")
    stop_collapse(c(
      "Only Google Drive type files can be published.",
      "Your file(s) and type:",
      all_mime_types,
      "Check out `drive_share()` to change sharing permissions."
    ))
  }

  published <- purrr::map2(file$id, file$name, is_published_one, verbose = verbose)
  file$publish <- published

  invisible(file)
}

is_published_one <- function(id, name, verbose = TRUE) {

  request <- generate_request(
    endpoint = "drive.revisions.get",
    params = list(fileId = id,
                  revisionId = "head",
                  fields = "*")
  )
  response <- make_request(request)
  proc_res <- process_response(response)

  if (verbose) {
    message_glue(
      "The latest revision of file {sq(name)} is ",
      "{if (proc_res$published) '' else 'NOT '}published."
    )
  }
  publish_tbl(proc_res)
}

publish_tbl <- function(x) {
  tibble::tibble(
    check_time = Sys.time(),
    revision = x$id,
    published = x$published,
    auto_publish = x$publishAuto %||% FALSE
  )
}
