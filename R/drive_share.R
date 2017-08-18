#' Update Google Drive file share permissions.
#'
#' #' @seealso Wraps the `permissions.update` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/permissions/update>
#'
#' @template file-plural
#' @param role Character. The role granted by this permission. Valid values are:
#' * organizer
#' * owner
#' * writer
#' * commenter
#' * reader
#' @param type Character. The type of the grantee. Valid values are:
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
drive_share <- function(file,
                        role = NULL,
                        type = NULL,
                        ...,
                        verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  if (is.null(role) || is.null(type)) {
    stop_glue("'role' and 'type' must be specified.")
  }

  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_types <- c("user", "group", "domain", "anyone")

  if (!(role %in% ok_roles)) {
    stop_glue(
      "\n'role' must be one of the following:\n",
      "  * {collapse(ok_roles, sep = ', ')}."
    )
  }

  if (!(type %in% ok_types)) {
    stop_glue(
      "\n'type' must be one of the following:\n",
      "  * {collapse(ok_types, sep = ', ')}."
    )
  }

  params <- list(...)
  params[["role"]] <- role
  params[["type"]] <- type
  params[["fields"]] <- "*"
  permissions_resource <- purrr::map(file$id,
                                     drive_share_one,
                                     params = params,
                                     verbose = verbose)
  file[["permissions_resource"]] <- NULL
  file <- tibble::add_column(file, permissions_resource = permissions_resource, .after = 1)

  out <- purrr::map_chr(permissions_resource, "type") == type
  if (verbose) {
    if (any(out)) {
      successes <- glue_data(file[out, ], "  * {name}: {id}")
      message_collapse(c(glue("Permissions updated\n  * `role` = {role}\n  * `type` = {type}\nFor files:"), successes))
    }
    if (any(!out)) {
      failures <- glue_data(file[out, ], "  * {name}: {id}")
      message_collapse(c("\nPermissions were NOT updated:", failures))
    }
  }

  invisible(file)
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

drive_show_permissions <- function(file) {
  file <- as_dribble(file)
  file <- confirm_some_files(file)
  permissions_resource <- purrr::map(file$id, show_sharing_one)
  file[["permissions_resource"]] <- NULL
  tibble::add_column(file, permissions_resource = permissions_resource, .after = 1)
}

show_permissions_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.permissions.list",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- make_request(request, encode = "json")
  process_response(response)
}
