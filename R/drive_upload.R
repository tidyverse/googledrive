#' Upload into a new Drive file
#'
#' Uploads a local file into a new Drive file. To update the content or metadata
#' of an existing Drive file, use [drive_update()]. To upload or update,
#' depending on whether the Drive file already exists, see [drive_put()].
#'
#' @seealso Wraps the `files.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/create>
#'
#' MIME types that can be converted to native Google formats:
#'    * <https://developers.google.com/drive/v3/web/manage-uploads#importing_to_google_docs_types_wzxhzdk18wzxhzdk19>
#'
#' @template media
#' @eval param_path(
#'   thing = "new file",
#'   default_notes = "By default, the file is created in the current
#'     user's \"My Drive\" root folder."
#' )
#' @eval param_name(
#'   thing = "file",
#'   default_notes = "Defaults to the file's local name."
#' )
#' @param type Character. If `type = NULL`, a MIME type is automatically
#'   determined from the file extension, if possible. If the source file is of a
#'   suitable type, you can request conversion to Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively. All non-`NULL` values for `type` are pre-processed with
#'   [drive_mime_type()].
#' @template dots-metadata
#' @template overwrite
#' @template verbose
#'
#' @eval return_dribble()
#' @export
#' @examplesIf drive_has_token()
#' # upload a csv file
#' chicken_csv <- drive_example_local("chicken.csv") %>%
#'   drive_upload("chicken-upload.csv")
#'
#' # or convert it to a Google Sheet
#' chicken_sheet <- drive_example_local("chicken.csv") %>%
#'   drive_upload(
#'     name = "chicken-sheet-upload.csv",
#'     type = "spreadsheet"
#'   )
#'
#' # check out the new Sheet!
#' drive_browse(chicken_sheet)
#'
#' # clean-up
#' drive_find("chicken.*upload") %>% drive_rm()
#'
#' # Upload a file and, at the same time, star it
#' chicken <- drive_example_local("chicken.jpg") %>%
#'   drive_upload(starred = "true")
#'
#' # Is is really starred? YES
#' purrr::pluck(chicken, "drive_resource", 1, "starred")
#'
#' # Clean up
#' drive_rm(chicken)
#'
#' # `overwrite = FALSE` errors if something already exists at target filepath
#' # THIS WILL ERROR!
#' drive_create("name-squatter")
#' drive_example_local("chicken.jpg") %>%
#'   drive_upload(
#'     name = "name-squatter",
#'     overwrite = FALSE
#'   )
#'
#' # `overwrite = TRUE` moves the existing item to trash, then proceeds
#' chicken <- drive_example_local("chicken.jpg") %>%
#'   drive_upload(
#'     name = "name-squatter",
#'     overwrite = TRUE
#'   )
#'
#' # Clean up
#' drive_rm(chicken)
#'
#' \dontrun{
#' # Upload to a shared drive:
#' #   * Shared drives are only available if your account is associated with a
#' #     Google Workspace
#' #   * The shared drive (or shared-drive-hosted folder) MUST be captured as a
#' #     dribble first and provided via `path`
#' sd <- shared_drive_get("Marketing")
#' drive_upload("fascinating.csv", path = sd)
#' }
drive_upload <- function(media,
                         path = NULL,
                         name = NULL,
                         type = NULL,
                         ...,
                         overwrite = NA,
                         verbose = deprecated()) {
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

  params <- toCamel(list2(...))

  # load (path, name) into params
  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- as.character(path$id)
  }
  params[["name"]] <- name %||% basename(media)

  check_for_overwrite(params[["parents"]], params[["name"]], overwrite)

  params[["fields"]] <- params[["fields"]] %||% "*"
  params[["mimeType"]] <- drive_mime_type(type)
  params[["uploadType"]] <- "multipart"

  request <- request_generate(
    endpoint = "drive.files.create.media",
    params = params
  )

  meta_file <- withr::local_file(
    tempfile("drive-upload-meta", fileext = ".json")
  )
  write_utf8(jsonlite::toJSON(params), meta_file)
  ## media uploads have unique body situations, so customizing here.
  request$body <- list(
    metadata = httr::upload_file(
      path = meta_file,
      type = "application/json; charset=UTF-8"
    ),
    media = httr::upload_file(path = media)
  )

  response <- request_make(request, encode = "multipart")
  out <- as_dribble(list(gargle::response_process(response)))

  drive_bullets(c(
    "Local file:",
    "*" = "{.path {media}}",
    "Uploaded into Drive file:",
    bulletize(gargle_map_cli(out)),
    "With MIME type:",
    "*" = "{.field {pluck(out, 'drive_resource', 1, 'mimeType')}}"
  ))
  invisible(out)
}
