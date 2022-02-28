# path utilities that CAN call the Drive API ----
root_folder <- function() {
  # inlining env_cache() logic, so I don't need bleeding edge rlang
  if (!env_has(.googledrive, "root_folder")) {
    env_poke(.googledrive, "root_folder", drive_get(id = "root"))
  }
  env_get(.googledrive, "root_folder")
}
root_id <- function() root_folder()$id

rationalize_path_name <- function(path = NULL, name = NULL) {
  if (!is.null(name)) {
    stopifnot(is_string(name))
  }

  if (is_path(path)) {
    confirm_clear_path(path, name)
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  list(path = path, name = name)
}

confirm_clear_path <- function(path, name) {
  if (is.null(name) &&
    !has_slash(path) &&
    drive_path_exists(append_slash(path))) {
    drive_abort(c(
      "Unclear if {.arg path} specifies parent folder or full path \\
       to the new file, including its name.",
      "See {.fun ?as_dribble} for advice on how to make this clear."
    ))
  }
}

drive_path_exists <- function(path) {
  stopifnot(is_path(path))
  if (length(path) == 0) {
    return(logical(0))
  }
  stopifnot(length(path) == 1)
  with_drive_quiet(
    some_files(drive_get(path = path))
  )
}

# `parent` is NULL or the file ID of a folder
check_for_overwrite <- function(parent = NULL, name, overwrite) {
  hits <- overwrite_hits(parent = parent, name = name, overwrite = overwrite)

  # Happy Path 1 of 2: no name collision
  if (is.null(hits) || no_file(hits)) {
    return(invisible())
  }

  # Happy Path 2 of 2: single name collision, which we are authorized to trash
  if (overwrite && single_file(hits)) {
    return(drive_trash(hits))
  }

  # Unhappy Paths: multiple collisions and/or not allowed to trash anything
  hits <- drive_reveal(hits, "path")

  if (overwrite) {
    drive_abort(c(
      "Multiple items already exist at the target filepath.",
      bulletize(gargle_map_cli(hits, bullet = "x")),
      "Although {.code overwrite = TRUE}, it's not clear which item \\
       to overwrite.",
      "Use {.code overwrite = NA} to suppress this check. Exiting."
    ))
  } else {
    drive_abort(c(
      # \u00a0 is a nonbreaking space
      "{nrow(hits)} item{?s} already exist{?s/} at the target filepath \\
       and {.code overwrite\u00a0=\u00a0FALSE}:",
      bulletize(gargle_map_cli(hits, bullet = "x"))
    ))
  }
}

overwrite_hits <- function(parent = NULL, name, overwrite) {
  stopifnot(is_toggle(overwrite))
  if (is.na(overwrite)) {
    return(invisible())
  }

  parent_id <- parent %||% root_id()
  q <- c(
    glue("'{parent_id}' in parents"),
    glue("name = '{name}'"),
    "trashed = FALSE"
  )
  # suppress drive_find() status updates
  local_drive_quiet()
  drive_find(q = q, corpus = "allDrives")
}

# path utilities that are "mechanical", i.e. they NEVER call the Drive API ----
dribble_with_path <- function() {
  put_column(dribble(), nm = "path", val = character(), .after = "name")
}

is_path <- function(x) is.character(x) && !is_drive_id(x)

is_string <- function(x) length(x) == 1L && is_path(x)

# turn '~' into `~/`
rootize_path <- function(path) {
  if (length(path) == 0) {
    return(path)
  }
  stopifnot(is.character(path))
  leading_slash <- startsWith(path, "/")
  if (any(leading_slash)) {
    drive_abort("{.pkg googledrive} does not allow paths to start with {.code /}")
  }
  sub("^~$", "~/", path)
}

## does path have a trailing slash?
has_slash <- function(path) {
  grepl("/$", path)
}

## "a/b/" and "a/b" both return "a/b/"
append_slash <- function(path) {
  if (length(path) < 1) {
    return(path)
  }
  ifelse(has_slash(path) | path == "", path, paste0(path, "/"))
}

## "a/b/" and "a/b" both return "a/b"
strip_slash <- function(path) {
  gsub("/$", "", path)
}

# partitions path into
#   * name = substring after the last `/`
#   * parent = substring up to the last `/`
# if there is no `/`, put the input into `name`
# use maybe_name if you have external info re: how to interpret the path
# maybe_name = TRUE --> path could end in a name
# maybe_name = FALSE --> path is known to be a directory
partition_path <- function(path, maybe_name = FALSE) {
  out <- list(parent = NULL, name = NULL)
  if (length(path) < 1) {
    return(out)
  }
  stopifnot(is_string(path))
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
