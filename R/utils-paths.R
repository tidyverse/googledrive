## path utilities -----------------------------------------------------

## turn '~' into `~/`
## turn leading `/` into leading `~/`
rootize_path <- function(path) {
  if (is.null(path)) return(path)
  if (!(is.character(path) && length(path) == 1)) {
    stop("'path' must be a character string.", call. = FALSE)
  }
  sub("^~$|^/", "~/", path)
}

## "a/b/" and "a/b" both return "a/b/"
append_slash <- function(path) {
  if (length(path) < 1 || path == "") return(path)
  ifelse(grepl("/$", path), path, paste0(path, "/"))
}

## "a/b/" and "a/b" both return "a/b"
strip_slash <- function(path) {
  gsub("/$", "", path)
}

split_path <- function(path = "") {
  path <- path %||% ""
  unlist(strsplit(rootize_path(path), "/"))
}

unsplit_path <- function(...) {
  gsub("^/*", "", file.path(...))
}

is_root <- function(path) {
  length(path) == 1 && is.character(path) && grepl("^~$|^/$|^~/$", path)
}

root_folder <- function() drive_get("root")

root_id <- function() root_folder()$id
