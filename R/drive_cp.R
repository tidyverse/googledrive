#' Copy a Drive file
#'
#' Copies an existing Drive file into a new file id.
#'
#' @seealso Wraps the `files.copy` endpoint:
#'   * <https://developers.google.com/drive/api/v3/reference/files/copy>
#'
#' @template file-singular
#' @eval param_path(
#'   thing = "new file",
#'   default_notes = "By default, the new file has the same parent folder as the
#'      source file."
#' )
#' @eval param_name(
#'   thing = "file",
#'   default_notes = "Defaults to \"Copy of `FILE-NAME`\"."
#' )
#' @template dots-metadata
#' @template overwrite
#' @template verbose
#' @eval return_dribble()
#' @export
#'
#' @examplesIf drive_has_token()
#' # Target one of the official example files
#' (src_file <- drive_example_remote("chicken.txt"))
#'
#' # Make a "Copy of" copy in your My Drive
#' cp1 <- drive_cp(src_file)
#'
#' # Make an explicitly named copy, in a different folder, and star it.
#' # The starring is an example of providing metadata via `...`.
#' # `starred` is not an actual argument to `drive_cp()`,
#' # it just gets passed through to the API.
#' folder <- drive_mkdir("drive-cp-folder")
#' cp2 <- drive_cp(
#'   src_file,
#'   path = folder,
#'   name = "chicken-cp.txt",
#'   starred = TRUE
#' )
#' drive_reveal(cp2, "starred")
#'
#' # `overwrite = FALSE` errors if file already exists at target filepath
#' # THIS WILL ERROR!
#' # drive_cp(src_file, name = "Copy of chicken.txt", overwrite = FALSE)
#'
#' # `overwrite = TRUE` moves an existing file to trash, then proceeds
#' cp3 <- drive_cp(src_file, name = "Copy of chicken.txt", overwrite = TRUE)
#'
#' # Delete all of our copies and the new folder!
#' drive_rm(cp1, cp2, cp3, folder)
#'
#' # Target an official example file that's a csv file
#' (csv_file <- drive_example_remote("chicken.csv"))
#'
#' # copy AND AT THE SAME TIME convert it to a Google Sheet
#' chicken_sheet <- drive_cp(
#'   csv_file,
#'   name = "chicken-sheet-copy",
#'   mime_type = drive_mime_type("spreadsheet")
#' )
#' # is it really a Google Sheet?
#' drive_reveal(chicken_sheet, "mime_type")$mime_type
#'
#' # go see the new Sheet in the browser
#' # drive_browse(chicken_sheet)
#'
#' # Clean up
#' drive_rm(chicken_sheet)
drive_cp <- function(file,
                     path = NULL,
                     name = NULL,
                     ...,
                     overwrite = NA,
                     verbose = deprecated()) {
  warn_for_verbose(verbose)

  file <- as_dribble(file)
  file <- confirm_single_file(file)
  if (is_parental(file)) {
    drive_abort("The Drive API does not copy folders or shared drives.")
  }

  tmp <- rationalize_path_name(path, name)
  path <- tmp$path
  name <- tmp$name

  params <- toCamel(list2(...))

  # load (path, name) into params
  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- list(path$id)
  }
  params[["name"]] <- name %||% glue("Copy of {file$name}")
  check_for_overwrite(params[["parents"]], params[["name"]], overwrite)

  params[["fields"]] <- params[["fields"]] %||% "*"
  params[["fileId"]] <- file$id

  request <- request_generate(
    endpoint = "drive.files.copy",
    params = params
  )
  res <- request_make(request)
  proc_res <- gargle::response_process(res)
  out <- as_dribble(list(proc_res))

  drive_bullets(c(
    "Original file:",
    bulletize(gargle_map_cli(file)),
    "Copied to file:",
    # drive_reveal_path() puts immediate parent, if specified, in the `path`
    # then we reveal `path`, instead of `name`
    bulletize(gargle_map_cli(
      drive_reveal_path(out, ancestors = path),
      template = c(
        id_string = "<id:\u00a0<<id>>>", # \u00a0 is a nonbreaking space
        out = "{.drivepath <<path>>} {cli::col_grey('<<id_string>>')}"
      )
    ))
  ))

  invisible(out)
}
