#' Publish Google Drive file
#'
#' @param file `drive_file` object representing the file you would like to publish
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return logical, whether the file was successfully published
#' @export
gd_publish <- function(file, verbose = TRUE){

  if(!inherits(file, "drive_file")){
    spf("Input must be a `drive_file`. See `gd_file()`")
  }

  if (gd_check_publish(file, verbose = FALSE)){
    spf("The Google Drive file '%s' is already published", file$name)
  }

  id <- file$id

  url <- file.path(.state$gd_base_url_files_v3, id,"revisions")

  req <- build_request(endpoint = url,
                       token = gd_token())
  res <- make_request(req)
  proc_res <- process_request(res)

  rev_id <- proc_res$revisions[[1]]$id

  url <- paste0(url, "/",rev_id, "?fields=published")
  req <- build_request(endpoint = url,
                       params = list(published = "true"),
                       token = gd_token(),
                       method = "PATCH")
  res <- make_request(req, encode = "json")
  proc_res <- process_request(res)

  if (verbose){
    if(proc_res$published){
      cat(sprintf("You have successfully published '%s'.", file$name))
    } else
      cat(sprintf("Uh oh, something went wrong. '%s' was not published.", file$name))
  }

  invisible(proc_res$published)
}

#' Check if Google Drive file is published
#'
#' @param file `drive_file` object representing the file you would like to check the published status of
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return logical, whether the file is published
#' @export
gd_check_publish <- function (file, verbose = TRUE){
  if(!inherits(file, "drive_file")){
    spf("Input must be a `drive_file`. See `gd_file()`")
  }

  id <- file$id

  url <- file.path(.state$gd_base_url_files_v3, id,"revisions")

  req <- build_request(endpoint = url,
                       token = gd_token())
  res <- make_request(req)
  proc_res <- process_request(res)

  rev_id <- proc_res$revisions[[1]]$id

  url <- file.path(url,rev_id)
  req <- build_request(endpoint = url,
                       token = gd_token(),
                       params = list(fields = "published"))
  res <- make_request(req)
  proc_res <- process_request(res)

  if (verbose){
    if (proc_res$published) {
    cat(sprintf("The Google Drive file '%s' is published.", file$name))
    } else
      cat(sprintf("The Google Drive file '%s' is not published.", file$name))
  }

  invisible(proc_res$published)
}
