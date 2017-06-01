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
