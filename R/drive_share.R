#' Update Google Drive file share permissions
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
#' @param ... name-value pairs to add to the API request body
#' @template verbose
#'
#' @template dribble
#' @export
drive_share <- function(file = NULL,
                        role = NULL,
                        type = NULL,
                        ...,
                        verbose = TRUE) {
  request <- build_drive_share(
    file = file,
    role = role,
    type = type,
    ...
  )
  response <- make_request(request, encode = "json")
  process_drive_share(response = response,
                      file = file,
                      verbose = verbose)

  file <- drive_get(file$id)
  invisible(file)
}

build_drive_share <- function(file = NULL,
                              role = NULL,
                              type = NULL,
                              ...) {
  if (inherits(file, "drive_id")) {
    file <- drive_get(file)
  }
  if (!inherits(file, "dribble") || nrow(file) != 1) {
    spf("Input `file` must be a `dribble` with 1 row.")
  }

  if (is.null(role) || is.null(type)) {
    spf("Role and type must be specified.")
  }

  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_types <- c("user", "group", "domain", "anyone")

  if (!(role %in% ok_roles)) {
    spf("Role must be one of the following: %s.",
        paste(ok_roles, collapse = ", "))
  }

  if (!(type %in% ok_types)) {
    spf("Role must be one of the following: %s.",
        paste(ok_types, collapse = ", "))
  }

  build_request(
    endpoint = "drive.permissions.create",
    params = list(
      fileId = file$id,
      role = role,
      type = type,
      ...
    )
  )
}

process_drive_share <- function(response = NULL,
                                file = NULL,
                                verbose = TRUE) {

  httr::stop_for_status(response)

  if (verbose == TRUE) {
    if (response$status_code == 200L) {
      message(
        glue::glue_data(
          file,
          "The permissions for file '{name}' have been updated"
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
}
