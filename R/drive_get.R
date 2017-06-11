#' Get Drive files by id
#'
#' Warning: the name of this function is likely to change.
#'
#' @param id Character vector of Drive file ids, such as you might see in the
#'   URL when visiting a file on Google Drive.
#'
#' @return dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' drive_get("abcdefgeh123456789")
#'
#' drive_get(c("abcdefgh123456789", "jklmnopq123456789"))
#'
#' ## the id "root" is an alias for your root folder on My Drive
#' drive_get("root")
#' }
drive_get <- function(id) {
  stopifnot(is.character(id))
  if (length(id) < 1) return(dribble())
  ## when id = "", drive.files.get actually becomes a call to drive.files.list
  ## and, therefore, returns 100 files by default
  stopifnot(all(nzchar(id, keepNA = TRUE)))
  as_dribble(purrr::map(id, get_one))
}

get_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.files.get",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- make_request(request)
  process_response(response)
}
