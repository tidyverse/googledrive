#' Update Google Drive file share permissions
#'
#' @param file `gfile` object representing the file you would like to
#'   delete
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
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return `gfile` object updated with new sharing information
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

  file <- drive_file(file$id)
  invisible(file)
}

build_drive_share <- function(file = NULL,
                              role = NULL,
                              type = NULL,
                              ...) {
  if (!inherits(file, "gfile")) {
    spf("Input must be a `gfile`. See `drive_file()`")
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
  process_request(response, content = FALSE)

  if (verbose == TRUE) {
    if (response$status_code == 200L) {
      message(sprintf("The permissions for file '%s' have been updated", file$name))
    } else {
      message(
        sprintf(
          "Zoinks! Something went wrong, '%s' permissions were not updated.",
          file$name
        )
      )
    }
  }
}
