#' Update Google Drive file share permissions.
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
#' @param display Character. The value you'd like displayed for who has share permissions.
#'   Valid values are:
#'   * id
#'   * name
#'   * type
#'   * email
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
                        display = "name",
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

  files <- purrr::map(file$id,
                      drive_share_one,
                      role = role,
                      type = type,
                      display = display,
                      ...,
                      verbose = TRUE)
  file <- do.call(rbind, files)
  invisible(file)
}

drive_share_one <- function(id, role, display, type, ..., verbose) {
  request <- generate_request(
    endpoint = "drive.permissions.create",
    params = list(
      fileId = id,
      role = role,
      type = type,
      fields = "*",
      ...
    )
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  file <- as_dribble(as_id(id))
  if (verbose) {
    if (proc_res$type == type && proc_res$role == role) {
      message_glue_data(
        proc_res,
        "\nThe permissions for file {sq(file$name)} have been updated.\n",
        "  * id: {id}\n",
        "  * type: {type}\n",
        "  * role: {role}"
      )
    } else {
      message_glue_data(file, "\nPermissions were NOT updated:\n  * '{name}'")
    }
  }
  share_tbl <- share_tbl(list(proc_res))
  add_sharing_cols(file, share_tbl, display, role)
}

drive_show_sharing <- function(file) {
  file <- as_dribble(file)
  file <- confirm_some_files(file)
  file <- purrr::map(file$id, show_sharing_one)
  do.call(rbind, file)
}

show_sharing_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.permissions.list",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  file <- as_dribble(as_id(id))
  tibble::add_column(file, sharing = list(proc_res$permissions), .after = 1)
}

## this is not currently used anywhere, but is a nice way to turn the
## icky list-col from drive_reveal(what = "sharing") into a tibble.
share_tbl <- function(x) {
  tbl <- tibble::tibble(
    id = purrr::map_chr(x, "id"),
    name = purrr::map_chr(x, "displayName", .null = NA_character_),
    type = purrr::map_chr(x, "type", .null = NA_character_),
    email = purrr::map_chr(x, "emailAddress", .null = NA_character_),
    role = purrr::map_chr(x, "role", .null = NA_character_),
    deleted = purrr::map_lgl(x, "deleted", .null = NA)
  )
  tbl$name <- ifelse(tbl$id == "anyoneWithLink", "anyone with link", tbl$name)
  tbl
}
