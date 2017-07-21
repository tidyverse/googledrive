## path utilities that are "mechanical"

is_path <- function(x) is.character(x) && !inherits(x, "drive_id")

is_rootpath <- function(path) {
  length(path) == 1 && is.character(path) && grepl("^~$|^/$|^~/$", path)
}

is_rooted <- function(path) grepl("^~", path)

## turn '~' into `~/`
## turn leading `/` into leading `~/`
rootize_path <- function(path) {
  if (length(path) == 0) return(path)
  stopifnot(is.character(path))
  sub("^~$|^/", "~/", path)
}

## does path have a trailing slash?
has_slash <- function(path) {
  grepl("/$", path)
}

## "a/b/" and "a/b" both return "a/b/"
append_slash <- function(path) {
  if (length(path) < 1 || path == "") return(path)
  ifelse(has_slash(path), path, paste0(path, "/"))
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
## use maybe_name if you have external info re: how to interpret the path
## maybe_name = TRUE --> path could end in a name
## maybe_name = FALSE --> path is known to be a directory
partition_path <- function(path, maybe_name = FALSE) {
  out <- list(parent = NULL, name = NULL)
  if (length(path) < 1) {
    return(out)
  }
  stopifnot(is_path(path), length(path) == 1)
  path <- rootize_path(path)
  if (!maybe_name) {
    path <- append_slash(path)
  }
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

confirm_clear_path <- function(path, name) {
  if (is.null(name) && !has_slash(path) && drive_path_exists(append_slash(path))) {
    stop(
      "Unclear if `path` specifies parent folder or full path\n",
      "to the new file, including its name. ",
      "See ?as_dribble() for details.",
      call. = FALSE
    )
  }
}
