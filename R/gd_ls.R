#' Tibble of files on Google Drive
#'
#' @param search character, regular expression(s) of title(s) of documents to output in a tibble.
#' If it is `NULL` (default), information about all documents in drive will be output in a tibble.
#' @param ... name-value pairs to query the API
#' @param fixed logical, from `[grep()]`. If `TRUE``, `search` is exactly matched to a
#' document's name on Google Drive.
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#'This will default to the most recent 100 files on your Google Drive. If you would like more than 100,
#'include using the `pageSize` parameter. For example, if I wanted 200, I would run `gd_ls(pageSize = 200)`.
#
#' @return tibble containing the name, type, and id of files on your google drive (default 100 files)
#' @export
#'
gd_ls <- function(search = NULL, ..., fixed = FALSE, verbose = TRUE){

  req <- build_request(endpoint = .state$gd_base_url_files_v3,
                       token = gd_token(),
                       params = list(...))
  res <- make_request(req)
  proc_res <- process_request(res)

  req_tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub('.*\\.', '',purrr::map_chr(proc_res$files, "mimeType")),
    id = purrr::map_chr(proc_res$files, "id")
  )

  if (is.null(search)){
    return(req_tbl)
  } else{
    if(!inherits(search, "character")){
      stop("Please update `search` to be a character string or vector of character strings.")
    }
  }

  if (length(search) > 1) {
    search <- paste(search, collapse = "|")
  }

  keep_names <- grep(search, req_tbl$name, fixed = fixed)

  if(length(keep_names) == 0L){
    if(verbose){
      message(sprintf("We couldn't find any documents matching '%s'. \nTry updating your `search` critria.", gsub("\\|", "' or '", search)))
    }
    invisible(NULL)
  } else
    req_tbl[keep_names,]
}
