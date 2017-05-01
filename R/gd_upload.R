#' Upload a file to Google Drive
#'
#' @param file character, path the the file you'd like to upload
#' @param name character, what you'd like the uploaded file to be called on Google Drive
#' @param overwrite logical, do you want to overwrite file already on Google Drive
#' @param type if type = \code{NULL}, will force type as follows:
#'  \itemize{
#'  \item document: .doc, .docx, .txt, .rtf., .html, .odt, .pdf, .jpeg, .png, .gif,.bmp
#'  \item spreadsheet: .xls, .xlsx, .csv, .tsv, .tab, .xlsm, .xlt, .xltx, .xltm,
#' .ods
#'  \item presentation: .opt, .ppt, .pptx, .pptm
#'  otherwise you can specify \code{document}, \code{spreadsheet}, or \code{presentation}
#'  }
#' @param verbose logical, indicating whether to print informative messages (default \code{TRUE})
#'
#' @export
gd_upload <- function(file, name = NULL, overwrite = FALSE, type = NULL, verbose = TRUE){

   if (!file.exists(file)) {
    spf("\"%s\" does not exist!", file)
   }

  ext <- tolower(tools::file_ext(file))

  #default to .txt is a doc
  if (!is.null(type)){
    stopifnot(type %in% c("document","spreadsheet","presentation"))
    type <- paste0("application/vnd.google-apps.",type)
  } else {
  if (ext %in% c("doc, docx", "txt", "rtf", "html", "odt", "pdf", "jpeg",
                 "png","gif","bmp")) {
    type <- "application/vnd.google-apps.document"
  } else if (ext %in% c("xls", "xlsx", "csv", "tsv", "tab", "xlsm", "xlt",
                        "xltx", "xltm", "ods")) {
    type <- "application/vnd.google-apps.spreadsheet"
  } else if (ext %in% c("opt", "ppt", "pptx", "pptm")){
    type <- "application/vnd.google-apps.presentation"
  } else {
    spf("We cannot currently upload a file with this extension to Google Drive: %s", ext)
  }
  }

  if (is.null(name)){
    name <- tools::file_path_sans_ext(basename(file))
  }

  id <- NULL

  if (overwrite){
   old_doc <- gd_ls(name, fixed = TRUE, verbose = FALSE)
   if (!is.null(old_doc)){
     id <- old_doc$id[1]
   }
  }

  if (is.null(id)){
    req <- build_request(endpoint = .state$gd_base_url_files_v3,
                         token = gd_token(),
                         params = list("name" = name,
                                       "mimeType" = type),
                         method = "POST")
    res <- make_request(req, encode = "json")
    proc_res <- process_request(res)
    id <- proc_res$id
  }

url <- file.path(.state$gd_base_url, "upload/drive/v3/files", paste0(id, "?uploadType=media"))

req <- build_request(endpoint = url,
                     token = gd_token(),
                     params = list("path" = file,
                                   "type" = type),
                     method = "PATCH"
                     )

res <- make_request(req)
proc_res <- process_request(res)

uploaded_doc <- gd_ls(name, fixed = TRUE, verbose = FALSE)
success <- id == uploaded_doc$id[1]

if (success) {
  if (verbose) {
    message(sprintf("File uploaded to Google Drive: \n%s \nAs the Google %s named:\n%s",
                    file,
                    sub('.*\\.','',type),
                    name))
  }
} else {
  spf("Zoinks! the file doesn't seem to have uploaded")
}

}

