#' Example using dribbles
#' @param file input
#'
#' @export
drive_hello <- function(file) {
  drib <- as.dribble(file)
  ## this silly second pass is necessary because, eg, drive_path() doesn't
  ## actually return a dribble yet! but you get the idea, yes?
  drib <- as.dribble(drive_id(drib$id))
  message(
    glue::glue_data(
      drib,
      "Hi, my name is {sq(name)}!",
      "My fileId starts with {substr(id, 1, 7)}",
      .sep = "\n"
    )
  )
  invisible(drib)
}
