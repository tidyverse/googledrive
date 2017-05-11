#' Open Google Drive file in browser to edit
#'
#' @param file `gfile` object for the file you would like to edit
#'
#' @return `gfile` object
#' @export
drive_browse <- function(file){
  if (!interactive()) return(invisible(file))
  if(!inherits(file, "gfile")){
    spf("Input `file` must be a `gfile`. See `drive_file()`")
  }

  link <- drive_share_link(file = file)
  utils::browseURL(link)
  return(invisible(file))
}
