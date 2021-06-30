#' Example files
#'
#' googledrive makes a variety of example files -- both local and remote --
#' available for use in examples and reprexes. These functions help you access
#' the example files. See `vignette("example-files", package = "googledrive")`
#' for more.
#'
#' @param matches A regular expression that matches the name of the desired
#'   example file(s). This argument is optional for the plural forms
#'   (`drive_examples_local()` and `drive_examples_remote()` and, if provided,
#'   multiple matches are allowed. The single forms (`drive_example_local()` and
#'   `drive_example_reomote()` require this argument and require that there is
#'   exactly one match.

#'
#' @return

#' * For `drive_example_local()` and `drive_examples_local()`, one or more local
#' filepaths.

#' * For `drive_example_remote()` and `drive_examples_remote()`, a `dribble`.

#' @name drive_examples
#' @examples
#' drive_examples_remote()
#' drive_examples_remote("chicken")
#' drive_example_remote("chicken_doc")
#'
#' drive_examples_local() %>% basename()
#' drive_examples_local("chicken") %>% basename()
#' drive_example_local("imdb")
NULL

#' @rdname drive_examples
#' @export
drive_examples_local <- function(matches) {
  out <- many_files(
    needle    = matches,
    haystack  = local_example_files(),
    where     = "local"
  )
  out$path
}

#' @rdname drive_examples
#' @export
drive_examples_remote <- function(matches) {
  many_files(
    needle    = matches,
    haystack  = remote_example_files(),
    where     = "remote"
  )
}

#' @rdname drive_examples
#' @export
drive_example_local <- function(matches) {
  out <- one_file(
    needle    = matches,
    haystack  = local_example_files(),
    where     = "local"
  )
  out$path
}

#' @rdname drive_examples
#' @export
drive_example_remote <- function(matches) {
  one_file(
    needle    = matches,
    haystack  = remote_example_files(),
    where     = "remote"
  )
}

many_files <- function(needle, haystack, where = c("local", "remote")) {
  where <- match.arg(where)
  out <- haystack

  if (!missing(needle)) {
    check_needle(needle)
    sel <- grepl(needle, haystack$name, ignore.case = TRUE)
    if (!any(sel)) {
      drive_abort(
        "Can't find a {where} example file with a name that matches \\
        \"{needle}\".")
    }
    out <- haystack[sel, ]
  }

  out
}

one_file <- function(needle, haystack, where) {
  out <- many_files(needle = needle, haystack = haystack, where = where)
  if (nrow(out) > 1) {
    drive_abort(c(
      "Found multiple matching {where} files:",
      bulletize(gargle_map_cli(out$name)),
      i = "Make the {.arg matches} regular expression more specific."
    ))
  }
  out
}

local_example_files <- function() {
  # inlining env_cache() logic, so I don't need bleeding edge rlang
  if (!env_has(.googledrive, "local_example_files")) {
    pths <- list.files(
      system.file(
        "extdata", "example_files",
        package = "googledrive", mustWork = TRUE
      ),
      full.names = TRUE
    )
    env_poke(
      .googledrive,
      "local_example_files",
      tibble(name = basename(pths), path = pths)
    )
  }
  env_get(.googledrive, "local_example_files")
}

remote_example_files <- function() {
  # inlining env_cache() logic, so I don't need bleeding edge rlang
  # TODO: this would be the place to learn the ids of remote example sheets
  # dynamically, if I ever did that
  if (!env_has(.googledrive, "remote_example_files")) {
    dat <- utils::read.csv(
      system.file(
        "extdata", "data", "remote_example_files.csv",
        package = "googledrive", mustWork = TRUE
      ),
      stringsAsFactors = FALSE
    )
    if (!drive_has_token()) { # don't trigger auth just for this
      local_drive_quiet()
      local_deauth()
    }
    env_poke(.googledrive, "remote_example_files", as_dribble(as_id(dat$id)))
  }
  env_get(.googledrive, "remote_example_files")
}

check_needle <- function(needle) {
  if (is_string(needle)) {
    return()
  }
  drive_abort(c(
    "{.arg matches} must be a string, not {.cls class(needle)}"
  ))
}

#' @name googledrive-deprecated
#' @export
drive_example <- function(path = NULL) {
  if (is.null(path)) {
    lifecycle::deprecate_warn("2.0.0", "drive_example()", "drive_examples_local()")
    drive_examples_local()
  } else {
    lifecycle::deprecate_warn("2.0.0", "drive_example()", "drive_example_local()")
    drive_example_local(path)
  }
}
