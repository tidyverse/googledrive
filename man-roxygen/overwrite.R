#' @param overwrite Logical, indicating whether to check for a pre-existing file
#'   at the targetted "filepath". The quotes around "filepath" refer to the fact
#'   that Drive does not impose a 1-to-1 relationship between filepaths and files,
#'   like a typical file system; read more about that in [drive_get()].
#'
#'   * `NA` (default): Just do the operation, even if it results in multiple
#'     files with the same filepath.
#'   * `TRUE`: Check for a pre-existing file at the filepath. If there is
#'     zero or one, move a pre-existing file to the trash, then carry on. Note
#'     that the new file does not inherit any properties from the old one, such
#'     as sharing or publishing settings. It will have a new file ID. An error is
#'     thrown if two or more pre-existing files are found. Use `drive_update()` or
#'     `drive_put()` if you want to keep permissions and sharing from an already existing file.
#'   * `FALSE`: Error if there is any pre-existing file at the filepath.
#'
#' Note that existence checks, based on filepath, are expensive operations, i.e.
#' they require additional API calls.

