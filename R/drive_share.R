#' Share Drive files
#'
#' @description
#' Grant individuals or other groups access to files, including permission to
#' read, comment, or edit. The returned [`dribble`] will have extra columns,
#' `shared` and `permissions_resource`. Read more in [drive_reveal()].
#'
#' `drive_share_anyone()` is a convenience wrapper for a common special case:
#' "make this `file` readable by 'anyone with a link'".
#'
#' @seealso
#' Wraps the `permissions.create` endpoint:
#' * <https://developers.google.com/drive/api/v3/reference/permissions/create>
#'
#' Drive roles and permissions are described here:
#' * <https://developers.google.com/drive/api/v3/ref-roles>
#'
#' @template file-plural
#' @param role Character. The role to grant. Must be one of:
#'   * owner (not allowed in shared drives)
#'   * organizer (applies to shared drives)
#'   * fileOrganizer (applies to shared drives)
#'   * writer
#'   * commenter
#'   * reader
#' @param type Character. Describes the grantee. Must be one of:
#'   * user
#'   * group
#'   * domain
#'   * anyone
#' @param ... Name-value pairs to add to the API request. This is where you
#'   provide additional information, such as the `emailAddress` (when grantee
#'   `type` is `"group"` or `"user"`) or the `domain` (when grantee type is
#'   `"domain"`). Read the API docs linked below for more details.
#' @template verbose
#'
#' @eval return_dribble(extras = "There will be extra columns, `shared` and
#'   `permissions_resource`.")
#' @export
#' @examplesIf drive_has_token()
#' # Upload a file to share
#' file <- drive_upload(
#'    drive_example("chicken.txt"),
#'    name = "chicken-share.txt",
#'    type = "document"
#' )
#'
#' # Let a specific person comment
#' file <- file %>%
#'   drive_share(
#'     role = "commenter",
#'     type = "user",
#'     emailAddress = "susan@example.com"
#' )
#'
#' # Let a different specific person edit and customize the email notification
#' file <- file %>%
#'   drive_share(
#'     role = "writer",
#'     type = "user",
#'     emailAddress = "carol@example.com",
#'     emailMessage = "Would appreciate your feedback on this!"
#'   )
#'
#' # Let anyone read the file
#' file <- file %>%
#'   drive_share(role = "reader", type = "anyone")
#' # Single-purpose wrapper function for this
#' drive_share_anyone(file)
#'
#' # Clean up
#' drive_rm(file)
drive_share <- function(file,
                        role = c(
                          "reader", "commenter", "writer",
                          "fileOrganizer", "owner", "organizer"
                        ),
                        type = c("user", "group", "domain", "anyone"),
                        ...,
                        verbose = deprecated()) {
  warn_for_verbose(verbose)

  role <- match.arg(role)
  type <- match.arg(type)
  file <- as_dribble(file)
  file <- confirm_some_files(file)

  params <- toCamel(list2(...))
  params[["role"]] <- role
  params[["type"]] <- type
  params[["fields"]] <- "*"
  ## this resource pertains only to the affected permission
  permission_out <- map(
    file$id,
    drive_share_one,
    params = params
  )

  ok <- map_chr(permission_out, "type") == type
  if (any(ok)) {
    successes <- file[ok, ]
    drive_bullets(c(
      "Permissions updated:",
      "*" = "role = {role}",
      "*" = "type = {type}",
      "For file{?s}:{cli::qty(nrow(successes))}",
      bulletize(gargle_map_cli(successes))
    ))
  }
  # I'm not sure this ever comes up IRL?
  # Is it even possible that permission update fails but there's no error?
  if (any(!ok)) {
    failures <- file[!ok, ]
    drive_bullets(c(
      "Permissions were NOT updated for file{?s}:{cli::qty(nrow(failures))}",
      bulletize(gargle_map_cli(failures))
    ))
  }

  ## refresh drive_resource, get full permissions_resource
  out <- drive_get(as_id(file))
  invisible(drive_reveal(out, "permissions"))
}

#' @rdname drive_share
#' @export
drive_share_anyone <- function(file, verbose = deprecated()) {
  warn_for_verbose(verbose)
  drive_share(file = file, role = "reader", type = "anyone")
}

drive_share_one <- function(id, params) {
  params[["fileId"]] <- id
  request <- request_generate(
    endpoint = "drive.permissions.create",
    params = params
  )
  response <- request_make(request)
  gargle::response_process(response)
}

drive_reveal_permissions <- function(file) {
  confirm_dribble(file)
  permissions_resource <- map(file$id, list_permissions_one)
  # TODO: revisit this in light of Team Drives --> shared drives
  ## can't use promote() here (yet) because Team Drive files don't have
  ## `shared` and their NULLs would force `shared` to be a list-column
  file <- put_column(
    file,
    nm = "shared",
    val = map_lgl(file$drive_resource, "shared", .default = NA),
    .after = "name"
  )
  put_column(
    file,
    nm = "permissions_resource",
    val = permissions_resource
  )
}

list_permissions_one <- function(id) {
  request <- request_generate(
    endpoint = "drive.permissions.list",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  # TODO: is this still a problem for shared drives? probably
  # TO DO: we aren't dealing with the fact that this endpoint is paginated
  # for Team Drives
  response <- request_make(request)
  # if capabilities/canReadRevisions (present in File resource) is not true,
  # user will get a 403 "insufficientFilePermissions" here
  if (httr::status_code(response) == 403) {
    return(NULL)
  }
  gargle::response_process(response)
}
