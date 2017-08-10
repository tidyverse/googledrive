#' Update Google Drive file share permissions.
#'
#' @template file
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
    stop("`role` and `type` must be specified.", call. = FALSE)
  }

  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_types <- c("user", "group", "domain", "anyone")

  if (!(role %in% ok_roles)) {
    stop_glue(
      "\n`role` must be one of the following:\n",
      "  * {collapse(ok_roles, sep = ', ')}."
    )
  }

  if (!(type %in% ok_types)) {
    stop_glue(
      "\n`type` must be one of the following:\n",
      "  * {collapse(ok_types, sep = ', ')}."
    )
  }

  file <- split(file, 1:nrow(file))
  files <- purrr::map(file,
                      drive_share_one,
                      role = role,
                      type = type,
                      display = display,
                      ...,
                      verbose = TRUE)
  file <- do.call(rbind, files)
  invisible(file)
}

drive_share_one <- function(file, role, display, type, ..., verbose) {
  request <- generate_request(
    endpoint = "drive.permissions.create",
    params = list(
      fileId = file$id,
      role = role,
      type = type,
      fields = "*",
      ...
    )
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

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
  file <- as_dribble(as_id(file))
  share_tbl <- share_tbl(list(proc_res))
  add_sharing_cols(file, share_tbl, display, role)
}

#' Add sharing column(s) to your dribble
#'
#' @template file
#' @param display Character. The value you'd like displayed for who has share permissions.
#'   Defaults to "name". Valid values are:
#'   * id
#'   * name
#'   * type
#'   * email
#' @param role Character. The role(s) you'd like to see the permissions for. A column with
#'   permission information based on the `display` value chosen will be added for each role.
#'   Defaults to "owner". Valid values are any combination of:
#'   * organizer
#'   * owner
#'   * writer
#'   * commenter
#'   * reader
#' @template dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## Upload a file to view sharing permissions
#' file <- drive_upload(
#'    system.file("DESCRIPTION"),
#'    type = "document"
#'    )
#'
#' ## Add default sharing information (the name of the owner)
#' drive_show_sharing(file)
#'
#' ## Add sharing information (name) for those with role "owner" and "commenter"
#' drive_show_sharing(file, role = c("owner", "commenter"))
#'
#' ## Add sharing information (email address) for all "readers"
#' drive_show_sharing(file, display = "email", role = "reader")
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_show_sharing <- function(file, display = "name", role = "owner") {
  ok_roles <- c("organizer", "owner", "writer", "commenter", "reader")
  ok_display <- c("id", "name", "type", "email")
  if (!all(role %in% ok_roles)) {
    stop_glue(
      "\n`role` may only include the following:\n",
      "  * {collapse(ok_roles, sep = ', ')}."
    )
  }
  if (!(display %in% ok_display)) {
    stop_glue(
      "\n`display` must be one of the following:\n",
      "  * {collapse(ok_display, sep = ', ')}."
    )
  }
  file <- as_dribble(file)
  file <- confirm_some_files(file)
  file <- split(file, 1:nrow(file))
  files <- purrr::map(file, show_sharing_one, display = display, role = role)
  do.call(rbind, files)
}

show_sharing_one <- function(file, display, role) {
  request <- generate_request(
    endpoint = "drive.permissions.list",
    params = list(
      fileId = file$id,
      fields = "*"
    )
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)
  share_tbl <- share_tbl(proc_res$permissions)
  file <- add_sharing_cols(file, share_tbl, display, role)
}

add_sharing_cols <- function(d, x, display, role) {
  ## there must be a better way to do this
  for (i in role) {
    display_col <- collapse(x[[display]][x$role == i], sep = ",")
    if (length(display_col) == 0L) {
      d[[i]] <- NA_character_
    } else d[[i]] <- display_col
    ## reorder
    d <- d[, c(1, ncol(d), 2:(ncol(d) - 1))]
  }
  d
}

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
