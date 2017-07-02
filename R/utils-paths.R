## path utilities -----------------------------------------------------

## ensure we can interpret x as a single path
confirm_single_path <- function(x) {
  stopifnot(is.character(x), length(x) == 1, !inherits(x, "drive_id"))
  x
}

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

## partitions path into
##   * name = substring after the last `/`
##   * parent = substring up to the last `/`, processed with rootize_path()
## if there is no `/`, put the input into `name`
partition_path <- function(path) {
  out <- list(parent = NULL, name = NULL)
  if (length(path) < 1) {
    return(out)
  }
  confirm_single_path(path)
  path <- rootize_path(path)
  last_slash <- last(unlist(gregexpr(pattern = "/", path)))
  if (last_slash < 1) {
    out[["name"]] <- path
    return(out)
  }
  out[["parent"]] <- substr(path, 1, last_slash)
  if (last_slash == nchar(path)) {
    return(out)
  }
  out[["name"]] <- substr(path, last_slash + 1, nchar(path))
  out
}

## tools::file_ext(), except return NULL for non-extensions
file_ext_safe <- function(x) {
  stopifnot(length(x) <= 1)
  ext <- tools::file_ext(x)
  if (length(ext) > 0 && nzchar(ext)) {
    ext
  } else {
    NULL
  }
}

## add an extension if it is not already present
apply_extension <- function(path, ext) {
  ext_orig <- file_ext_safe(path)
  if (!identical(ext, ext_orig)) {
    path <- paste(path, ext, sep = ".")
  }
  path
}

is_root <- function(path) {
  length(path) == 1 && is.character(path) && grepl("^~$|^/$|^~/$", path)
}

root_folder <- function() drive_get("root")

root_id <- function() root_folder()$id

split_path_name <- function(path, name, verbose = TRUE) {
  if (!is.character(path) || grepl("/$", path)) {
    return(list(path = path, name = name))
  }
  pth <- split_path(path)
  pth_n <- length(pth)
  pth_name <- pth[pth_n]
  path <- NULL
  if (pth_n > 1) {
    path <- collapse(pth[-pth_n], sep = "/")
  }
  if (!is.null(name) && verbose) {
    message(glue("Ignoring `name`: {name}",
                 "\nin favor of name specified in `path`: {pth_name}"))
  }
  name <- pth_name
  list(path = path, name = name)
}
