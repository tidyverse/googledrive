#' Google Drive List
#'
#' @param search character, regular expression(s) of title(s) of documents to output in a tibble. If it is \code{NULL} (defualt), information about all documents in drive will be output in a tibble.
#' @param verbose Logical, indicating whether to print informative messages (default \code{TRUE})
#'
#' @return tibble of files
#' @export
#'
gd_ls <- function(search = NULL, ..., verbose = TRUE){
  token <- .state$token
  req <- httr::GET(.state$gd_base_url_files_v3,token)
  httr::stop_for_status(req)
  reqlist <- httr::content(req, "parsed")
  if (length(reqlist) == 0) stop("Zero records match your url.\n")

  req_tbl <- tibble::tibble(
    name = purrr::map_chr(reqlist$files, "name"),
    type = sub('.*\\.', '',purrr::map_chr(reqlist$files, "mimeType")),
    id = purrr::map_chr(reqlist$files, "id")
  )

  if (is.null(search)){

    return(req_tbl)

  } else{

    stopifnot(inherits(search, "character"))

  }

  keep_names <- grep(search, req_tbl$name, ...)

  if(length(keep_names) == 0L){
    if(verbose){
      message(paste0("We couldn't find any documents matching '", search, "'. Try updating your search critria."))
    }
    invisible(NULL)
  } else
    req_tbl[keep_names,]
}
