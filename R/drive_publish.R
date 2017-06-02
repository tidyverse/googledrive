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
drive_publish <- function(file = NULL, ..., verbose = TRUE) {
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
drive_unpublish <- function(file = NULL, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = FALSE, ..., verbose = verbose)
}

drive_change_publish <- function(file = NULL, publish = TRUE, ..., verbose = TRUE) {
  file_update <- drive_is_published(file = file, verbose = FALSE)

  ## TO DO can only publish 1 at a time at the moment
  if (nrow(file_update) != 1) {
    spf("Publish exactly 1 file at a time.")
  }
  x <- list(...)
  x$published <- publish
  if (!("publishAuto" %in% names(x))) {
    x$publishAuto <- TRUE
  }

  x$fileId <- file_update$id

  x$revisionId <- purrr::map_chr(file_update$publish, "revision")

  mime_type <- purrr::map_chr(file_update$files_resource, "mimeType")

  ## TO DO: do you need vectorized ifelse()? if not, use if(){...}else{...}
  x$revisionId <- ifelse(grepl("application/vnd.google-apps.spreadsheet", mime_type),
                         1,
                         x$revisionId)

  request <- build_request(
    endpoint = "drive.revisions.update",
    params = x
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  if (verbose) {
    if (httr::status_code(response) == 200L) {
      ## TO DO: switch these to glue
      message(sprintf(
        "You have changed the publication status of '%s'.",
        file$name
      ))
    } else
      message(
        sprintf(
          "Uh oh, something went wrong. The publication status of '%s' was not changed",
          file$name
        )
      )
  }

  ## if we want to autopublish, it must have already been published, so
  ## we need to run again
  if (isTRUE(x$published) && isTRUE(x$publishAuto)) {
    response <- make_request(request, encode = "json")
    proc_res <- process_response(response)
  }

  ## TO DO: do we really have to call the API again?
  file_update <- as_dribble(drive_id(file$id))
  drive_is_published(file = file_update, verbose = FALSE)
}

#' Check if Google Drive file is published
#'
#' @template file
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_is_published <- function(file = NULL, verbose = TRUE) {

  file <- as_dribble(file)

  mime_types <- purrr::map_chr(file$files_resource, "mimeType")
  if (!all(grepl("application/vnd.google-apps.", mime_types))) {
    stop(
      glue::glue(
        "Only Google Drive files can be published. \nYour file is of type:\n {paste(mime_types, collapse = ' \n ')} \nCheck out `drive_share()` to change sharing permissions."
      )
    )
  }

  published <- purrr::map2(file$id, file$name, publish_one, verbose = verbose)
  file$publish <- published

  invisible(file)
}

publish_one <- function(id, name, verbose = TRUE) {
  fields <- paste(c("id", "published", "publishAuto", "lastModifyingUser"),
                  collapse = ",")

  request <- build_request(
    endpoint = "drive.revisions.get",
    params = list(fileId = id,
                  revisionId = "head",
                  fields = fields)
  )
  response <- make_request(request)
  proc_res <- process_response(response)

  if (verbose) {
    if (proc_res$published) {
      message(
        glue::glue(
          "The latest revision of Google Drive file '{name}' is published."
        ))
    } else
      message(
        glue::glue(
          "The latest revision of the Google Drive file '{name}' is not published."
        )
      )
  }

  tibble::tibble(
    check_time = Sys.time(),
    revision = proc_res$id,
    published = proc_res$published,
    ## TO DO: do you need vectorized ifelse()? if not, use if(){...}else{...}
    auto_publish = ifelse(
      !is.null(proc_res$publishAuto),
      proc_res$publishAuto,
      FALSE
    )
  )
}
