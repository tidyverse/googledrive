#' Publish Google Drive file
#'
#' @param file `drive_file` object representing the file you would like to publish
#' @param publish logical, indicating whether you'd like to publish the most recent revision of the file (default `TRUE`)
#' @param ... name-value pairs to add to the API request body, for example `publishAuto = FALSE` will ensure that each subsequent revision will not be automatically published (default here is `publishAuto = TRUE`)
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return `drive_file` object, a list with published information as a `tibble` under the list element `publish`
#' @export
gd_publish <- function(file, publish = TRUE, ..., verbose = TRUE){

  file <- gd_check_publish(file)

  request <- build_gd_publish(file = file, publish = publish, ...)
  response <- make_request(request, encode = "json")
  proc_res <- process_gd_publish(response = response, file = file, verbose = verbose)

  file <- gd_check_publish(file)
  invisible(file)
}

build_gd_publish <- function(file = NULL, publish = TRUE, ...){

  x <- list(...)
  if ("publishAuto" %in% names(x)){
    publishAuto <- x$publishAuto
  } else publishAuto <- TRUE

  rev_id <- file$publish$revision
  url <- file.path(.state$gd_base_url_files_v3, id,"revisions", rev_id)
  build_request(endpoint = url,
               params = list(published = publish,
                             publishAuto = publishAuto,
                             ...),
               token = gd_token(),
               method = "PATCH")
}

process_gd_publish <- function(response = NULL, file = NULL, verbose = TRUE){

   proc_res <- process_request(response)


  if (verbose){
    if(response$status_code == 200L){
      cat(sprintf("You have changed the publication status of '%s'.", file$name))
    } else
      cat(sprintf("Uh oh, something went wrong. The publication status of '%s' was not changed", file$name))
  }
}

#' Check if Google Drive file is published
#'
#' @param file `drive_file` object representing the file you would like to check the published status of
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return `drive_file` object, a list with published information as a `tibble` under the list element `publish`
#' @export
gd_check_publish <- function (file, verbose = TRUE){

  request <- build_gd_check_publish1(file = file)
  response <- make_request(request)
  proc_res <- process_request(response)

  request <- build_gd_check_publish2(proc_res = proc_res)
  response <- make_request(request)
  process_gd_check_publish(response = response, file = file, verbose = verbose)
}

build_gd_check_publish1 <- function(file = NULL){
  if(!inherits(file, "drive_file")){
    spf("Input must be a `drive_file`. See `gd_file()`")
  }

  id <- file$id

  url <- file.path(.state$gd_base_url_files_v3, id,"revisions")

  build_request(endpoint = url,
                token = gd_token())
}

build_gd_check_publish2 <- function(proc_res = NULL){
  last_rev <- length(proc_res$revisions)
  rev_id <- proc_res$revisions[[last_rev]]$id

  fields <- paste(c("id","published","publishAuto","lastModifyingUser"), collapse = ",")

  url <- file.path(.state$gd_base_url_files_v3, id,"revisions",rev_id)
  req <- build_request(endpoint = url,
                       token = gd_token(),
                       params = list(fields = fields))
}

process_gd_check_publish <- function(response = NULL, file = NULL, verbose = TRUE){
  proc_res <- process_request(response)

  file$publish <- tibble::tibble(
    check_time = Sys.time(),
    revision = proc_res$id,
    published = proc_res$published,
    auto_publish = proc_res$publishAuto,
    last_user = proc_res$lastModifyingUser$displayName
  )

  if (verbose){
    if (proc_res$published) {
      cat(sprintf("The latest revision of Google Drive file '%s' is published.", file$name))
    } else
      cat(sprintf("The latest revision of the Google Drive file '%s' is not published.", file$name))
  }

  invisible(file)
}
