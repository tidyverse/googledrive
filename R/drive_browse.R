#' Visit Google Drive file in browser.
#'
#' @template file
#'
#' @template dribble-return
#' @export
drive_browse <- function(file) {
  if (!interactive()) return(invisible(file))

  ## TO DO: do we really want to require a 1 row dribble?
  ## another options is to browse first n where n is low, maybe even 1
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  link <- drive_share_link(file = file)
  utils::browseURL(link)
  return(invisible(file))
}
