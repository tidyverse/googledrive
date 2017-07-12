## for internal use only!!
## We need to create some pathological situations for testing, but googledrive
## isn't going to help users shoot themselves in the foot like this..
## What pathology, specifically?
## one file having multiple direct parents
## i.e. one file with multiple "paths"
##
## both file and new_parent must be single-file dribble or drive_id
drive_add_parent <- function(file = NULL, new_parent = NULL) {
  if (is_dribble(file)) {
    file <- as_id(file$id)
  }
  if (is_dribble(new_parent)) {
    new_parent <- as_id(new_parent$id)
  }
  stopifnot(inherits(file, "drive_id"), inherits(new_parent, "drive_id"))
  file <- as_dribble(file)
  file <- confirm_single_file(file)
  new_parent <- as_dribble(new_parent)
  new_parent <- confirm_single_file(new_parent)

  params <- list(
    fileId = file$id,
    addParents = new_parent$id,
    fields = "*"
  )
  request <- generate_request(
    endpoint = "drive.files.update",
    params = params
  )
  res <- make_request(request, encode = "json")
  proc_res <- process_response(res)
  as_dribble(list(proc_res))
}
