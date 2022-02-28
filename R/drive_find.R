#' Find files on Google Drive
#'
#' This is the closest googledrive function to what you can do at
#' <https://drive.google.com>: by default, you just get a listing of your files.
#' You can also search in various ways, e.g., filter by file type or ownership
#' or work with [shared drives][shared_drives]. This is a very powerful
#' function. Together with the more specific [drive_get()], this is the main way
#' to identify files to target for downstream work. If you know you want to
#' search within a specific folder or shared drive, use [drive_ls()].

#' @section File type:
#'
#'   The `type` argument is pre-processed with [drive_mime_type()], so you can
#'   use a few shortcuts and file extensions, in addition to full-blown MIME
#'   types. googledrive forms a search clause to pass to `q`.

#' @section Search parameters:
#'
#' Do advanced search on file properties by providing search clauses to the
#' `q` parameter that is passed to the API via `...`. Multiple `q` clauses or
#' vector-valued `q` are combined via 'and'.

#' @section Trash:
#'
#'   By default, `drive_find()` sets `trashed = FALSE` and does not include
#'   files in the trash. Literally, it adds `q = "trashed = false"` to the
#'   query. To search *only* the trash, set `trashed = TRUE`. To see files
#'   regardless of trash status, set `trashed = NA`, which adds
#'   `q = "(trashed = true or trashed = false)"` to the query.

#' @section Sort order:
#'
#'   By default, `drive_find()` sends `orderBy = "recency desc"`, so the top
#'   files in your result have high "recency" (whatever that means). To suppress
#'   sending `orderBy` at all, do `drive_find(orderBy = NULL)`. The `orderBy`
#'   parameter accepts sort keys in addition to `recency`, which are documented
#'   in the [`files.list` endpoint](https://developers.google.com/drive/api/v3/reference/files/list).
#'   googledrive translates a snake_case specification of `order_by` into the
#'   lowerCamel form, `orderBy`.

#' @section Shared drives and domains:
#'
#'   If you work with shared drives and/or Google Workspace, you can apply your
#'   search query to collections of items beyond those associated with "My
#'   Drive". Use the `shared_drive` or `corpus` arguments to control this.
#'   Read more about [shared drives][shared_drives].

