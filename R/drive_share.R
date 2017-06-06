#' Update Google Drive file share permissions.
#'
#' @template file
#' @param role The role granted by this permission. Valid values are:
#' * organizer
#' * owner
#' * writer
#' * commenter
#' * reader
#' @param type The type of the grantee. Valid values are:
#' * user
#' * group
#' * domain
#' * anyone
#' @param ... Name-value pairs to add to the API request body.
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_share <- function(file = NULL, role = NULL, type = NULL, ..., verbose = TRUE) {

  file <- confirm_single_file(as_dribble(file))

  if (is.null(role) || is.null(type)) {
    spf("`role` and `type` must be specified.")
  }

  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_types <- c("user", "group", "domain", "anyone")

  if (!(role %in% ok_roles)) {
    spf("`role` must be one of the following: %s.",
        paste(ok_roles, collapse = ", "))
  }

  if (!(type %in% ok_types)) {
    spf("`type` must be one of the following: %s.",
        paste(ok_types, collapse = ", "))
  }

  request <- build_request(
    endpoint = "drive.permissions.create",
    params = list(
      fileId = file$id,
      role = role,
      type = type,
      ...
    )
  )
  response <- make_request(request, encode = "json")
  proc_req <- process_response(response)

  if (verbose) {
    if (proc_req$type == type && proc_req$role == role) {
      message(
        glue::glue_data(
          proc_req,
          "The permissions for file '{file$name}' have been updated.\n id: {id}\n type: {type}\n role: {role}"
        )
      )
    } else {
      message(
        glue::glue_data(
          file,
          "Zoinks! Something went wrong, '{name}' permissions were not updated."
        )
      )
    }
  }
  file <- as_dribble(drive_id(file$id))
  invisible(file)
}
