#' Delete file from Google Drive
#'
#' @param file \code{drive_file} object representing the file you would like to delete
#' @param verbose logical, indicating whether to print informative messages (default \code{TRUE})
#'
#' @return logical, indicating whether the delete succeeded
#' @export
#'
gd_delete <- function(file, verbose = TRUE){
  if(!inherits(file, "drive_file")){
    spf("Input must be a `drive_file`. See `gd_file()`")
  }

  id <- file$id
  url <- file.path(.state$gd_base_url_files_v3, id)

  req <- build_request(endpoint = url,
                       token = gd_token(),
                       method = "DELETE")
  res <- make_request(req)
  process_request(res, content = FALSE)

  if (verbose==TRUE){
    if (res$status_code == 204L){
      message(sprintf("The file '%s' has been deleted from your Google Drive", file$name))
    } else {
      message(sprintf("Zoinks! Something went wrong, '%s' was not deleted.", file$name))
    }
  }

  if(res$status_code == 204L) invisible(TRUE) else invisible(FALSE)

}
