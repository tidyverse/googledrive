#' Open Google Drive file in browser to edit
#'
#' @param file `dribble` for the file you would like to edit
#'
#' @return `dribble`
#' @export
drive_browse <- function(file){
  if (!interactive()) return(invisible(file))

  file <- as.dribble(file)

  if (!inherits(file, "dribble") || nrow(file) != 1) {
    spf("Input `file` must be a `dribble` with 1 row.")
  }

  link <- drive_share_link(file = file)
  utils::browseURL(link)
  return(invisible(file))
}
