#' Create a new shared drive
#'
#' @template shared-drive-description
#'
#' @seealso Wraps the `drives.create` endpoint:
#'   * <https://developers.google.com/drive/api/v3/reference/drives/create>
#'
#' @param name Character. Name of the new shared drive. Must be non-empty and not
#'   entirely whitespace.
#'
#' @eval return_dribble("shared drive")
#' @export
#' @examples
#' \dontrun{
#' shared_drive_create("my-awesome-shared-drive")
#'
#' # clean up
#' shared_drive_rm("my-awesome-shared-drive")
#' }
shared_drive_create <- function(name) {
  stopifnot(is_string(name), isTRUE(nzchar(name)))
  request <- request_generate(
    "drive.drives.create",
    params = list(
      requestId = uuid::UUIDgenerate(),
      name = name,
      fields = "*"
    )
  )
  response <- request_make(request)
  out <- as_dribble(list(gargle::response_process(response)))

  drive_bullets(c("Shared drive created:", bulletize(map_cli(out))))
  invisible(out)
}
