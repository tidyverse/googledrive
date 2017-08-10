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
  file_update <- drive_show_publish(file = file, verbose = FALSE)
  file_update <- confirm_some_files(file_update)
  file_update <- split(file_update, 1:nrow(file_update))
  file_update <- purrr::map(file_update,
                            change_publish_one,
                            publish = publish,
                            ...,
                            verbose = verbose)
  file_update <- do.call(rbind, file_update)
  if (verbose) {
    success <- glue_data(file_update, "  * {name}: {id}")
    message_collapse(c(
      glue("\nFiles now {if (publish) '' else 'NOT '}published:\n"),
      success
    ))
  }
  invisible(file_update)
}
change_publish_one <- function(file,
                               publish = TRUE,
                               ...,
                               verbose = TRUE) {

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

#' Add a published column to your dribble
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

  files <- split(file, 1:nrow(file))
  files <- purrr::map(files, show_publish_one, verbose = verbose)
  file <- do.call(rbind, files)
  invisible(file)
}

show_publish_one <- function(file, verbose = TRUE) {

  request <- generate_request(
    endpoint = "drive.revisions.get",
    params = list(fileId = file$id,
                  revisionId = "head",
                  fields = "*")
  )
  response <- make_request(request)
  proc_res <- process_response(response)

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
  tibble::add_column(d,
                     published_check_time = Sys.time(),
                     revision_id = x$id,
                     published = x$published,
                     auto_publish = x$publishAuto %||% FALSE,
                     .after = 1
  )
}
