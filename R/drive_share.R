#' Share files
#'
#' Grant individuals or other groups access to files, including permission to
#' read, comment, or edit. The returned [`dribble`] will have extra columns,
#' `shared` and `permissions_resource`. Read more in [drive_reveal()].
#'
#' @seealso Wraps the `permissions.update` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/permissions/create>
#'
#' @template file-plural
#' @param role Character. The role to grant. Must be one of:
#'   * organizer (applies only to Team Drives)
#'   * owner
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
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Upload a file to share
#' file <- drive_upload(
#'    system.file("DESCRIPTION"),
#'    name = "DESC-share-ex",
#'    type = "document"
#' )
#'
#' ## Let a specific person comment
#' file <- file %>%
#'   drive_share(
#'     role = "commenter",
#'     type = "user",
#'     emailAddress = "susan@example.com"
#' )
#'
#' ## Let a different specific person edit and customize the email notification
#' file <- file %>%
#'   drive_share(
#'     role = "writer",
#'     type = "user",
#'     emailAddress = "carol@example.com",
#'     emailMessage = "Would appreciate your feedback on this!"
#' )
#'
#' ## Let anyone read the file
#' file <- file %>%
#'   drive_share(role = "reader", type = "anyone")
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_share <- function(file,
                        role = c("reader", "commenter", "writer",
                                 "owner", "organizer"),
                        type = c("user", "group", "domain", "anyone"),
                        ...,
                        verbose = TRUE) {
  role <- match.arg(role)
  type <- match.arg(type)
  file <- as_dribble(file)
  file <- confirm_some_files(file)

  params <- toCamel(list(...))
  params[["role"]] <- role
  params[["type"]] <- type
  params[["fields"]] <- "*"
  ## this resource pertains only to the affected permission
  permission_out <- purrr::map(
    file$id,
    drive_share_one,
    params = params,
    verbose = verbose
  )

  if (verbose) {
    ok <- purrr::map_chr(permission_out, "type") == type
    if (any(ok)) {
      successes <- glue_data(file[ok, ], "  * {name}: {id}")
      message_collapse(c(
        "Permissions updated",
        glue("  * role = {role}"),
        glue("  * type = {type}"),
        "For files:",
        successes
      ))
    }
    if (any(!ok)) {
      failures <- glue_data(file[ok, ], "  * {name}: {id}")
      message_collapse(c("Permissions were NOT updated:", failures))
    }
  }

  ## refresh drive_resource, get full permissions_resource
  out <- drive_get(as_id(file))
  invisible(drive_reveal(out, "permissions"))
}

drive_share_one <- function(id, params, verbose) {
  params[["fileId"]] <- id
  request <- generate_request(
    endpoint = "drive.permissions.create",
    params = params
  )
  response <- make_request(request, encode = "json")
  process_response(response)
}

drive_reveal_permissions <- function(file) {
  confirm_dribble(file)
  permissions_resource <- purrr::map(file$id, list_permissions_one)
  ## can't use promote() here (yet) because Team Drive files don't have
  ## `shared` and their NULLs would force `shared` to be a list-column
  file <- put_column(
    file,
    nm = "shared",
    val = purrr::map_lgl(file$drive_resource, "shared", .default = NA),
    .after = "name"
  )
  put_column(
    file,
    nm = "permissions_resource",
    val = permissions_resource
  )
}

list_permissions_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.permissions.list",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  ## TO DO: we aren't dealing with the fact that this endpoint is paginated
  ## for Team Drives
  response <- make_request(request, encode = "json")
  ## if capabilities/canReadRevisions (present in File resource) is not true,
  ## user will get a 403 "insufficientFilePermissions" here
  if (httr::status_code(response) == 403) {
    return(NULL)
  }
  process_response(response)
}
