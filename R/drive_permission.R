#' Work with Drive file permissions
#'
#' @description
#' A family of functions for working with Drive file permissions.
#' * `drive_permission_list()`: Lists the permissions associated with each
#'   input file. Useful for getting a `permission_id`, if you need to
#'   delete a permission *not implemented yet*.
#' * *More functions will be added, especially, `drive_permission_delete()`.*
#' * `drive_share()` has been in googledrive for a long time and, morally, it's
#'   `drive_permission_create().` *We will probably add
#'   `drive_permission_create()` and make `drive_share()` an alias.*
#'
#' @seealso
#' Overview of the `permissions` API:
#' * <https://developers.google.com/drive/api/v3/reference/permissions>
#'
#' Drive roles and permissions are described here:
#' * <https://developers.google.com/drive/api/v3/ref-roles>
#'
#' @template file-plural
#'
#' @return
#' * `drive_permission_list()`: A tibble with one row per permission, per file.
#'   The `name` and `id` columns identify the associated file. The remaining
#'   columns are determined dynamically from the permission data returned by
#'   the Drive API. This should always include `permission_id`, as well as the
#'   permission `type` and `role`.
#'
#' @export
#' @examplesIf drive_has_token()
#' # Create a file to share
#' file <- drive_example_remote("chicken_doc") %>%
#'   drive_cp(name = "chicken-permissions.txt")
#'
#' # View the initial permissions
#' drive_permission_list(file)
#'
#' # Let a specific person comment
#' file <- file %>%
#'   drive_share(
#'     role = "commenter",
#'     type = "user",
#'     emailAddress = "susan@example.com"
#'   )
#'
#' # Allow "anyone with the link" to read the file
#' drive_share_anyone(file)
#'
#' # View the permissions again
#' drive_permission_list(file)
#'
#' # Clean up
#' drive_rm(file)
drive_permission_list <- function(file, ...) {
  file <- as_dribble(file)
  file <- confirm_some_files(file)

  dribble_plus_perm_res <- drive_reveal_permissions(file)

  # If I could use tidyr+dplyr, this would basically boil down to:
  # dribble_plus_perm_res %>%
  #   hoist(permissions_resource, "permissions") %>%
  #   select(!ends_with("_resource")) %>%
  #   unnest_longer(permissions) %>%
  #   unnest_wider(permissions, names_sep = "_") %>%
  #   some select()-y-stuff
  # Alas, I cannot use tidyr+dplyr here.

  dribble_plus_perm_res$permission_list <-
    map(dribble_plus_perm_res$permissions_resource, "permissions")
  vec_rbind(!!!purrr::pmap(dribble_plus_perm_res, rectangle_one_permission))
}

rectangle_one_permission <- function(name = NA_character_,
                                     id = as_id(NA_character_),
                                     permission_list, ...) {
  # some files are visible to the user, but user is not allowed to list
  # permissions
  if (is.null(permission_list)) {
    return(tibble::tibble(name = name, id = id, permission_id = "")[0,])
  }

  # In googlesheets4, I would formally ingest the relevant schemas:
  # drive#permissionList and drive#permission
  # and write an as_tibble() method for it/them.
  # Alas, googledrive doesn't use the schema machinery (yet?).
  #
  # So I will rectangle this "by hand", for now.

  # poor woman's tidyr::unnest_wider() -----------------------------------------
  nms <- permission_list %>%
    map(names) %>%
    purrr::reduce(union) %>%
    set_names()
  out <- map(nms, ~ map(permission_list, .x)) %>%
    map(simplify_col) %>%
    as_tibble()

  # fixups specific to permissionList ------------------------------------------

  # boring / constant
  out$kind <- NULL
  # item is deprecated, but is still showing up
  out$teamDrivePermissionDetails <- NULL

  names(out) <- snake_case(names(out))

  # avoid name collision with file `id`
  id_col <- which(names(out) == "id")
  names(out)[id_col] <- "permission_id"

  # move any list-column(s) to the end
  is_list_col <- map_lgl(out, is_list)
  out <- out[c(which(!is_list_col), which(is_list_col))]

  out %>%
    tibble::add_column(name = name, id = id, .before = 1)
}
