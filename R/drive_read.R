#' Read a Drive file
#'
#' @description This function reads the content of a Drive file into memory.
#'   Some basic processing is available, but you might need to do additional
#'   work to turn the content into an R object that is useful to you.
#'
#'   [drive_download()] is the more generally useful function, but for certain
#'   file types, such as comma-separated values (MIME type `text/csv`), it can
#'   be handy to read data directly from Google Drive and avoid writing to disk.
#'
#'   Just as for [drive_download()], native Google file types, such as Google
#'   Sheets or Docs, must be exported as a conventional MIME type. See the help
#'   for [drive_download()] for more about how that works and the examples
#'   below.

#' @template file-singular
#' @inheritParams drive_download
#' @param as How to process the response body.
#'   * "auto": Determine from the MIME type of the response.
#'     - "string" for `text/csv`, `text/plain`, or `text/tab-separated-values`
#'     - "json" for `application/json`
#'     - "html" for `text/html`
#'     - "xml" for `application/xml` or `text/xml`
#'     - "raw" otherwise
#'   * "string": `httr::content(x, as = "text", ...)`
#'   * "json": `httr::content(x, as = "parsed", type = "application/json", ...)`
#'     which calls `jsonlite::fromJSON()`
#'   * "html": `httr::content(x, as = "parsed", type = "text/html", ...)` which
#'     calls `xml2::read_html()`
#'   * "xml": `httr::content(x, as = "parsed", type = "text/xml", ...)` which
#'     calls `xml2::read_xml()`
#'   * "raw": `httr::content(x, as = "raw")`

#' @param ... Additional parameters passed along to body processing functions,
#'   for example, the `encoding` of the input `file`.
#'

#' @return The content of `file`, in the form specified via `as`. When `as =
#'   "string"`, the content is (re-)encoded as UTF-8, which is also true, by
#'   definition, for `as = "json"`. Any `encoding` parameter provided via `...`
#'   is understood to describe the *input* `file`.

