#' Get Drive files by id
#'
#' Warning: the name of this function is likely to change.
#'
#' @param id Character, a Drive file id, such as you might see in the URL when
#'   visiting a file on Google Drive.
#'
#' @return dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' drive_get("abcdefgeh12345678")
#' }
drive_get <- function(id) {
  stopifnot(is.character(id), length(id) == 1)

  request <- build_request(
    endpoint = "drive.files.get",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- make_request(request)
  proc_res <- process_response(response)

  as_dribble(list(proc_res))
}
