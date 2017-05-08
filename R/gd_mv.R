#' Move Google Drive file
#'
#' @param file `drive_file` object for the file you would like to move
#' @param folder `drive_file` object for the folder you would like to move the file to
#'
#' @return `drive_file` that was moved
#' @export
gd_mv <- function(file = NULL, folder = NULL){

  request <- build_gd_mv(file = file, folder = folder)
  response <- make_request(request)
  proc_res <- process_request(response)

  file <- gd_file(proc_res$id)
  invisible(file)
}

build_gd_mv <- function(file = NULL, folder = NULL){
  if(!inherits(file, "drive_file")){
    spf("Input `file` must be a `drive_file`. See `gd_file()`")
  }

  if(!inherits(folder, "drive_file")){
    spf("Input `folder` must be a `drive_file`. See `gd_file()`")
  }

  url <- file.path(.state$gd_base_url_files_v3,
                   paste0(id, "?addParents=",folder$id,"&removeParents=",file$kitchen_sink$parents[[1]]))

                   build_request(endpoint = url,
                                 token = gd_token(),
                                 method = "PATCH")
}
