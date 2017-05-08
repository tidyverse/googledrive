#' Delete file from Google Drive
#'
#' @param file `drive_file` object representing the file you would like to delete
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return logical, indicating whether the delete succeeded
#' @export
#'
gd_delete <- function(file = NULL, verbose = TRUE){

  request <- build_gd_delete(file = file)
  response <- make_request(request)
  process_gd_delete(response = response, file = file, verbose = verbose)

}

build_gd_delete <- function(file = NULL, token = gd_token()) {
  if(!inherits(file, "drive_file")){
    spf("Input must be a `drive_file`. See `gd_file()`")
  }

  id <- file$id
  url <- file.path(.state$gd_base_url_files_v3, id)

  build_request(endpoint = url,
                token = token,
                method = "DELETE")
}

process_gd_delete <- function(response = NULL, file = NULL, verbose = TRUE){
  process_request(response, content = FALSE)

  if (verbose==TRUE){
    if (response$status_code == 204L){
      message(sprintf("The file '%s' has been deleted from your Google Drive", file$name))
    } else {
      message(sprintf("Zoinks! Something went wrong, '%s' was not deleted.", file$name))
    }
  }

  if(response$status_code == 204L) invisible(TRUE) else invisible(FALSE)
}