#' @export
#' @examplesIf drive_has_token()
#' # plain text --> character vector
#' r_desc <- system.file("DESCRIPTION") %>%
#'   drive_upload()
#' r_desc %>%
#'   drive_read() %>%
#'   strsplit(split = "\n") %>%
#'   .[[1]]
#' if (require(readr)) {
#'   r_desc %>%
#'     drive_read() %>%
#'     readr::read_lines()
#' }
#'
#' # clean up plain text
#' drive_rm(r_desc)
#'
#' # comma-separated values --> data.frame or tibble
#' chicken_csv <- drive_example("chicken.csv") %>%
#'   drive_upload()
#' chicken_csv %>%
#'   drive_read() %>%
#'   read.csv(text = .)
#' if (require(readr)) {
#'   chicken_csv %>%
#'     drive_read() %>%
#'     readr::read_csv()
#' }
#'
#' # clean up comma-separated values
#' drive_rm("chicken.csv")
#'
#' # comma-separated values with latin-1 encoding --> data.frame or tibble
#' tfile <- tempfile()
#' curl::curl_download(
#'   "https://matthew-brett.github.io/cfd2019/data/imdblet_latin.csv",
#'   destfile = tfile
#' )
#' imdb_latin1 <- tfile %>%
#'   drive_upload(name = "imdb_latin1.csv")
#' imdb_latin1 %>%
#'   drive_read(encoding = "ISO-8859-1") %>% # "latin1" works too
#'   read.csv(text = .)
#' if (require(readr)) {
#'   imdb_latin1 %>%
#'     drive_read(encoding = "latin1") %>%  # "ISO-8859-1" works too
#'     readr::read_csv()
#' }
#'
#' # clean up comma-separated values with latin-1 encoding
#' drive_rm(imdb_latin1)
#'
#' # Google Doc --> character vector
#' chicken_doc <- drive_example("chicken.txt") %>%
#'   drive_upload(type = "document")
#' chicken_doc %>%
#'   # NOTE: we must specify an export MIME type
#'   drive_read(type = "text/plain") %>%
#'   strsplit(split = "(\r\n|\r|\n)") %>%
#'   .[[1]]
#'
#' # clean up Google Doc
#' drive_rm(chicken_doc)
#'
#' # JPEG --> raw --> raster
#' # https://stat.ethz.ch/R-manual/R-patched/doc/html/logo.jpg
#' if (require(jpeg)) {
#'   r_logo <- R.home("doc/html/logo.jpg") %>%
#'      drive_upload(name = "r_logo.jpg")
#'   img <- r_logo %>%
#'     drive_read() %>%
#'     jpeg::readJPEG()
#'   plot(0:1, 0:1, type = "n")
#'   rasterImage(img, 0, 0, 1, 1)
#'
#'   # JPEG cleanup
#'   drive_rm(r_logo)
#' }
#'
#' # html -> character vector
#' # https://stat.ethz.ch/R-manual/R-patched/doc/html/about.html
#' if (require(rvest) && require(readr)) {
#'   r_about <- R.home("doc/html/about.html") %>%
#'      drive_upload()
#'   r_about %>%
#'     drive_read() %>%
#'     rvest::html_text2() %>%
#'     readr::read_lines() %>%
#'     lapply(substr, start = 1, stop = 70)
#'
#'   # html clean up
#'   drive_rm(r_about)
#' }
#'
#' # html --> character vector
#' if (require(rvest) && require(stringi)) {
#'   tfile <- tempfile(fileext = ".html")
#'   curl::curl_download("https://httpbin.org/html", destfile = tfile)
#'   httpbin_html <- tfile %>%
#'     drive_upload(name = "httpbin.html")
#'   httpbin_html %>%
#'     drive_read() %>%
#'     rvest::html_text2() %>%
#'     stringi::stri_split_boundaries(type = "sentence") %>%
#'     lapply(substr, start = 1, stop = 70) %>%
#'     .[[1]] %>%
#'     head(6)
#'
#'   # html clean up
#'   drive_rm(httpbin_html)
#' }
#'
#' # xml --> list
#' if (require(xml2)) {
#'   tfile <- tempfile(fileext = ".xml")
#'   curl::curl_download("https://httpbin.org/xml", destfile = tfile)
#'   httpbin_xml <- tfile %>%
#'     drive_upload()
#'   httpbin_xml %>%
#'     drive_read() %>%
#'     xml2::as_list()
#'
#'   # xml clean up
#'   drive_rm(httpbin_xml)
#' }
#'
#' # json --> list
#' tfile <- tempfile(fileext = ".json")
#' curl::curl_download("https://httpbin.org/json", destfile = tfile)
#' httpbin_json <- tfile %>%
#'   drive_upload()
#' httpbin_json %>%
#'   drive_read()
#'
#' # json clean up
#' drive_rm(httpbin_json)
drive_read <- function(file,
                       type = NULL,
                       as = c("auto", "string", "raw", "json", "html", "xml"),
                       ...) {
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
  # it's not prepared to handle general body content types
  code <- httr::status_code(response)
  if (code < 200 || code >= 300) {
    return(gargle::response_process(response))
  }

  actual_mime_type <- httr::http_type(response)
  if (as == "auto") {
    as <- choose_as(actual_mime_type)
    drive_bullets(c(
      "i" = "MIME type of body: {.field {actual_mime_type}}",
      "i" = "Setting {.code as = \"{as}\"}"
    ))
  }

  parser <- switch(
    as,
    string = resp_body_string,
    raw    = resp_body_raw,
    json   = resp_body_json,
    html   = resp_body_html,
    xml    = resp_body_xml,
    drive_abort(c(
      "Internal error: unexpected value for the {.arg as} argument.",
      x = "{.field {as}}"
    ))
  )
  parser(response, ...)
}

choose_as <- function(mime_type) {
  switch(
    mime_type,
    `text/csv` =,
    `text/plain` =,
    `text/tab-separated-values` = "string",
    `application/json` = "json",
    `text/html` = "html",
    `application/xml` =,
    `text/xml` = "xml",
    "raw"
  )
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

resp_body_json <- function(resp, ...) {
  # jsonlite::fromJSON()
  httr::content(resp, as = "parsed", type = "application/json", ...)
}

resp_body_html <- function(resp, ...) {
  # xml2::read_html()
  httr::content(resp, as = "parsed", type = "text/html", ...)
}

resp_body_xml <- function(resp, ...) {
  #xml2::read_xml()
  httr::content(resp, as = "parsed", type = "text/xml", ...)
}
