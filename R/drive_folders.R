## gets the root folder id
root_folder <- function() {
  url <- file.path(.state$drive_base_url_files_v3, "root")
  request <- build_request(endpoint = url,
                           token = drive_token())
  response <- make_request(request)
  proc_res <- process_request(response)
  proc_res$id

}
