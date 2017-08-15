#' Get Team Drives by name or id
#'
#' @description Retrieve metadata for Team Drives specified via name or id. Note
#'   that Google Drive does NOT behave like your local file system:
#'   * You can get zero, one, or more Team Drives back for each name! Team Drive
#'     names need not be unique.
#' @template team-drives-description

#' @param name Character vector of names.  A character vector marked with
#'   [as_id()] is treated as if it was provided via the `id` argument.
#' @param id Character vector of Team Drive ids or URLs (it is first processed
#'   with [as_id()]). If both `name` and `id` are non-`NULL`, `id` is silently
#'   ignored.
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' team_drive_get("my-awesome-team-drive")
#' team_drive_get(c("apple", "orange", "banana"))
#' team_drive_get(as_id("KCmiHLXUk9PVA-0AJNG"))
#' team_drive_get(as_id("https://drive.google.com/drive/u/0/folders/KCmiHLXUk9PVA-0AJNG"))
#' team_drive_get(id = "KCmiHLXUk9PVA-0AJNG")
#' team_drive_get(id = "https://drive.google.com/drive/u/0/folders/KCmiHLXUk9PVA-0AJNG")
#' }
team_drive_get <- function(name = NULL, id = NULL, verbose = TRUE) {
  if (length(name) + length(id) == 0) return(dribble())

  if (!is.null(name) && inherits(name, "drive_id")) {
    id <- name
    name <- NULL
  }

  if (!is.null(name)) {
    stopifnot(all(purrr::map_lgl(name, is_string)))
    return(team_drive_from_name(name))
  }

  stopifnot(is.character(id))
  as_dribble(purrr::map(as_id(id), get_one_team_drive_id))
}

get_one_team_drive_id <- function(id) {
  if (!isTRUE(nzchar(id, keepNA = TRUE))) {
    stop_glue("Team Drive ids must not be NA and cannot be the empty string.")
  }
  request <- generate_request(
    endpoint = "drive.teamdrives.get",
    params = list(
      teamDriveId = id,
      fields = "*"
    )
  )
  response <- make_request(request)
  process_response(response)
}

team_drive_from_name <- function(name = NULL) {
  if (length(name) == 0) return(dribble())

  team_drives <- team_drive_find(verbose = FALSE)
  if (no_file(team_drives)) return(dribble())

  team_drives <- team_drives[team_drives$name %in% name, ]
  ## TO DO: if (verbose), message if a name matches 0 or multiple Team Drives?

  team_drives[order(match(team_drives$name, name)), ]
}
