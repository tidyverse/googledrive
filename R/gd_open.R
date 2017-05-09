#' Open Google Drive file in browser to edit
#'
#' @param file `drive_file` object for the file you would like to edit
#'
#' @return NULL
#' @export
gd_open <- function(file){
  if(!inherits(file, "drive_file")){
    spf("Input `file` must be a `drive_file`. See `gd_file()`")
  }
  link <- gd_share_link(file = file)
  browseURL(link)
}
