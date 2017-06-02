#' Open Google Drive file in browser to edit.
#'
#' @template file
#'
#' @template dribble-return
#' @export
drive_browse <- function(file){
  if (!interactive()) return(invisible(file))

  file <- as_dribble(file)

  if (nrow(file) != 1) {
    spf("Input `file` must be a `dribble` with 1 row.")
  }

  link <- drive_share_link(file = file)
  utils::browseURL(link)
  return(invisible(file))
}
