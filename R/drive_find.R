#' Find files on Google Drive.
#'
#' This is the closest googledrive function to what you get from
#' <https://drive.google.com>: by default, you just get a listing of your files.
#' You can also narrow the search in various ways, such as by file type, whether
#' it's yours or shared with you, starred status, etc.

#' @seealso Helpful links for forming queries:
#'   * <https://developers.google.com/drive/v3/web/search-parameters>
#'   * <https://developers.google.com/drive/v3/reference/files/list>
#'
#' @param pattern Character. If provided, only the files whose names match this
#'   regular expression are returned. This is implemented locally on the results
#'   returned by the API.
#' @param type Character. If provided, only files of this type will be returned.
#'   Can be anything that [drive_mime_type()] knows how to handle. This is
#'   processed by googledrive and sent as a query parameter.
#' @param n_max Integer. An upper bound on the number of files to return. This
#'   applies to the results requested from the API, which may be further
#'   filtered locally, via the `pattern` argument.
#' @param ... Query parameters to pass along to the API query.
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
#' }
#'
#' @export
drive_find <- function(pattern = NULL,
                       type = NULL,
                       n_max = Inf,
                       ...,
                       verbose = TRUE) {

  if (!is.null(pattern)) {
    if (!(is.character(pattern) && length(pattern) == 1)) {
      stop("Please update `pattern` to be a character string.", call. = FALSE)
    }
  }
  stopifnot(is.numeric(n_max), n_max >= 0, length(n_max) == 1)
  if (n_max < 1) return(dribble())

  params <- list(...)
  params$fields <- params$fields %||% prep_fields(drive_fields())

  if (!is.null(type)) {
    ## if they are all NA, this will error, because drive_mime_type()
    ## doesn't allow it, otherwise we proceed with the non-NA mime types
    mime_type <- drive_mime_type(type)
    mime_type <- purrr::discard(mime_type, is.na)
    params$q <- paste(
      c(params$q,
        paste0("mimeType = '", mime_type, "'", collapse = " or ")),
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
