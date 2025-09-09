#' Read the content of a Drive file
#'
#' @description These functions return the content of a Drive file as either a
#'   string or raw bytes. You will likely need to do additional work to parse
#'   the content into a useful R object.
#'
#'   [drive_download()] is the more generally useful function, but for certain
#'   file types, such as comma-separated values (MIME type `text/csv`), it can
#'   be handy to read data directly from Google Drive and avoid writing to disk.
#'
#'   Just as for [drive_download()], native Google file types, such as Google
#'   Sheets or Docs, must be exported as a conventional MIME type. See the help
#'   for [drive_download()] for more.

#' @template file-singular
#' @inheritParams drive_download
#' @param encoding Passed along to [httr::content()]. Describes the encoding of
#'   the *input* `file`.

#' @return
#' * `read_drive_string()`: a UTF-8 encoded string
#' * `read_drive_raw()`: a [raw()] vector

#' @export
#' @examplesIf drive_has_token()
#' # comma-separated values --> data.frame or tibble
#' (chicken_csv <- drive_example_remote("chicken.csv"))
#' chicken_csv |>
#'   drive_read_string() |>
#'   read.csv(text = .)
#'
#' # Google Doc --> character vector
#' (chicken_doc <- drive_example_remote("chicken_doc"))
#' chicken_doc |>
#'   # NOTE: we must specify an export MIME type
#'   drive_read_string(type = "text/plain") |>
#'   strsplit(split = "(\r\n|\r|\n)") |>
#'   (\(.) .[[1]])()
drive_read_string <- function(file, type = NULL, encoding = NULL) {
  drive_read_impl(file = file, type = type, as = "string", encoding = encoding)
}

#' @export
#' @rdname drive_read_string
drive_read_raw <- function(file, type = NULL) {
  drive_read_impl(file = file, type = type, as = "raw")
}

drive_read_impl <- function(
  file,
  type = NULL,
  as = c("string", "raw"),
  encoding = NULL
) {
  as <- match.arg(as)
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  mime_type <- pluck(file, "drive_resource", 1, "mimeType")

  if (!grepl("google", mime_type) && !is.null(type)) {
    drive_bullets(c(
      "!" = "Ignoring {.arg type}. Only consulted for native Google file types.",
      " " = "MIME type of {.arg file}: {.field {mime_type}}."
    ))
  }

  if (grepl("google", mime_type)) {
    export_type <- type %||% get_export_mime_type(mime_type)
    export_type <- drive_mime_type(export_type)
    verify_export_mime_type(mime_type, export_type)

    request <- request_generate(
      endpoint = "drive.files.export",
      params = list(
        fileId = file$id,
        mimeType = export_type
      )
    )
  } else {
    request <- request_generate(
      endpoint = "drive.files.get",
      params = list(
        fileId = file$id,
        alt = "media"
      )
    )
  }

  response <- request_make(
    request,
    httr::write_memory()
  )

  # only call gargle::response_process() for a failed request
  # it's hard-wired to parse a JSON body
  code <- httr::status_code(response)
  if (code < 200 || code >= 300) {
    return(gargle::response_process(response))
  }

  if (as == "string") {
    resp_body_string(response, encoding = encoding)
  } else if (as == "raw") {
    resp_body_raw(response)
  } else {
    drive_abort(c(
      "Internal error: unexpected value for the {.arg as} argument.",
      x = "{.field {as}}"
    ))
  }
}

# stubs for eventual calls to httr2 functions by these same names
resp_body_string <- function(resp, encoding = NULL) {
  out <- httr::content(resp, as = "text", encoding = encoding)
  # Learned this fact the hard way (quoting from Wikipedia):
  # Google Docs also adds a BOM when converting a Doc to a plain text file
  # for download.
  # https://en.wikipedia.org/wiki/Byte_order_mark#UTF-8
  # Therefore we remove such a BOM, if present
  # UTF-8 representation of BOM: ef bb bf
  sub("^\uFEFF", "", out)
}

resp_body_raw <- function(resp) {
  httr::content(resp, as = "raw")
}
