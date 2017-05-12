## gets all the other folders
drive_folders <- function(...){

  fields <- paste0("files/",c("id","name","mimeType","parents"), collapse = ",")
  request <- build_request(endpoint = .state$drive_base_url_files_v3,
                           token = drive_token(),
                           params = list(...,
                                         fields = fields ,
                                         q = "mimeType='application/vnd.google-apps.folder'"))
  response <- make_request(request)
  proc_res <- process_request(response)
  tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub('.*\\.', '',purrr::map_chr(proc_res$files, "mimeType")),
    parent_id =  purrr::map_chr(purrr::map(proc_res$files, 'parents', .null = NA),1),
    id = purrr::map_chr(proc_res$files, "id")
  )

  root <- root_folder()
  tbl$root <- ifelse(tbl$parent_id == root, TRUE, FALSE)
  tbl
}

## gets the root folder id
root_folder <- function(){
  url <- file.path(.state$drive_base_url_files_v3, "root")
  request <- build_request(endpoint = url,
                           token = drive_token()

  )
  response <- make_request(request)
  proc_res <- process_request(response)
  proc_res$id

}

folder_id <- function(name = NULL, folder_tbl = NULL, verbose = TRUE){
  if(!(name %in% folder_tbl$name)){
    spf("We could not find a folder named '%s' on your Google Drive", name)
  }
  if (sum(folder_tbl$name == name) > 1) {
    spf("You have not uniquely identified the folder '%s', it seems you have more than one folder by that name.", name)
  }
  folder_tbl$id[folder_tbl$name == name]
}
