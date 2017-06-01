#' Publish Google Drive file
#'
#' @param file `dribble` or `drive_id` object representing the file you would
#'   like to publish
#' @param ... name-value pairs to add to the API request body, for example
#'   `publishAuto = FALSE` will ensure that each subsequent revision will not be
#'   automatically published (default here is `publishAuto = TRUE`)
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return `dribble` object, with published information as a `tibble`
#'   added under the column name `publish`
#' @export
drive_publish <- function(file = NULL, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = TRUE, ..., verbose = verbose)
}

#' Unpublish Google Drive file
#'
#' @param file `dribble` or `drive_id` object representing the file you would
#'   like to unpublish
#' @param ... name-value pairs to add to the API request body.
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return `dribble` object, with published information as a `tibble`
#'   added under the column name `publish`
#' @export
drive_unpublish <- function(file = NULL, ..., verbose = TRUE) {
  drive_change_publish(file = file, publish = FALSE, ..., verbose = verbose)
}

drive_change_publish <- function(file = NULL, publish = TRUE, ..., verbose = TRUE) {
  file_update <- drive_is_published(file = file, verbose = FALSE)

  ## TO DO can only publish 1 at a time at the moment
  if (nrow(file_update) != 1) {
    spf("We can currently only publish `dribble`s with 1 row.")
  }
  x <- list(...)
  x$published <- publish
  if (!("publishAuto" %in% names(x))) {
    x$publishAuto <- TRUE
  }

  x$fileId <- file_update$id

  x$revisionId <- purrr::map_chr(file_update$publish, "revision")

  mime_type <- purrr::map_chr(file_update$drive_file, "mimeType")

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
    if (response$status_code == 200L) {
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

  file_update <- as.dribble(drive_id(file$id))
  drive_is_published(file = file_update, verbose = FALSE)
}

#' Check if Google Drive file is published
#'
#' @param file `dribble` or `drive_id` object representing the file you would like to check the published status of
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return `dribble` object
#' @export
drive_is_published <- function (file = NULL, verbose = TRUE) {

  file <- as.dribble(file)

  mime_types <- purrr::map_chr(file$drive_file, "mimeType")
  if (!all(grepl("application/vnd.google-apps.",
             mime_types))) {
    stop(
      glue::glue(
        "Only Google Drive files can be published. \nYour file is of type:\n {paste(mime_types, collapse = ' \n ')} \nCheck out `drive_share()` to change sharing permissions."
        )
    )
  }

  fields <- paste(c("id", "published", "publishAuto", "lastModifyingUser"),
                  collapse = ",")

  published <- purrr::map2(file$id, file$name, ~ {
    request <- build_request(
      endpoint = "drive.revisions.get",
      params = list(fileId = .x,
                    revisionId = "head",
                    fields = fields)
    )
    response <- make_request(request)
    proc_res <- process_response(response)

    if (verbose) {
      if (proc_res$published) {
        message(
          glue::glue(
            "The latest revision of Google Drive file '{.y}' is published."
          ))
      } else
        message(
          glue::glue(
            "The latest revision of the Google Drive file '{.y}' is not published."
          )
        )
    }

    tibble::tibble(
      check_time = Sys.time(),
      revision = proc_res$id,
      published = proc_res$published,
      auto_publish = ifelse(
        !is.null(proc_res$publishAuto),
        proc_res$publishAuto,
        FALSE
      )
    )
  })
  file$publish <- published

  invisible(file)
}
