#' Get shared drives by name or id
#'
#' @description

#' Retrieve metadata for shared drives specified by name or id. Note that Google
#' Drive does NOT behave like your local file system:

#' * You can get zero, one, or more shared drives back for each name! Shared
#' drive names need not be unique.
#' @template shared-drive-description

#' @param name Character vector of names. A character vector marked with
#'   [as_id()] is treated as if it was provided via the `id` argument.
#' @param id Character vector of shared drive ids or URLs (it is first processed
#'   with [as_id()]). If both `name` and `id` are non-`NULL`, `id` is silently
#'   ignored.
#'
#' @eval return_dribble("shared drive")
#' @export
#' @examples
#' \dontrun{
#' shared_drive_get("my-awesome-shared-drive")
#' shared_drive_get(c("apple", "orange", "banana"))
#' shared_drive_get(as_id("KCmiHLXUk9PVA-0AJNG"))
#' shared_drive_get(as_id("https://drive.google.com/drive/u/0/folders/KCmiHLXUk9PVA-0AJNG"))
#' shared_drive_get(id = "KCmiHLXUk9PVA-0AJNG")
#' shared_drive_get(id = "https://drive.google.com/drive/u/0/folders/KCmiHLXUk9PVA-0AJNG")
#' }
shared_drive_get <- function(name = NULL, id = NULL) {
  if (length(name) + length(id) == 0) return(dribble())

  if (!is.null(name) && inherits(name, "drive_id")) {
    id <- name
    name <- NULL
  }

  if (!is.null(name)) {
    stopifnot(all(map_lgl(name, is_string)))
    return(shared_drive_from_name(name))
  }

  stopifnot(is.character(id))
  # TODO: use a batch requeset
  as_dribble(map(as_id(id), get_one_shared_drive_id))
}

get_one_shared_drive_id <- function(id) {
  id <- as_id(id)
  if (is.na(id)) {
    drive_abort("
      Can't {.fun shared_drive_get} a shared drive when {.arg id} is {.code NA}.")
  }
  if (!isTRUE(nzchar(id, keepNA = TRUE))) {
    drive_abort("
      Shared drive ids must not be {.code NA} and cannot be the empty string.")
  }
  request <- request_generate(
    endpoint = "drive.drives.get",
    params = list(
      driveId = id,
      fields = "*"
    )
  )
  response <- request_make(request)
  gargle::response_process(response)
}

shared_drive_from_name <- function(name = NULL) {
  if (length(name) == 0) return(dribble())

  shared_drives <- shared_drive_find()
  if (no_file(shared_drives)) return(dribble())

  shared_drives <- shared_drives[shared_drives$name %in% name, ]
  ## TO DO: message if a name matches 0 or multiple shared drives?

  shared_drives[order(match(shared_drives$name, name)), ]
}
