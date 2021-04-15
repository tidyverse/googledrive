#' Delete shared drives
#'
#' @template shared-drive-description
#'
#' @seealso Wraps the `drives.delete` endpoint:
#'   * <https://developers.google.com/drive/api/v3/reference/drives/delete>
#'
#' @template shared_drive-plural
#'
#' @return Logical vector, indicating whether the delete succeeded.
#' @export
#' @examples
#' \dontrun{
#' ## Create shared drives to remove in various ways
#' shared_drive_create("testdrive-01")
#' sd02 <- shared_drive_create("testdrive-02")
#' shared_drive_create("testdrive-03")
#' sd04 <- shared_drive_create("testdrive-04")
#'
#' ## remove by name
#' shared_drive_rm("testdrive-01")
#' ## remove by id
#' shared_drive_rm(as_id(sd02))
#' ## remove by URL (or, rather, id found in URL)
#' shared_drive_rm(as_id("https://drive.google.com/drive/u/0/folders/Q5DqUk9PVA"))
#' ## remove by dribble
#' shared_drive_rm(sd04)
#' }
shared_drive_rm <- function(drive = NULL) {
  shared_drive <- as_shared_drive(drive)
  if (no_file(shared_drive)) {
    message_glue("No such shared drive(s) found to delete.")
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(as_id(shared_drive), delete_one_shared_drive)

  if (any(out)) {
    successes <- glue_data(shared_drive[out, ], "  * {name}: {id}")
    message_collapse(c("Shared drives deleted:", successes))
  }
  if (any(!out)) {
    failures <- glue_data(shared_drive[!out, ], "  * {name}: {id}")
    message_collapse(c("Shared drives NOT deleted:", failures))
  }
  invisible(out)
}

delete_one_shared_drive <- function(id) {
  request <- request_generate(
    endpoint = "drive.drives.delete",
    params = list(driveId = id)
  )
  response <- request_make(request)
  gargle::response_process(response)
}