#' @seealso Wraps the `files.list` endpoint:
#'   * <https://developers.google.com/drive/api/v3/reference/files/list>
#'
#' Helpful resource for forming your own queries:
#'   * <https://developers.google.com/drive/api/v3/search-files>
#'
#' @template pattern
#' @param trashed Logical. Whether to search files that are not in the trash
#'   (`trashed = FALSE`, the default), only files that are in the trash
#'   (`trashed = TRUE`), or to search regardless of trashed status (`trashed =
#'   NA`).
#' @param type Character. If provided, only files of this type will be returned.
#'   Can be anything that [drive_mime_type()] knows how to handle. This is
#'   processed by googledrive and sent as a query parameter.
#' @template n_max
#' @template shared_drive-singular
#' @template corpus
#' @param ... Other parameters to pass along in the request. The most likely
#'   candidate is `q`. See below and the API's
#'   [Search for files and folders guide](https://developers.google.com/drive/api/v3/search-files).
#' @template verbose
#' @template team_drive-singular
#'
#' @eval return_dribble()
#' @examples
#' \dontrun{
#' # list "My Drive" w/o regard for folder hierarchy
#' drive_find()
#'
#' # filter for folders, the easy way and the hard way
#' drive_find(type = "folder")
#' drive_find(q = "mimeType = 'application/vnd.google-apps.folder'")
#'
#' # filter for Google Sheets, the easy way and the hard way
#' drive_find(type = "spreadsheet")
#' drive_find(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#'
#' # files whose names match a regex
#' # the local, general, sometimes-slow-to-execute version
#' drive_find(pattern = "ick")
#' # the server-side, executes-faster version
#' # NOTE: works only for a pattern at the beginning of file name
#' drive_find(q = "name contains 'chick'")
#'
#' # search for files located directly in your root folder
#' drive_find(q = "'root' in parents")
#' # FYI: this is equivalent to
#' drive_ls("~/")
#'
#' # control page size or cap the number of files returned
#' drive_find(pageSize = 50)
#' # all params passed through `...` can be camelCase or snake_case
#' drive_find(page_size = 50)
#' drive_find(n_max = 58)
#' drive_find(page_size = 5, n_max = 15)
#'
#' # various ways to specify q search clauses
#' # multiple q's
#' drive_find(
#'   q = "name contains 'TEST'",
#'   q = "modifiedTime > '2020-07-21T12:00:00'"
#' )
#' # vector q
#' drive_find(q = c("starred = true", "visibility = 'anyoneWithLink'"))
#'
#' # default `trashed = FALSE` excludes files in the trash
#' # `trashed = TRUE` consults ONLY file in the trash
#' drive_find(trashed = TRUE)
#' # `trashed = NA` disregards trash status completely
#' drive_find(trashed = NA)
#'
#' # suppress the default sorting on recency
#' drive_find(order_by = NULL, n_max = 5)
#'
#' # sort on various keys
#' drive_find(order_by = "modifiedByMeTime", n_max = 5)
#' # request descending order
#' drive_find(order_by = "quotaBytesUsed desc", n_max = 5)
#' }
#'
#' @export
drive_find <- function(pattern = NULL,
                       trashed = FALSE,
                       type = NULL,
                       n_max = Inf,
                       shared_drive = NULL,
                       corpus = NULL,
                       ...,
                       verbose = deprecated(),
                       team_drive = deprecated()) {
  warn_for_verbose(verbose)
  if (!is.null(pattern) && !(is_string(pattern))) {
    drive_abort("{.arg pattern} must be a character string.")
  }
  stopifnot(is_toggle(trashed))
  stopifnot(is.numeric(n_max), n_max >= 0, length(n_max) == 1)

  if (lifecycle::is_present(team_drive)) {
    lifecycle::deprecate_warn(
      "2.0.0",
      "drive_find(team_drive)",
      "drive_find(shared_drive)"
    )
    shared_drive <- shared_drive %||% team_drive
  }

  if (n_max < 1) {
    return(dribble())
  }

  params <- toCamel(list2(...))
  params[["fields"]] <- params[["fields"]] %||% "*"
  if (!has_name(params, "orderBy")) {
    params[["orderBy"]] <- "recency desc"
  }
  params <- marshal_q_clauses(params)

  trash_clause <- switch(
    as.character(trashed),
    `TRUE` = "trashed = true",
    `FALSE` = "trashed = false",
    "(trashed = true or trashed = false)"
  )
  params$q <- append(params$q, trash_clause)

  if (!is.null(type)) {
    ## if they are all NA, this will error, because drive_mime_type()
    ## doesn't allow it, otherwise we proceed with the non-NA mime types
    mime_type <- drive_mime_type(type)
    mime_type <- purrr::discard(mime_type, is.na)
    params$q <- append(params$q, or(glue("mimeType = {sq(mime_type)}")))
  }

  params$q <- and(params$q)

  params <- append(params, handle_shared_drives(shared_drive, corpus))

  request <- request_generate(endpoint = "drive.files.list", params = params)
  proc_res_list <- do_paginated_request(
    request,
    n_max = n_max,
    n = function(x) length(x$files)
  )

  res_tbl <- proc_res_list %>%
    map("files") %>%
    purrr::flatten() %>%
    as_dribble()

  # there is some evidence of overlap in the results returned in different
  # pages; this is attempt to eliminate a 2nd (or 3rd ...) record for an ID
  # #272 #273 #277 #279 #281
  res_tbl <- res_tbl[!duplicated(res_tbl$id), ]

  if (!is.null(pattern)) {
    res_tbl <- res_tbl[grep(pattern, res_tbl$name), ]
  }
  if (n_max < nrow(res_tbl)) {
    res_tbl <- res_tbl[seq_len(n_max), ]
  }
  res_tbl
}

## finds all the q clauses and collapses into one character vector of clauses
## these are destined to be and'ed to form q in the query
marshal_q_clauses <- function(params) {
  params <- partition_params(params, "q")
  if (length(params[["matched"]]) == 0) {
    return(params[["unmatched"]])
  }

  q_bits <- params[["matched"]]
  stopifnot(all(vapply(q_bits, is.character, logical(1))))
  q_bits <- unique(unlist(q_bits, use.names = FALSE))
  q_bits <- q_bits[lengths(q_bits) > 0]
  c(params[["unmatched"]], q = list(q_bits))
}

# https://developers.google.com/drive/api/v3/search-shareddrives#query_multiple_terms_with_parentheses
parenthesize <- function(x) glue("({x})")
and <- function(x) glue_collapse(parenthesize(x), sep = " and ")
or <- function(x) glue_collapse(x, sep = " or ")

handle_shared_drives <- function(shared_drive, corpus) {
  if (!is.null(shared_drive)) {
    shared_drive <- as_shared_drive(shared_drive)
    if (no_file(shared_drive)) {
      drive_abort("Can't find the requested {.arg shared_drive}.")
    }
    shared_drive <- as_id(shared_drive)
  }
  if (identical(corpus, "all")) {
    lifecycle::deprecate_warn(
      "2.0.0",
      "drive_find(corpus = 'now expects \"allDrives\" instead of \"all\"')"
    )
    corpus <- "allDrives"
  }
  if (is.null(shared_drive) && is.null(corpus)) {
    return()
  }
  shared_drive_params(shared_drive, corpus)
}
