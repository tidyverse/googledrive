#' Find files on Google Drive
#'
#' This is the closest googledrive function to what you can do at
#' <https://drive.google.com>: by default, you just get a listing of your files.
#' You can also search in various ways, e.g., filter by file type or ownership
#' or even work with Team Drives, if you have access. This is a very powerful
#' function. Together with the more specific [drive_get()], this is the main way
#' to identify files to target for downstream work.

#' @section File type:
#'
#' Use `type` to filter on file type. Under the hood, this filters on MIME type.
#' But the input is pre-processed with [drive_mime_type()], so you can use a few
#' shortcuts and file extensions, in addition to full-blown MIME types.

#' @section Search parameters:
#'
#' Do advanced search on file properties by providing search clauses to the
#' `q` parameter that is passed to the API via `...`. Multiple `q` clauses or
#' vector-valued `q` are combined via 'and'.

#' @section Trash:
#'
#' By default, `drive_find()` does not include files in the trash: it adds `q =
#' "trashed = false"` to the query. However, it will not do so if the user
#' specifies a `q` search clause for trash inclusion or exclusion. To see only
#' files in the trash, use [drive_view_trash()], which is a shortcut for
#' `drive_find(q = "trashed = true")`. To see files regardless of trash status,
#' use `drive_find(q = "trashed = true or trashed = false")`.

#' @section Team Drives:
#'
#' I will be back!

#' @seealso Wraps the `files.list` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/list>
#'
#' Helpful resource for forming your own queries:
#'   * <https://developers.google.com/drive/v3/web/search-parameters>
#'
#' @template pattern
#' @param type Character. If provided, only files of this type will be returned.
#'   Can be anything that [drive_mime_type()] knows how to handle. This is
#'   processed by googledrive and sent as a query parameter.
#' @template n_max
#' @template team_drive-singular
#' @template corpora
#' @param ... Other parameters to pass along in the request. The most likely
#'   candidate is `q`. See the examples and the API's
#'   [Search for Files guide](https://developers.google.com/drive/v3/web/search-parameters).
#' @template verbose
#'
#' @template dribble-return
#' @examples
#' \dontrun{
#' ## list "My Drive" w/o regard for folder hierarchy
#' drive_find()
#'
#' ## search for files located directly in your root folder
#' drive_find(q = "'root' in parents")
#'
#' ## filter for folders, the easy way and the hard way
#' drive_find(type = "folder")
#' drive_find(q = "mimeType = 'application/vnd.google-apps.folder'")
#'
#' ## filter for Google Sheets, the easy way and the hard way
#' drive_find(type = "spreadsheet")
#' drive_find(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#'
#' ## files whose names match a regex
#' drive_find(pattern = "jt")
#'
#' ## control page size or cap the number of files returned
#' drive_find(pageSize = 50)
#' drive_find(n_max = 58)
#' drive_find(pageSize = 5, n_max = 15)
#'
#' ## various ways to specify q search clauses
#' ## multiple q's
#' drive_find(q = "name contains 'TEST'",
#'            q = "modifiedTime > '2017-07-21T12:00:00'")
#' ## vector q
#' drive_find(q = c("starred = true", "visibility = 'anyoneWithLink'"))
#'
#' ## override the default to get files regardless of trash status
#' drive_find(q = "trashed = true or trashed = false")
#' }
#'
#' @export
drive_find <- function(pattern = NULL,
                       type = NULL,
                       n_max = Inf,
                       team_drive = NULL,
                       corpora = NULL,
                       ...,
                       verbose = TRUE) {

  if (!is.null(pattern) && !(is_string(pattern))) {
      stop_glue("`pattern` must be a character string.")
  }
  stopifnot(is.numeric(n_max), n_max >= 0, length(n_max) == 1)
  if (n_max < 1) return(dribble())

  params <- list(...)
  params$fields <- params$fields %||% "*"
  params <- marshal_q_clauses(params)

  if (!is.null(type)) {
    ## if they are all NA, this will error, because drive_mime_type()
    ## doesn't allow it, otherwise we proceed with the non-NA mime types
    mime_type <- drive_mime_type(type)
    mime_type <- purrr::discard(mime_type, is.na)
    params$q <- append(params$q, or(glue("mimeType = {sq(mime_type)}")))
  }

  params$q <- and(params$q)

  params <- append(params, handle_team_drives(team_drive, corpora))

  request <- generate_request(endpoint = "drive.files.list", params = params)
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

and <- function(x) collapse(x, sep = " and ")
or <- function(x) collapse(x, sep = " or ")

## finds all the q clauses and collapses into one character vector of clauses
## these are destined to be and'ed to form q in the query
## also enacts our default of excluding files in trash
marshal_q_clauses <- function(params) {
  params <- partition_params(params, "q")
  if (length(params[["matched"]]) == 0) {
    return(c(params[["unmatched"]], c(q = "trashed = false")))
  }
  q_bits <- params[["matched"]]
  stopifnot(all(vapply(q_bits, is.character, logical(1))))
  q_bits <- unique(unlist(q_bits, use.names = FALSE))
  q_bits <- q_bits[lengths(q_bits) > 0]

  ## by default, exclude files in trash
  ## but stay out of it if user has provided a trash clause
  if (!any(grepl("trashed\\s*!?=\\s*true|false", trim_ws(q_bits %||% "")))) {
    q_bits <- c(q_bits, "trashed = false")
  }

  c(params[["unmatched"]], q = list(q_bits))
}

handle_team_drives <- function(team_drive, corpora) {
  if (is.null(team_drive) && is.null(corpora)) return(NULL)
  tid <- as_id(as_teamdrive(team_drive))
  if (length(tid) == 0) {
    tid <- NULL
  }
  drive_corpus(teamDriveId = tid, corpora = corpora)
}
