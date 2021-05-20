#' Add a new column of Drive file information
#'
#' @description
#' `drive_reveal()` adds extra information about your Drive files that is not
#' readily available in the default [`dribble`] produced by googledrive. Why is
#' this info not always included in the default `dribble`?
#' * You don't always care about it. There is a lot of esoteric information in
#' the `drive_resource` that has little value for most users.
#' * It might be "expensive" to get this information and put it into a usable
#' form. For example, revealing a file's `"path"`, `"permissions"`, or
#' `"published"` status all require additional API calls.
#'

#' `drive_reveal()` can also **hoist** any property out of the `drive_resource`
#' list-column, when the property's name is passed as the `what` argument. The
#' resulting new column is simplified if it is easy to do so, e.g., if the
#' individual elements are all string or logical. If `what` extracts a
#' date-time, we return [`POSIXct`][DateTimeClasses]. Otherwise, you'll get a
#' list-column. If this makes you sad, consider using `tidyr::hoist()` instead.
#' It is more powerful due to a richer "plucking specification" and its `ptype`
#' and `transform` arguments. Another useful function is
#' `tidyr::unnest_wider()`.
#'
#' @template not-like-your-local-file-system
#'

#' @section File path:
#' When `what = "path"` the [`dribble`] gains a character column holding each
#' file's path. This can be *very slow* so use with caution.

#' @section Permissions:
#' When `what = "permissions"` the [`dribble`] gains a logical column `shared`
#' that indicates whether a file is shared and a new list-column
#' `permissions_resource` containing lists of
#' [Permissions resources](https://developers.google.com/drive/v3/reference/permissions#resource).
#'
#' @section Publishing:
#' When `what = "published"` the [`dribble`] gains a logical column
#' `published` that indicates whether a file is published and a new list-column
#' `revision_resource` containing lists of
#' [Revisions resources](https://developers.google.com/drive/v3/reference/revisions#resource).
#'

#' @section Parent:
#' When `what = "parent"` the [`dribble`] gains a character column `id_parent`
#' that is the file id of this item's parent folder. This information is
#' available in the `drive_resource`, but can't just be hoisted out:
#' * Google Drive used to allow files to have multiple parents, but this is no
#'   longer supported and googledrive now assumes this is impossible. However,
#'   we have seen (very old) files that still have >1 parent folder. If we see
#'   this we message about it and drop all but the first parent.
#' * The `parents` property in `drive_resource` has an "extra" layer of nesting
#'   and needs to be flattened.
#'

#' If you really want the raw `parents` property, call `drive_reveal(what =
#' "parents")`.

#' @template file-plural

#' @param what Character, describing the type of info you want to add. These
#'   values get special handling (more details below):
#'   * `path`
#'   * `permissions`
#'   * `published`
#'   * `parent`
#'

#'   You can also request any property in the `drive_resource` column by name.
#'   The request can be in `camelCase` or `snake_case`, but the new column name
#'   will always be `snake_case`. Some examples of `what`:

#'   * `mime_type` (or `mimeType`)
#'   * `trashed`
#'   * `starred`
#'   * `description`
#'   * `version`
#'   * `web_view_link` (or `webViewLink`)
#'   * `modified_time` (or `modifiedTime`)
#'   * `created_time` (or `createdTime`)
#'   * `owned_by_me` (or `ownedByMe`)
#'   * `size`
#'   * `quota_bytes_used` (or `quotaBytesUsed`)
#'
#' @template dribble-return
#'

#' @seealso To learn more about the properties present in the metadata of a
#'   Drive file (which is what's in the `drive_resource` list-column of a
#'   [`dribble`]), see the API docs:

#'   * <https://developers.google.com/drive/api/v3/reference/files#resource-representations>
#'

#' @export
#' @examplesIf drive_has_token()
#' # Get a few of your files
#' files <- drive_find(n_max = 10, trashed = NA)
#'
#' # the "special" cases that require additional API calls and can be slow
#' drive_reveal(files, "path")
#' drive_reveal(files, "permissions")
#' drive_reveal(files, "published")
#'
#' # a "special" case of digging info out of `drive_resource`, then processing
#' # a bit
#' drive_reveal(files, "parent")
#'
#' # the "simple" cases of digging info out of `drive_resource`
#' drive_reveal(files, "trashed")
#' drive_reveal(files, "mime_type")
#' drive_reveal(files, "starred")
#' drive_reveal(files, "description")
#' drive_reveal(files, "version")
#' drive_reveal(files, "web_view_link")
#' drive_reveal(files, "modified_time")
#' drive_reveal(files, "created_time")
#' drive_reveal(files, "owned_by_me")
#' drive_reveal(files, "size")
#' drive_reveal(files, "quota_bytes_used")
#'
#' # 'root' is a special file id that represents your My Drive root folder
#' drive_get(id = "root") %>%
#'   drive_reveal("path")
drive_reveal <- function(file,
                         what = c("path", "permissions", "published", "parent")) {
  stopifnot(is_string(what))
  file <- as_dribble(file)

  if (what %in% c("path", "permissions", "published", "parent")) {
    reveal <- switch(
      what,
      "path"        = drive_reveal_canonical_path,
      "permissions" = drive_reveal_permissions,
      "published"   = drive_reveal_published,
      "parent"      = drive_reveal_parent
    )
    return(reveal(file))
  }

  drive_reveal_this(file, what)
}

drive_reveal_this <- function(file, this) {
  elem_snake_case <- snake_case(this)
  is_dttm <- grepl("_time$", elem_snake_case)

  if (no_file(file)) {
    return(
      put_column(
        file,
        nm = elem_snake_case,
        val = list(),
        .after = "name"
      )
    )
  }

  out <- promote(file, elem_snake_case)

  if (is_dttm && is.character(out[[elem_snake_case]])) {
    out[[elem_snake_case]] <-as.POSIXct(
      out[[elem_snake_case]],
      format = "%Y-%m-%dT%H:%M:%OSZ",
      tz = "UTC"
    )
  }

  out
}

drive_reveal_parent <- function(file) {
  confirm_dribble(file)

  file <- drive_reveal(file, "parents")
  # due to the historical use of multiple parents, there is a gratuitous level
  # of nesting here
  file$parents <- map(file$parents, 1)

  n_parents <- lengths(file$parents)
  has_multiple_parents <- n_parents > 1
  if (any(has_multiple_parents)) {
    drive_bullets(c(
      "{sum(has_multiple_parents)} file{?s} {?has/have} >1 parent, which is a \\
       remnant of legacy Drive behaviour:",
      cli_format_dribble(file[has_multiple_parents, ]),
      "!" = "Only the first parent will be used"
    ))
  }

  file <- put_column(
    file,
    nm = "id_parent",
    val = map_chr(file$parents, 1, .default = NA),
    .after = "name"
  )
  file$parents <- NULL
  file
}
