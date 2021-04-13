#' PUT new media into a Drive file
#'
#' PUTs new media into a Drive file, in the HTTP sense: if the file already
#' exists, we replace its content and we create a new file, otherwise. This is a
#' convenience wrapper around [`drive_upload()`] and [`drive_update()`]. In
#' pseudo-code:
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
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
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
#' # clean-up
#' drive_find("drive_put_.+[.]txt") %>% drive_rm()
#' unlink(local_file)
#' }
drive_put <- function(media,
                      path = NULL,
                      name = NULL,
                      ...,
                      type = NULL,
                      verbose = deprecated()) {
  if (lifecycle::is_present(verbose)) {
    warn_for_verbose(verbose)
  }

  if (!file.exists(media)) {
    stop_glue("\nFile does not exist:\n  * {media}")
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
    message_glue("No pre-existing file at this filepath. Calling `drive_upload()`.")
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
    message_glue("Pre-existing file found at this filepath. Calling `drive_update()`.")
    return(drive_update(
      hits,
      media = media,
      ...
    ))
  }

  # Unhappy Path: multiple collisions
  hits <- drive_reveal(hits, "path")
  msg <- glue("  * {hits$path}: {hits$id}")

  msg <- c(
    "Multiple items already exist at the target filepath.",
    "It's not clear what `drive_put()` should do. Aborting.",
    msg
  )
  stop_glue(glue_collapse(msg, sep = "\n"))
}
