#' Search for files on Google Drive.
#'
#' This is the closest googledrive function to what you get from
#' <https://drive.google.com>: by default, you just get a listing of your files.
#' You can also narrow the search in various ways, such as by file type, whether
#' it's yours or shared with you, starred status, etc.

#' @seealso Helpful links for forming queries: *
#'   <https://developers.google.com/drive/v3/web/search-parameters> *
#'   <https://developers.google.com/drive/v3/reference/files/list>
#'
#' @param pattern Character. If provided, only the files whose names match this
#'   regular expression are returned.
#' @param type Character. If provided, only files of this type will be returned.
#'   Can be anything that [drive_mime_type()] knows how to handle. This is
#'   processed by googledrive and sent as a query parameter.
#' @param n_max Integer. An upper bound on the number of files to return. This
#'   applies to the results returned by the API, which may be further filtered
#'   locally, via the `pattern` argument.
#' @param ... Query parameters to pass along to the API query.
#' @template verbose
#'
#' @template dribble-return
#' @examples
#' \dontrun{
#' ## list "My Drive" w/o regard for folder hierarchy
#' drive_search()
#'
#' ## search for files located directly in your root folder
#' drive_search(q = "'root' in parents")
#'
#' ## filter for folders
#' drive_search(type = "folder")
#' drive_search(q = "mimeType = 'application/vnd.google-apps.folder'")
#'
#' ## filter for Google Sheets
#' drive_search(type = "spreadsheet")
#' drive_search(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#'
#' ## files whose names match a regex
#' drive_search(pattern = "jt")
#'
#' ## control page size or cap the number of files returned
#' drive_search(pageSize = 50)
#' drive_search(n_max = 75)
#' drive_search(pageSize = 5, n_max = 15)
#' }
#'
#' @export
drive_search <- function(pattern = NULL,
                         type = NULL,
                         n_max = Inf,
                         ...,
                         verbose = TRUE) {

  if (!is.null(pattern)) {
    if (!(is.character(pattern) && length(pattern) == 1)) {
      stop("Please update `pattern` to be a character string.", call. = FALSE)
    }
  }

  params <- list(...)
  params$fields <- params$fields %||% prep_fields(drive_fields())

  if (!is.null(type)) {
    ## if they are all NA, this will error, because drive_mime_type
    ## doesn't allow it, otherwise we proceed with the non-NA mime types
    mime_type <- drive_mime_type(type)
    mime_type <- purrr::discard(mime_type, is.na)
    params$q <- paste(
      c(params$q,
        paste0("mimeType = '", mime_type,"'", collapse = " or ")),
      collapse = " and "
    )
  }

  ## initialize q, if necessary
  ## by default, don't list items in trash
  if (is.null(params$q) || !grepl("trashed", params$q)) {
    ## TO DO: scrutinize what happens here when params$q is NULL
    params$q <- collapse(c(params$q, "trashed = false"), sep = " and ")
  }

  request <- generate_request(endpoint = "drive.files.list", params = params)
  proc_res_list <- do_paginated_request(
    request,
    n_max = n_max,
    n = function(x) length(x$files)
  )

  res_tbl <- as_dribble(purrr::map(proc_res_list, "files") %>% purrr::flatten())
  if (n_max < Inf) {
    res_tbl <- res_tbl[seq_len(n_max), ]
  }

  if (is.null(pattern)) {
    return(res_tbl)
  }

  keep_names <- grep(pattern, res_tbl$name)
  if (length(keep_names) == 0L) {
    if (verbose) message(sprintf("No file names match the pattern: '%s'.", pattern))
    return(invisible())
  }
  as_dribble(res_tbl[keep_names, ]) ## TO DO change this once we get indexing working
}
