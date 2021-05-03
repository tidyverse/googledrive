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
#' # Create shared drives to remove in various ways
#' shared_drive_create("testdrive-01")
#' sd02 <- shared_drive_create("testdrive-02")
#' shared_drive_create("testdrive-03")
#' sd04 <- shared_drive_create("testdrive-04")
#'
#' # remove by name
#' shared_drive_rm("testdrive-01")
#' # remove by id
#' shared_drive_rm(as_id(sd02))
#' # remove by URL (or, rather, id found in URL)
#' shared_drive_rm(as_id("https://drive.google.com/drive/u/0/folders/Q5DqUk9PVA"))
#' # remove by dribble
#' shared_drive_rm(sd04)
#' }
shared_drive_rm <- function(drive = NULL) {
  shared_drive <- as_shared_drive(drive)
  if (no_file(shared_drive)) {
    drive_bullets(c(
      "!" = "No such shared drive found to delete."
    ))
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(as_id(shared_drive), delete_one_shared_drive)

  if (any(out)) {
    successes <- shared_drive[out, ]
    drive_bullets(c(
      "Shared drive{?s} deleted:{cli::qty(nrow(successes))}",
      bulletize(map_cli(successes))
    ))
  }
  # I'm not sure this ever comes up IRL?
  # Is it even possible that removal fails but there's no error?
  if (any(!out)) {
    failures <- shared_drive[!out, ]
    drive_bullets(c(
      "Shared drive{?s} NOT deleted:{cli::qty(nrow(failures))}",
      bulletize(map_cli(failures))
    ))
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
