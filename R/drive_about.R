#' Get info on Drive capabilities
#'
#' Gets information about the user, the user's Drive, and system capabilities.
#' This function mostly exists to power [drive_user()], which extracts the most
#' useful information (the information on current user) and prints it nicely.
#'
#' @seealso Wraps the `about.get` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/about/get>
#'
#' @return A list representation of a Drive
#'   [about resource](https://developers.google.com/drive/v3/reference/about#resource)
#' @export
#'
#' @examples
#' \dontrun{
#' drive_about()
#'
#' ## explore the names of available Team Drive themes
#' about <- drive_about()
#' about[["teamDriveThemes"]] %>%
#'   purrr::map_chr("id")
#' }
drive_about <- function() {
  request <- request_generate(
    endpoint = "drive.about.get",
    params = list(fields = "*")
  )
  response <- request_make(request)
  gargle::response_process(response)
}
