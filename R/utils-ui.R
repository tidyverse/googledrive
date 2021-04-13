sq <- function(x) glue::single_quote(x)
bt <- function(x) glue::backtick(x)

# message <- function(...) {
#   abort("Internal error: use googledrive's UI functions, not {bt('message()')}")
# }

warn_for_verbose <- function(verbose = TRUE, env = parent.frame()) {
  if (isTRUE(verbose)) {
    return(invisible())
  }

  called_from <- sys.parent(1)
  if (called_from == 0) {
    # called from global env, presumably in a test or during development
    called_as <- "some_googledrive_function()"
  } else {
    called_as <- deparse(sys.call(called_from))
  }
  caller <- sub("[(].*[)]", "", called_as)
  lifecycle::deprecate_warn(
    when = "2.0.0",
    what = glue("{caller}(verbose)"),
    details = glue("
      Set `options(googledrive_quiet = TRUE)` to suppress all \\
      googledrive messages.
      For finer control, use `local_drive_quiet()` or `with_drive_quiet()`.
      googledrive's `verbose` argument will be removed in the future."),
    id = "googledrive_verbose"
  )
  local_drive_quiet(env = env)
  invisible()
}

drive_quiet <- function() {
  getOption("googledrive_quiet", default = NA)
}

#' @rdname googledrive-configuration
#' @param env The environment to use for scoping
#' @section Messages:
#'
#' The `googledrive_quiet` option can be used to suppress messages from
#' googledrive. By default, googledrive always messages, i.e. it is *not*
#' quiet.
#'
#' Set `googledrive_quiet` to `TRUE` to suppress messages, by one of these
#' means, in order of decreasing scope:
#' * Put `options(googledrive_quiet = TRUE)` in a start-up file, such as
#'   `.Rprofile`, or at the top of your R script
#' * Use `local_drive_quiet()` to silence googledrive in a specific scope
#'   ```
#'   foo <- function() {
#'     ...
#'     local_drive_quiet()
#'     drive_this(...)
#'     drive_that(...)
#'     ...
#'   }
#' * Use `with_drive_quiet()` to run a small bit of code silently
#'   ```
#'   with_drive_quiet(
#'     drive_something(...)
#'   )
#'   ```
#'
#' `local_drive_quiet()` and `with_drive_quiet()` follow the conventions of the
#' the withr package (<https://withr.r-lib.org>).
#'
#' @export
#' @examples
#' if (drive_has_token()) {
#'   # message: "Created Drive file"
#'   (x <- drive_create("drive-quiet-demo", type = "document"))
#'
#'   # message: "File updated"
#'   x <- drive_update(x, starred = TRUE)
#'   purrr::pluck(x, "drive_resource", 1, "starred")
#'
#'   # suppress messages for a small amount of code
#'   with_drive_quiet(
#'     x <- drive_update(x, name = "drive-quiet-works")
#'   )
#'   x$name
#'
#'   # message: "File updated"
#'   x <- drive_update(x, media = drive_example("chicken.txt"))
#'
#'   # suppress messages within a specific scope, e.g. function
#'   unstar <- function(y) {
#'     local_drive_quiet()
#'     drive_update(y, starred = FALSE)
#'   }
#'   x <- unstar(x)
#'   purrr::pluck(x, "drive_resource", 1, "starred")
#'
#'   # clean up
#'   drive_trash(x)
#'   rm(unstar)
#' }
local_drive_quiet <- function(env = parent.frame()) {
  withr::local_options(list(googledrive_quiet = TRUE), .local_envir = env)
}

local_drive_loud <- function(env = parent.frame()) {
  withr::local_options(list(googledrive_quiet = FALSE), .local_envir = env)
}

#' @rdname googledrive-configuration
#' @param code Code to execute quietly
#' @export
with_drive_quiet <- function(code) {
  withr::with_options(list(googledrive_quiet = TRUE), code = code)
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                           call. = FALSE, .domain = NULL) {
  stop(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_collapse <- function(x) stop(glue_collapse(x, sep = "\n"), call. = FALSE)

message_glue <- function(..., .sep = "", .envir = parent.frame(),
                         .domain = NULL, .appendLF = TRUE) {
  # TODO: temporary fix since I switched to testthat 3e before updating the
  # UI functions
  quiet <- drive_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  message(
    glue(..., .sep = .sep, .envir = .envir),
    domain = .domain, appendLF = .appendLF
  )
}

message_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              .domain = NULL) {
  # TODO: temporary fix since I switched to testthat 3e before updating the
  # UI functions
  quiet <- drive_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  message(
    glue_data(..., .sep = .sep, .envir = .envir),
    domain = .domain
  )
}

message_collapse <- function(x) {
  # TODO: temporary fix since I switched to testthat 3e before updating the
  # UI functions
  quiet <- drive_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  message(glue_collapse(x, sep = "\n"))
}

warning_glue <- function(..., .sep = "", .envir = parent.frame(),
                         call. = FALSE, .domain = NULL) {
  warning(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              call. = FALSE, .domain = NULL) {
  warning(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_collapse <- function(x) warning(glue_collapse(x, sep = "\n"))
