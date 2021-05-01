#' Find shared drives
#'
#' @description This is the closest googledrive function to what you get from
#'   visiting <https://drive.google.com> and clicking "Shared drives".
#' @template shared-drive-description

#' @seealso Wraps the `drives.list` endpoint:
#' * <https://developers.google.com/drive/api/v3/reference/drives/list>

#' @template pattern
#' @template n_max
#' @param ... Other parameters to pass along in the request, such as `pageSize`
#'   or `useDomainAdminAccess`.
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' shared_drive_find()
#' }
shared_drive_find <- function(pattern = NULL,
                              n_max = Inf,
                              ...) {
  if (!is.null(pattern) && !(is_string(pattern))) {
    abort("{.arg pattern} must be a character string.")
  }
  stopifnot(is.numeric(n_max), n_max >= 0, length(n_max) == 1)
  if (n_max < 1) return(dribble())

  ## what could possibly come via `...` here? pageSize (or fields)
  params <- toCamel(list2(...))
  params$fields <- params$fields %||% "*"

  request <- request_generate("drive.drives.list", params = params)
  proc_res_list <- do_paginated_request(
    request,
    n_max = n_max,
    n = function(x) length(x$drives)
  )

  res_tbl <- proc_res_list %>%
    purrr::map("drives") %>%
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
