sq <- function(x) glue::single_quote(x)
bt <- function(x) glue::backtick(x)

# message <- function(...) {
#   abort("Internal error: use googledrive's UI functions, not {bt('message()')}")
# }

warn_for_verbose <- function(verbose = TRUE, env = parent.frame()) {
  # this is about whether `verbose` was present in the **user's** call to the
  # calling function
  # don't worry about the `verbose = TRUE` default here
  if (!lifecycle::is_present(verbose) || isTRUE(verbose)) {
    return(invisible())
  }

  called_from <- sys.parent(1)
  if (called_from == 0) {
    # called from global env, presumably in a test or during development
    caller <- "some_googledrive_function"
  } else {
    called_as <- sys.call(called_from)
    if (is.call(called_as) && is.symbol(called_as[[1]])) {
      caller <- as.character(called_as[[1]])
    } else {
      caller <- "some_googledrive_function"
    }
  }
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

# keeps wrapping from wreaking havoc on snapshot tests, esp. when I have to
# find and replace volatile bits of text
local_drive_loud_and_wide <- function(cli.width = 85, env = parent.frame()) {
  withr::local_options(list(
    googledrive_quiet = FALSE,
    cli.width = cli.width
  ), .local_envir = env)
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

drive_bullets <- function(text, .envir = parent.frame()) {
  quiet <- drive_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  cli::cli_div(theme = list(
    span.field = list(transform = single_quote_if_no_color),
    # this is so cli_format.dribble controls its own coloring (vs. "blue")
    span.val = list(color = "reset")
  ))
  cli::cli_bullets(text = text, .envir = .envir)
  cli::cli_end()
}

quote_if_no_color <- function(x, quote = "'") {
  # TODO: if a better way appears in cli, use it
  # @gabor says: "if you want to have before and after for the no-color case
  # only, we can have a selector for that, such as:
  # span.field::no-color
  # (but, at the time I write this, cli does not support this yet)
  if (cli::num_ansi_colors() > 1) {
    x
  } else {
    paste0(quote, x, quote)
  }
}

single_quote_if_no_color <- function(x) quote_if_no_color(x, "'")
double_quote_if_no_color <- function(x) quote_if_no_color(x, '"')

#' @export
#' @importFrom cli cli_format
cli_format.dribble <- function(x, ...) {
  confirm_single_file(x)
  # \u00a0 is a nonbreaking space
  id_string <- glue("<id:\u00a0{x$id}>")
  glue("{x$name} {cli::col_grey(id_string)}")
}

cli_format_dribble <- function(x, bullet = "*") {
  confirm_dribble(x)

  n <- nrow(x)
  n_show_nominal <- 5
  if (n > n_show_nominal && n - n_show_nominal > 2) {
    n_show <- n_show_nominal
  } else {
    n_show <- n
  }

  out <- purrr::map_chr(seq_len(n_show), ~ cli_format(x[.x, ]))
  out <- set_names(out, rep_along(out, bullet))
  if (n > n_show) {
    out <- c(out, " " = glue("{cli::symbol$ellipsis} and {n - n_show} more"))
  }
  out
}

# useful to me during development, so I can see how my messages look w/o color
local_no_color <- function(.envir = parent.frame()) {
  withr::local_envvar(c("NO_COLOR" = 1), .local_envir = .envir)
}

with_no_color <- function(code) {
  withr::with_envvar(c("NO_COLOR" = 1), code)
}

# old UI functions ----
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

message_collapse <- function(x) {
  # TODO: temporary fix since I switched to testthat 3e before updating the
  # UI functions
  quiet <- drive_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  message(glue_collapse(x, sep = "\n"))
}

warning_collapse <- function(x) warning(glue_collapse(x, sep = "\n"))
