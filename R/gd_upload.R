#' Upload a file to Google Drive
#'
#' @param file character, path the the file you'd like to upload
#' @param name character, what you'd like the uploaded file to be called on Google Drive
#' @param overwrite logical, do you want to overwrite file already on Google Drive
#' @param type if type = `NULL`, will force type as follows:
#'  * **document**: .doc, .docx, .txt, .rtf., .html, .odt, .pdf, .jpeg, .png, .gif,.bmp
#'  * **spreadsheet**: .xls, .xlsx, .csv, .tsv, .tab, .xlsm, .xlt, .xltx, .xltm,
#' .ods
#'  * **presentation**: .opt, .ppt, .pptx, .pptm
#'  otherwise you can specify `document`, `spreadsheet`, or `presentation`. Files with no extension will be assumed to be a `folder`
#'
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return object of class `drive_file` and `list` that contains uploaded file's information
#' @export
gd_upload <- function(file = NULL, name = NULL, overwrite = FALSE, type = NULL, verbose = TRUE){

request <- build_gd_upload(file = file, name = name, overwrite = overwrite, type = type, verbose = verbose)

if (inherits(request, "drive_file")) return(invisible(request))

response <- make_request(request)
process_gd_upload(response = response, file = file, verbose = verbose)

}

build_gd_upload <- function(file = NULL, name = NULL, overwrite = FALSE, type = NULL, verbose = TRUE, internet = TRUE){
  if (!file.exists(file)) {
    spf("\"%s\" does not exist!", file)
  }

  ext <- tolower(tools::file_ext(file))

  #default to .txt is a doc
  if (!is.null(type)){
    stopifnot(type %in% c("document","spreadsheet","presentation","folder"))
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
    } else if (ext == ""){
      type <- "application/vnd.google-apps.folder"
    } else {
      spf("We cannot currently upload a file with this extension to Google Drive: %s", ext)
    }
  }

  if (type == "application/vnd.google-apps.folder" & overwrite){
    spf("You are not able to overwrite a folder, please set `overwrite = FALSE`")
  }
  if (is.null(name)){
    name <- tools::file_path_sans_ext(basename(file))
  }

  id <- NULL

  if (overwrite & internet){
    old_doc <- gd_ls(name, fixed = TRUE, verbose = FALSE)
    if (!is.null(old_doc)){
      id <- old_doc$id[1]
    }
  }

  if (is.null(id) & internet){

    url <- .state$gd_base_url_files_v3

    req <- build_request(endpoint = url,
                         token = gd_token(),
                         params = list(name = name,
                                       mimeType = type),
                         method = "POST")
    res <- make_request(req, encode = "json")
    proc_res <- process_request(res)
    id <- proc_res$id
  }

  if (type == "application/vnd.google-apps.folder" & internet){
    success <- proc_res$id == gd_get_id(name, fixed = TRUE)

    if (success) {
      if (verbose) {
        message(sprintf("File uploaded to Google Drive: \n%s \nAs the Google %s named:\n%s",
                        file,
                        sub('.*\\.','',proc_res$mimeType),
                        proc_res$name))
      }
    } else {
      spf("Zoinks! the file doesn't seem to have uploaded")
    }

    return(invisible(gd_file(proc_res$id)))
  }

  url <- file.path(.state$gd_base_url, "upload/drive/v3/files", paste0(id, "?uploadType=media"))

  build_request(endpoint = url,
                token = gd_token(),
                params = httr::upload_file(path = file, type = type),
                method = "PATCH")

}

process_gd_upload <- function(response = NULL, file = NULL, name = NULL, verbose = TRUE){
  proc_res <- process_request(response)

  uploaded_doc <- gd_file(proc_res$id)
  success <- proc_res$id == uploaded_doc$id[1]

  if (success) {
    if (verbose) {
      message(sprintf("File uploaded to Google Drive: \n%s \nAs the Google %s named:\n%s",
                      file,
                      sub('.*\\.','',proc_res$mimeType),
                      proc_res$name))
    }
  } else {
    spf("Zoinks! the file doesn't seem to have uploaded")
  }

  invisible(uploaded_doc)
}
