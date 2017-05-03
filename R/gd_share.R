#' Update Google Drive file share permissions
#'
#' @param file `drive_file` object representing the file you would like to delete
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
#' @param email The email address of the user or group to which this permission refers.
#' @param message A custom message to include in the notification email.
#' @param ... name-value pairs to add to the API request body
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return logical, indicating whether the permissions update succeeded
#' @export
gd_share <- function(file, role = NULL, type = NULL, email = NULL, message = NULL, ..., verbose = TRUE){

  if (!inherits(file, "drive_file")) {
    spf("Input must be a `drive_file`. See `gd_file()`")
  }

  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_types <- c("user","group","domain","anyone")

  if (!is.null(role)) if (!(role %in% ok_roles)){
    spf("Role must be one of the following: %s.",paste(ok_roles, collapse = ", "))
  }

  if (!is.null(type)) if (!(type %in% ok_types)){
    spf("Role must be one of the following: %s.",paste(ok_types, collapse = ", "))
  }

  id <- file$id

  body <- list(role = role,
               type = type,
               emailAddress = email,...)

  url <- file.path(.state$gd_base_url_files_v3, id, "permissions")

  if (!is.null(message)) {
    message <- gsub(" ", "%20", message)
    url <- paste0(url,"?emailMessage=", message)
  }

  req <- build_request(endpoint = url,
                       token = gd_token(),
                       params = body,
                       method = "POST")

  res <- make_request(req, encode = 'json')
  process_request(res, content = FALSE)

  if (verbose==TRUE){
    if (res$status_code == 200L){
      message(sprintf("The permissions for file '%s' have been updated", file$name))
    } else {
      message(sprintf("Zoinks! Something went wrong, '%s' permissions were not updated.", file$name))
    }
  }

  if(res$status_code == 200L) invisible(TRUE) else invisible(FALSE)
}
