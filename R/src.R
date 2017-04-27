#fields
default_fields <- c("appProperties", "capabilities", "contentHints", "createdTime",
            "description", "explicitlyTrashed", "fileExtension",
            "folderColorRgb", "fullFileExtension", "headRevisionId",
            "iconLink", "id", "imageMediaMetadata", "kind",
            "lastModifyingUser", "md5Checksum", "mimeType",
            "modifiedByMeTime", "modifiedTime", "name", "originalFilename",
            "ownedByMe", "owners", "parents", "permissions", "properties",
            "quotaBytesUsed", "shared", "sharedWithMeTime", "sharingUser",
            "size", "spaces", "starred", "thumbnailLink", "trashed",
            "version", "videoMediaMetadata", "viewedByMe", "viewedByMeTime",
            "viewersCanCopyContent", "webContentLink", "webViewLink",
            "writersCanShare")

# fx
spf <- function(...) stop(sprintf(...), call. = FALSE)

#this is directly from googlesheets

#httr helpers

stop_for_content_type <- function(req, expected) {
  actual <- req$headers$`Content-Type`
  if (actual != expected) {
    stop(
      sprintf(
        paste0("Expected content-type:\n%s",
               "\n",
               "Actual content-type:\n%s"),
        expected, actual
      )
    )
  }
  invisible(NULL)
}

content_as_json_UTF8 <- function(req) {
  stop_for_content_type(req, expected = "application/json; charset=UTF-8")
  jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
}

#environment to store credentials
.state <- new.env(parent = emptyenv())
.state$gd_base_url_files_v3 <- "https://www.googleapis.com/drive/v3/files"
.state$gd_base_url <- "https://www.googleapis.com/"

.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googledrive <- list(
    ## httr_oauth_cache can be a path, but I'm only really thinking about and
    ## supporting the simpler TRUE/FALSE usage, i.e. assuming that .httr-oauth
    ## will live in current working directory if it exists at all
    ## this is main reason for creating this googledrive-specific variant
    googledrive.httr_oauth_cache = TRUE,
    googledrive.client_id = "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com",
    googledrive.client_secret = "iWPrYg0lFHNQblnRrDbypvJL",
    googledrive.webapp.client_id = "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com",
    googledrive.webapp.client_secret = "UiF2uCHeMiUH0BeNbSAzzBxL",
    googledrive.webapp.redirect_uri = "http://127.0.0.1:4642"
  )
  toset <- !(names(op.googledrive) %in% names(op))
  if(any(toset)) options(op.googledrive[toset])

  invisible()

}

## from gh
`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}
