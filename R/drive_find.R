#' Find files on Google Drive
#'
#' This is the closest googledrive function to what you can do at
#' <https://drive.google.com>: by default, you just get a listing of your files.
#' You can also search in various ways, e.g., filter by file type or ownership
#' or even work with [Team Drive files][team_drives], if you have access. This
#' is a very powerful function. Together with the more specific [drive_get()],
#' this is the main way to identify files to target for downstream work.
#'
#' @template team-drives-description

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
#'   in the [`files.list` endpoint](https://developers.google.com/drive/v3/reference/files/list).
#'   googledrive translates a snake_case specification of `order_by` into the
#'   lowerCamel form, `orderBy`.

#' @section Team Drives:
#'
#' If you have access to Team Drives, you'll know. Use `team_drive` or `corpus`
#' to search one or more Team Drives or a domain. See
#' [Access Team Drives][team_drives] for more.

#' @seealso Wraps the `files.list` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/list>
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
#' @template team_drive-singular
#' @template corpus
#' @param ... Other parameters to pass along in the request. The most likely
#'   candidate is `q`. See below and the API's
#'   [Search for files and folders guide](https://developers.google.com/drive/api/v3/search-files).
#' @template verbose
#'
#' @template dribble-return
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
#' drive_find(pattern = "jt")
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
#' drive_find(q = "name contains 'TEST'",
#'            q = "modifiedTime > '2017-07-21T12:00:00'")
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
#' drive_find(order_by = "quotaBytesUsed", n_max = 5)
#' drive_find(order_by = "modifiedByMeTime", n_max = 5)
#' }
#'
#' @export
drive_find <- function(pattern = NULL,
                       trashed = FALSE,
                       type = NULL,
                       n_max = Inf,
                       team_drive = NULL,
                       corpus = NULL,
                       ...,
                       verbose = TRUE) {
  if (!is.null(pattern) && !(is_string(pattern))) {
    stop_glue("`pattern` must be a character string.")
  }
  stopifnot(is_toggle(trashed))
  stopifnot(is.numeric(n_max), n_max >= 0, length(n_max) == 1)
  if (n_max < 1) return(dribble())

  params <- toCamel(list(...))
  params[["fields"]] <- params[["fields"]] %||% "*"
  if (!rlang::has_name(params, "orderBy")) {
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

  params <- append(params, handle_team_drives(team_drive, corpus))

  request <- request_generate(endpoint = "drive.files.list", params = params)
  proc_res_list <- do_paginated_request(
    request,
    n_max = n_max,
    n = function(x) length(x$files),
    verbose = verbose
  )

  res_tbl <- proc_res_list %>%
    purrr::map("files") %>%
    purrr::flatten() %>%
    as_dribble()

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

handle_team_drives <- function(team_drive, corpus) {
  if (!is.null(team_drive)) {
    team_drive <- as_team_drive(team_drive)
    if (no_file(team_drive)) {
      stop(
        "Can't find the requested `team_drive`.",
        call. = FALSE
      )
    }
    team_drive <- as_id(team_drive)
  }
  if (identical(corpus, "all")) {
    corpus <- "user,allTeamDrives"
  }
  if (is.null(team_drive) && is.null(corpus)) return(NULL)
  team_drive_params(team_drive, corpus)
}
