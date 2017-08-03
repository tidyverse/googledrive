#' Find Team Drives
#'
#' @description This is the closest googledrive function to what you get from
#'   visiting <https://drive.google.com> and clicking "Team Drives". Note:
#'   [Team Drives](https://gsuite.google.com/learning-center/products/drive/get-started-team-drive/)
#'   are only available to users of certain enhanced Google services, such as
#'   G Suite Enterprise, G Suite Business, or G Suite for Education.

#' @seealso Wraps the `teamdrives.list` endpoint::
#'   * <https://developers.google.com/drive/v3/reference/teamdrives/list>

#' @template pattern
#' @template n_max
#' @param ... Other parameters to pass along in the request, such as `pageSize`.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' team_drive_find()
#' }
team_drive_find <- function(pattern = NULL,
                            n_max = Inf,
                            ...,
                            verbose = TRUE) {
  if (!is.null(pattern) && !is_string(pattern)) {
    stop_glue("Please update `pattern` to be a character string.")
  }
  stopifnot(is.numeric(n_max), n_max >= 0, length(n_max) == 1)
  if (n_max < 1) return(dribble())

  ## what could possibly come via `...` here? pageSize (or fields)
  params <- list(...)
  params$fields <- params$fields %||% "*"

  request <- generate_request("drive.teamdrives.list", params = params)
  proc_res_list <- do_paginated_request(
    request,
    n_max = n_max,
    n = function(x) length(x$teamDrives),
    verbose = verbose
  )

  res_tbl <- proc_res_list %>%
    purrr::map("teamDrives") %>%
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
