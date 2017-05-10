#' Open Google Drive file in browser to edit
#'
#' @param file `drive_file` object for the file you would like to edit
#'
#' @return `drive_file` object
#' @export
gd_browse <- function(file){
  if (!interactive()) return(invisible(file))
  if(!inherits(file, "drive_file")){
    spf("Input `file` must be a `drive_file`. See `gd_file()`")
  }

  link <- gd_share_link(file = file)
  utils::browseURL(link)
  return(invisible(file))
}
