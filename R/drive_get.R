## TO DO: should this be exported?
## is this functionality what people would expect drive_id() to have?
## maybe this should be exported as drive_id() and drive_id() should be as_id()
drive_get <- function(id) {
  stopifnot(is.character(id), length(id) == 1)

  request <- build_request(
    endpoint = "drive.files.get",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- make_request(request)
  proc_res <- process_response(response)

  as_dribble(list(proc_res))
}
