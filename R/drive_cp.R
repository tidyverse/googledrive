#' Copy a Drive file
#'
#' Copies an existing Drive file into a new file id.
#'
#' @seealso Wraps the `files.copy` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/copy>
#'
#' @template file-singular
#' @template path
#' @templateVar name file
#' @templateVar default {}
#' @template name
#' @templateVar name file
#' @templateVar default Defaults to "Copy of `FILE-NAME`".
#' @template dots-metadata
#' @template overwrite
#' @template verbose
#' @template dribble-return
#'
#' @examplesIf drive_has_token()
#' # Create a file to copy
#' file <- drive_upload(drive_example("chicken.txt"), "chicken-cp.txt")
#'
#' # Make a "Copy of" copy in same folder as the original
#' drive_cp("chicken-cp.txt")
#'
#' # Make an explicitly named copy in same folder as the original
#' drive_cp("chicken-cp.txt", "chicken-cp-two.txt")
#'
#' # Make an explicitly named copy in a different folder
#' folder <- drive_mkdir("new-folder")
#' drive_cp("chicken-cp.txt", path = folder, name = "chicken-cp-three.txt")
#'
#' # Make an explicitly named copy and star it.
#' # The starring is an example of providing metadata via `...`.
#' # `starred` is not an actual argument to `drive_cp()`,
#' # it just gets passed through to the API.
#' x <- drive_cp("chicken-cp.txt", name = "chicken-cp-starred.txt", starred = TRUE)
#' purrr::pluck(x, "drive_resource", 1, "starred")
#'
#' # `overwrite = FALSE` errors if file already exists at target filepath
#' # THIS WILL ERROR!
#' # drive_cp("chicken-cp.txt", name = "chicken-cp.txt", overwrite = FALSE)
#'
#' # `overwrite = TRUE` moves an existing file to trash, then proceeds
#' drive_cp("chicken-cp.txt", name = "chicken-cp.txt", overwrite = TRUE)
#'
#' # Behold all of our copies!
#' drive_find("chicken-cp")
#'
#' # Delete all of our copies and the new folder!
#' drive_find("chicken-cp") %>% drive_rm()
#' drive_find("new-folder") %>% drive_rm(folder)
#'
#' # upload a csv file to copy
#' csv_file <- drive_upload(drive_example("chicken.csv"))
#'
#' # copy AND AT THE SAME TIME convert it to a Google Sheet
#' chicken_sheet <- drive_cp(
#'   csv_file,
#'   name = "chicken-cp",
#'   mime_type = drive_mime_type("spreadsheet")
#' )
#' # is it really a Google Sheet?
#' purrr::pluck(chicken_sheet, "drive_resource", 1, "mimeType")
#'
#' # go see the new Sheet in the browser
#' # drive_browse(chicken_sheet)
#'
#' # clean up
#' drive_find("chicken.csv") %>% drive_rm()
#' drive_rm(chicken_sheet)
#' @export
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
    abort("The Drive API does not copy folders or shared drives.")
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

  # doing this in a hacky way because drive_reveal_path(), which is more
  # correct, can be quite slow
  # once I eliminate the "multiple parent" accommodations, that might change
  tmp <- out
  tmp$name <- paste0(append_slash(path$path), out$name)

  drive_bullets(c(
    "Original file:",
    bulletize(cli_map(file)),
    "Copied to file:",
    bulletize(cli_map(tmp))
  ))

  invisible(out)
}
