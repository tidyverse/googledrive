#' Upload a file to Google Drive
#'
#' @param input character, path (on your computer) of the file you'd like to upload
#' @param output character, path (on your Google Drive) where you'd like to upload
#'   the file
#' @param overwrite logical, do you want to overwrite file already on Google
#'   Drive
#' @param type if type = `NULL`, will force type as follows:
#' * **document**: .doc, .docx, .txt, .rtf., .html, .odt, .pdf, .jpeg, .png, .gif,.bmp
#' * **spreadsheet**: .xls, .xlsx, .csv, .tsv, .tab, .xlsm, .xlt, .xltx, .xltm,
#'   .ods
#' * **presentation**: .opt, .ppt, .pptx, .pptm
#'
#'  otherwise you can specify `document`, `spreadsheet`, or `presentation`. Files with no extension will
#'   be assumed to be a `folder`
#' @param ... name-value pairs to query the API
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return object of class `gfile` and `list` that contains uploaded file's
#'   information
#' @export
drive_upload <- function(input = NULL,
                         output = NULL,
                         overwrite = FALSE,
                         type = NULL,
                         ...,
                         verbose = TRUE) {
  request <- build_drive_upload(
    input = input,
    output = output,
    overwrite = overwrite,
    type = type,
    ...,
    verbose = verbose
  )

  response <- make_request(request, encode = "json")
  process_drive_upload(response = response,
                       input = input,
                       verbose = verbose)

}

build_drive_upload <- function(input = NULL,
                               output = NULL,
                               overwrite = FALSE,
                               type = NULL,
                               ...,
                               verbose = TRUE,
                               token = drive_token(),
                               internet = TRUE) {
  if (!file.exists(input)) {
    spf("'%s' does not exist!", input)
  }

  ext <- tolower(tools::file_ext(input))

  #default to .txt is a doc
  if (!is.null(type)) {
    stopifnot(type %in% c("document", "spreadsheet", "presentation", "folder"))
    type <- paste0("application/vnd.google-apps.", type)
  } else {
    if (ext %in% c("doc, docx",
                   "txt",
                   "rtf",
                   "html",
                   "odt",
                   "pdf",
                   "jpeg",
                   "png",
                   "gif",
                   "bmp")) {
      type <- "application/vnd.google-apps.document"
    } else if (ext %in% c("xls",
                          "xlsx",
                          "csv",
                          "tsv",
                          "tab",
                          "xlsm",
                          "xlt",
                          "xltx",
                          "xltm",
                          "ods")) {
      type <- "application/vnd.google-apps.spreadsheet"
    } else if (ext %in% c("opt", "ppt", "pptx", "pptm")) {
      type <- "application/vnd.google-apps.presentation"
    } else if (ext == "") {
      type <- "application/vnd.google-apps.folder"
    } else {
      # spf("We cannot currently upload a file with this extension to Google Drive: %s",
      #     ext)
      type = NULL
    }
  }

  if (!is.null(type)) {
    if (type == "application/vnd.google-apps.folder" & overwrite) {
      spf("You are not able to overwrite a folder, please set `overwrite = FALSE`")
    }
  }

  if (is.null(output)) {
    output <- basename(input)
    if (!is.null(type)){
      output <- tools::file_path_sans_ext(basename(input))
    }
  }

  #split the output into the name & the folder
  path_pieces <- unlist(strsplit(output, "/"))
  d <- length(path_pieces)
  name <- path_pieces[d]

  id <- NULL

  if (overwrite & internet) {
    path <- "~"
    if (d > 1) {
      path <- paste(path_pieces[seq_len(d - 1)],
                    collapse = "/")
    }
    old_doc <- drive_list(path = path,
                          pattern = paste0("^", name, "$"),
                          verbose = FALSE)
    if (!is.null(old_doc)) {
      id <- old_doc$id[1]
    }
  }


  if (is.null(id) & internet) {

    parent <- NULL
    # if there are folders defined
    if (d > 1) {
      leafmost <- path_pieces[d - 1]

      upper_folders <- "~"

      if (d > 2) {
        upper_folders <- paste(path_pieces[seq_len(d - 2)],
                               collapse = "/")
      }

      leafmost_tbl <- drive_list(path = upper_folders,
                                 pattern = paste0("^", leafmost, "$"))

      if (nrow(leafmost_tbl) != 1){
        spf("We could not find a unique folder named '%s' in the path '%s' on your Google Drive.",
            leafmost,
            upper_folders)
      }

      parent <- leafmost_tbl$id
    }

    url <- .drive$base_url_files_v3

    req <- build_request(
      endpoint = url,
      token = token,
      params = list(name = name,
                    parents = list(parent),
                    mimeType = type
      ),
      method = "POST"
    )

    # if we are just uploading a folder, we are finished,
    if (!is.null(type)) {
      if (type == "application/vnd.google-apps.folder" & internet) {
        return(res)
      }
    }

    res <- make_request(req, encode = "json")
    proc_res <- process_request(res)
    id <- proc_res$id
  }

  url <- file.path(.drive$base_url,
                   "upload/drive/v3/files",
                   paste0(id, "?uploadType=media"))

  list(
    method = "PATCH",
    url = url,
    token = token,
    body = httr::upload_file(path = input,
                             type = type),
    query = list(...)
  )

}

process_drive_upload <- function(response = NULL,
                                 input = NULL,
                                 verbose = TRUE) {
  proc_res <- process_request(response)

  uploaded_doc <- drive_file(proc_res$id)
  success <- proc_res$id == uploaded_doc$id[1]

  if (success) {
    if (verbose) {
      message(
        sprintf(
          "File uploaded to Google Drive: \n%s \nAs the Google %s named:\n%s",
          input,
          sub(".*\\.", "", proc_res$mimeType),
          proc_res$name
        )
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have uploaded")
  }

  invisible(uploaded_doc)
}
