#' PUT new media into a Drive file
#'
#' @description
#' PUTs new media into a Drive file, in the HTTP sense:
#' * If the file already exists, we replace its content.
#' * If the file does not already exist, we create a new file.
#'
#' @description
#' This is a convenience wrapper around [`drive_upload()`] and
#' [`drive_update()`]. In pseudo-code:
#'
#' ```
#' target_filepath <- <determined from `path`, `name`, and `media`>
#' hits <- <get all Drive files at target_filepath>
#' if (no hits) {
#'   drive_upload(media, path, name, type, ...)
#' } else if (exactly 1 hit) {
#'   drive_update(hit, media, ...)
#' } else {
#'   ERROR
#' }
#' ```
#'
#' @inheritParams drive_upload
#'
#' @eval return_dribble()
#' @export
#' @examplesIf drive_has_token()
#' # create a local file to work with
#' local_file <- tempfile("drive_put_", fileext = ".txt")
#' writeLines(c("beginning", "middle"), local_file)
#'
#' # PUT to a novel filepath --> drive_put() delegates to drive_upload()
#' file <- drive_put(local_file)
#'
#' # update the local file
#' cat("end", file = local_file, sep = "\n", append = TRUE)
#'
#' # PUT again --> drive_put() delegates to drive_update()
#' file <- drive_put(local_file)
#'
#' # create a second file at this filepath
#' file2 <- drive_create(basename(local_file))
#'
#' # PUT again --> ERROR
#' drive_put(local_file)
#'
#' # Clean up
#' drive_find("drive_put_.+[.]txt") |> drive_rm()
#' unlink(local_file)
drive_put <- function(
  media,
  path = NULL,
  name = NULL,
  ...,
  type = NULL,
  verbose = deprecated()
) {
  warn_for_verbose(verbose)
  if (file.exists(media)) {
    media <- enc2utf8(media)
  } else {
    drive_abort(c(
      "No file exists at the local {.arg media} path:",
      bulletize(gargle_map_cli(media, "{.path <<x>>}"), bullet = "x")
    ))
  }

  tmp <- rationalize_path_name(path, name)
  path <- tmp$path
  name <- tmp$name

  params <- list()

  # load (path, name) into params
  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- path$id
  }
  params[["name"]] <- name %||% basename(media)

  hits <- overwrite_hits(
    parent = params[["parents"]],
    name = params[["name"]],
    overwrite = FALSE
  )

  # Happy Path 1 of 2: no name collision
  if (is.null(hits) || no_file(hits)) {
    drive_bullets(c(
      "i" = "No pre-existing Drive file at this path. Calling \\
             {.fun drive_upload}."
    ))

    return(drive_upload(
      media = media,
      path = as_id(params[["parents"]]),
      name = params[["name"]],
      type = type,
      ...
    ))
  }

  # Happy Path 2 of 2: single name collision
  if (single_file(hits)) {
    drive_bullets(c(
      "i" = "A Drive file already exists at this path. Calling \\
             {.fun drive_update}."
    ))
    return(drive_update(
      hits,
      media = media,
      ...
    ))
  }

  # Unhappy Path: multiple collisions
  drive_abort(c(
    "Multiple items already exist on Drive at the target filepath.",
    "Unclear what {.fun drive_put} should do. Exiting.",
    # drive_reveal_path() puts immediate parent, if specified, in the `path`
    # then we reveal `path`, instead of `name`
    bulletize(gargle_map_cli(
      drive_reveal_path(hits, ancestors = path),
      template = c(
        id_string = "<id:\u00a0<<id>>>", # \u00a0 is a nonbreaking space
        out = "{.drivepath <<path>>} {cli::col_grey('<<id_string>>')}"
      )
    ))
  ))
}
