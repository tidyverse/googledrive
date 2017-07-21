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
#' @examples
#' \dontrun{
#' ## Upload a file to share
#' file <- drive_upload(
#'    system.file("DESCRIPTION"),
#'    type = "document"
#'    )
#'
#' ## Share file
#' file %>%
#'   drive_share(role = "reader", type = "anyone")
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_share <- function(file, role = NULL, type = NULL, ..., verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_single_file(file)

  if (is.null(role) || is.null(type)) {
    stop("`role` and `type` must be specified.", call. = FALSE)
  }

  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_types <- c("user", "group", "domain", "anyone")

  if (!(role %in% ok_roles)) {
    stop_glue(
      "\n`role` must be one of the following:\n",
      "  * {glue::collapse(ok_roles, sep = ', ')}."
    )
  }

  if (!(type %in% ok_types)) {
    stop_glue(
      "\n`type` must be one of the following:\n",
      "  * {glue::collapse(ok_types, sep = ', ')}."
    )
  }

  request <- generate_request(
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
      message_glue_data(
        proc_req,
        "\nThe permissions for file {sq(file$name)} have been updated.\n",
        "  * id: {id}\n",
        "  * type: {type}\n",
        "  * role: {role}"
      )
    } else {
      message_glue_data(file, "\nPermissions were NOT updated:\n  * '{name}'")
    }
  }
  file <- as_dribble(as_id(file$id))
  invisible(file)
}
