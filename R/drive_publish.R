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

  file <- as_dribble(file)
  file <- confirm_some_files(file)
  file <- purrr::map(file$id,
                     change_publish_one,
                     publish = publish,
                     ...,
                     verbose = verbose)
  file <- do.call(rbind, file)
  if (verbose) {
    success <- glue_data(file, "  * {name}: {id}")
    message_collapse(c(
      glue("\nFiles now {if (publish) '' else 'NOT '}published:\n"),
      success
    ))
  }
  invisible(file)
}
change_publish_one <- function(id,
                               publish = TRUE,
                               ...,
                               verbose = TRUE) {
  file <- drive_show_publish(as_id(id), verbose = FALSE)
  x <- list(...)
  x$published <- publish
  if (!("publishAuto" %in% names(x))) {
    x$publishAuto <- TRUE
  }

  x$fileId <- file$id
  x$revisionId <- file$revision_id
  mime_type <- purrr::map_chr(file$drive_resource, "mimeType")

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

  ## if we want to autopublish, it must have already been published, so
  ## we need to run again
  if (isTRUE(x$published) && isTRUE(x$publishAuto)) {
    response <- make_request(request, encode = "json")
    proc_res <- process_response(response)
  }

  add_publish_cols(file, proc_res)
}

#' Add columns with publication information to your dribble
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
#' drive_show_publish(file)
#'
#' ## Publish file
#' drive_publish(file)
#'
#' ## Check publication status agian
#' drive_show_publish(file)
#'
#' ## Unpublish file
#' drive_unpublish(file)
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_show_publish <- function(file, verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  mime_types <- purrr::map_chr(file$drive_resource, "mimeType")
  if (!all(grepl("application/vnd.google-apps.", mime_types)) || is_folder(file)) {
    all_mime_types <- glue_data(file, "  * {name}: {mime_types}")
    stop_collapse(c(
      "\nOnly Google Drive type files can be published.",
      "Your file(s) are type:",
      all_mime_types,
      "Check out `drive_share()` to change sharing permissions."
    ))
  }

  file <- purrr::map(file$id, show_publish_one, verbose = verbose)
  file <- do.call(rbind, file)
  invisible(file)
}

show_publish_one <- function(id, verbose = TRUE) {

  request <- generate_request(
    endpoint = "drive.revisions.get",
    params = list(fileId = id,
                  revisionId = "head",
                  fields = "*")
  )
  response <- make_request(request)
  proc_res <- process_response(response)

  file <- as_dribble(as_id(id))

  if (verbose) {
    message_glue(
      "The latest revision of file {sq(file$name)} is ",
      "{if (proc_res$published) '' else 'NOT '}published."
    )
  }
  add_publish_cols(file, proc_res)
}

add_publish_cols <- function(d, x) {
  if ("published" %in% names(d)) {
    d$published_check_time <- Sys.time()
    d$revision_id <- x$id
    d$published <- x$published
    d$auto_publish <- x$publishAuto %||% FALSE
    return(d)
  }
  tibble::add_column(
    d,
    published = x$published,
    revision_id = x$id,
    published_check_time = Sys.time(),
    auto_publish = x$publishAuto %||% FALSE,
    .after = 1
  )
}
