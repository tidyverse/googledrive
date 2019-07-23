#' Create a Drive folder
#'
#' Creates a new Drive folder. To update the metadata of an existing Drive file,
#' including a folder, use [drive_update()].
#'
#' @seealso Wraps the `files.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/create>
#'
#' @param name Name for the new folder or, optionally, a path that specifies
#'   an existing parent folder, as well as the new name.
#' @inheritParams drive_create
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Create folder named 'ghi', then another below named it 'jkl' and star it
#' ghi <- drive_mkdir("ghi")
#' jkl <- drive_mkdir("ghi/jkl", starred = TRUE)
#'
#' ## is 'jkl' really starred? YES
#' purrr::pluck(jkl, "drive_resource", 1, "starred")
#'
#' ## Another way to create folder 'mno' in folder 'ghi'
#' drive_mkdir("mno", parent = "ghi")
#'
#' ## Yet another way to create a folder named 'pqr' in folder 'ghi',
#' ## this time with parent folder stored in a dribble,
#' ## and setting the new folder's description
#' pqr <- drive_mkdir("pqr", parent = ghi, description = "I am a folder")
#'
#' ## Did we really set the description? YES
#' purrr::pluck(pqr, "drive_resource", 1, "description")
#'
#' ## clean up
#' drive_rm(ghi)
#' }
drive_mkdir <- function(name,
                        parent = NULL,
                        ...,
                        verbose = TRUE) {
  drive_create(
    name = name,
    parent = parent,
    type = "application/vnd.google-apps.folder",
    ...,
    verbose = verbose
  )
}
