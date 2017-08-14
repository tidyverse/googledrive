#' Upload into a new Drive file
#'
#' Uploads a local file into a new Drive file. To update the content or metadata
#' of an existing Drive file, use [drive_update()].
#'
#' @seealso Wraps the `files.create` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/create>
#'
#' MIME types that can be converted to native Google formats:
#'    * <https://developers.google.com/drive/v3/web/manage-uploads#importing_to_google_docs_types_wzxhzdk18wzxhzdk19>
#'
#' @template media
#' @template path
#' @templateVar name file
#' @templateVar default If not given or unknown, will default to the "My Drive"
#'   root folder.
#' @template name
#' @templateVar name file
#' @templateVar default Will default to its local name.
#' @param type Character. If `type = NULL`, a MIME type is automatically
#'   determined from the file extension, if possible. If the source file is of a
#'   suitable type, you can request conversion to Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively. All non-`NULL` values for `type` are pre-processed with
#'   [drive_mime_type()].
#' @template dots-metadata
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## upload a csv file
#' mirrors_csv <- drive_upload(R.home('doc/BioC_mirrors.csv'))
#'
#' ## or convert it to a Google Sheet
#' mirrors_sheet <- drive_upload(
#'   R.home('doc/BioC_mirrors.csv'),
#'   name = "BioC_mirrors",
#'   type = "spreadsheet"
#' )
#'
#' ## check out the new Sheet!
#' drive_browse(mirrors_sheet)
#'
#' ## clean-up
#' drive_find("BioC_mirrors") %>% drive_rm()
#'
#' ## Upload a file and, at the same time, star it
#' logo <- drive_upload(
#'   R.home('doc/html/logo.jpg'),
#'   starred = "true"
#' )
#'
#' ## Clean up
#' drive_rm(logo)
#' }
drive_upload <- function(media,
                         path = NULL,
                         name = NULL,
                         type = NULL,
                         ...,
                         verbose = TRUE) {

  if (!file.exists(media)) {
    stop_glue("\nFile does not exist:\n  * {media}")
  }

  if (!is.null(name)) {
    stopifnot(is_string(name))
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  dots <- toCamel(list(...))
  dots$fields <- dots$fields %||% "*"

  params <- c(
    uploadType = "multipart",
    dots
  )

  if (!is.null(path)) {
    path <- as_parent(path)
    if (!is.null(params[["parents"]])) {
      stop_collapse(c(
        "You have specified parent folders via both 'path' and 'parents'.",
        "Pick one.",
        "If you want multiple parents, just use the 'parents' parameter."
      ))
    }
    params[["parents"]] <- path$id
  }

  params[["name"]] <- name %||% basename(media)
  params[["mimeType"]] <- drive_mime_type(type)

  request <- generate_request(
    endpoint = "drive.files.create.media",
    params = params
  )

  meta_file <- tempfile()
  on.exit(unlink(meta_file))
  writeLines(jsonlite::toJSON(params), meta_file)
  ## media uploads have unique body situations, so customizing here.
  request$body <- list(
    metadata = httr::upload_file(
      path = meta_file,
      type = "application/json; charset=UTF-8"
    ),
    media = httr::upload_file(path = media)
  )

  response <- make_request(request)
  out <- as_dribble(list(process_response(response)))

  if (verbose) {
    message_glue("\nLocal file:\n  * {media}\n",
          "uploaded into Drive file:\n  * {out$name}: {out$id}\n",
          "with MIME type:\n  * {out$drive_resource[[1]]$mimeType}"
    )
  }
  invisible(out)
}
