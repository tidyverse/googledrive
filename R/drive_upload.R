#' Upload into a new Drive file
#'
#' Uploads a local file into a new Drive file. To update the content or metadata
#' of an existing Drive file, use [drive_update()].
#'
#' @seealso MIME types that can be converted to native Google formats:
#'    * <https://developers.google.com/drive/v3/web/manage-uploads#importing_to_google_docs_types_wzxhzdk18wzxhzdk19>
#'
#' @template media
#' @template path
#' @templateVar name file
#' @templateVar default If not given or unknown, will default to the "My Drive" root folder.
#' @template name
#' @templateVar name file
#' @templateVar default Will default to its local name.
#' @param type Character. If `type = NULL`, a MIME type is automatically
#'   determined from the file extension, if possible. If the source file is of a
#'   suitable type, you can request conversion to Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively. All non-`NULL` values for `type` are pre-processed with
#'   [drive_mime_type()].
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
#' }
drive_upload <- function(media,
                         path = NULL,
                         name = NULL,
                         type = NULL,
                         verbose = TRUE) {

  if (!file.exists(media)) {
    sglue("\nFile does not exist:\n  * {media}")
  }

  if (!is.null(name)) {
    stopifnot(is_path(name), length(name) == 1)
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  ## vet the parent folder
  ## easier to default to root vs keeping track of whether parent is specified
  path <- path %||% root_folder()
  path <- as_dribble(path)
  if (!some_files(path)) {
    sglue("Requested parent folder does not exist.")
  }
  if (!single_file(path)) {
    paths <- glue::glue_data(path, "  * {name}: {id}")
    scollapse(
      c("Requested parent folder identifies multiple files:", paths),
      sep = "\n"
    )
  }
  if (!is_folder(path)) {
    sglue("\n`path` specifies a file that is not a folder:\n * {path$name}")
  }

  name <- name %||% basename(media)
  mimeType <- drive_mime_type(type)

  request <- generate_request(
    endpoint = "drive.files.create",
    params = list(
      name = name,
      parents = list(path$id),
      mimeType = mimeType
    )
  )

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  out <- drive_update(as_id(proc_res$id), media, verbose = FALSE)

  if (verbose) {
    mglue("\nLocal file:\n  * {media}\n",
          "uploaded into Drive file:\n  * {out$name}: {out$id}\n",
          "with MIME type:\n  * {out$files_resource[[1]]$mimeType}"
    )
  }
  invisible(out)
}
