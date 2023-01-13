drive_theme <- function() {
  list(
    span.field = list(transform = single_quote_if_no_color),
    # I want to style the Drive file names similar to cli's `.file` style,
    # except cyan instead of blue
    span.drivepath = list(
      color = "cyan",
      fmt = utils::getFromNamespace("quote_weird_name", "cli")
    ),
    # since we're using color so much elsewhere, e.g. Drive file names, I think
    # the standard bullet should be "normal" color
    ".memo .memo-item-*" = list(
      "text-exdent" = 2,
      before = function(x) paste0(cli::symbol$bullet, " ")
    )
  )
}

drive_bullets <- function(text, .envir = parent.frame()) {
  quiet <- drive_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  cli::cli_div(theme = drive_theme())
  cli::cli_bullets(text = text, .envir = .envir)
}

drive_abort <- function(message, ..., .envir = parent.frame()) {
  cli::cli_div(theme = drive_theme())
  cli::cli_abort(message = message, ..., .envir = .envir)
}

drive_warn <- function(message, ..., .envir = parent.frame()) {
  cli::cli_div(theme = drive_theme())
  cli::cli_warn(message = message, ..., .envir = .envir)
}

single_quote_if_no_color <- function(x) quote_if_no_color(x, "'")
double_quote_if_no_color <- function(x) quote_if_no_color(x, '"')

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

# useful to me during development, so I can see how my messages look w/o color
local_no_color <- function(.envir = parent.frame()) {
  withr::local_envvar(c("NO_COLOR" = 1), .local_envir = .envir)
}

with_no_color <- function(code) {
  withr::with_envvar(c("NO_COLOR" = 1), code)
}

#' @export
gargle_map_cli.dribble <- function(x,
                                   template = NULL,
                                   .open = "<<", .close = ">>",
                                   ...) {
  # template can be a vector, in case some intermediate constructions are needed
  # this is true for the default case
  # templates should assume a data mask of `x`
  template <- template %||%
    c(
      id_string = "<id:\u00a0<<id>>>", # \u00a0 is a nonbreaking space
      out = "{.drivepath <<name>>} {cli::col_grey('<<id_string>>')}"
    )
  stopifnot(is.character(template))

  # if the template has length 1, I don't care if last element is named "out"
  stopifnot(length(template) == 1 || utils::tail(names(template), 1) == "out")

  for (i in seq_len(length(template) - 1)) {
    x[names(template)[[i]]] <-
      with(x, glue(template[[i]], .open = .open, .close = .close))
  }
  with(
    x,
    as.character(glue(utils::tail(template, 1), .open = .open, .close = .close))
  )
}

# making googldrive quiet vs. loud ----
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

#' @examplesIf drive_has_token()
#' # message: "Created Drive file"
#' (x <- drive_create("drive-quiet-demo", type = "document"))
#'
#' # message: "File updated"
#' x <- drive_update(x, starred = TRUE)
#' drive_reveal(x, "starred")
#'
#' # suppress messages for a small amount of code
#' with_drive_quiet(
#'   x <- drive_update(x, name = "drive-quiet-works")
#' )
#' x$name
#'
#' # message: "File updated"
#' x <- drive_update(x, media = drive_example_local("chicken.txt"))
#'
#' # suppress messages within a specific scope, e.g. function
#' unstar <- function(y) {
#'   local_drive_quiet()
#'   drive_update(y, starred = FALSE)
#' }
#' x <- unstar(x)
#' drive_reveal(x, "starred")
#'
#' # Clean up
#' drive_rm(x)
local_drive_quiet <- function(env = parent.frame()) {
  withr::local_options(list(googledrive_quiet = TRUE), .local_envir = env)
}

local_drive_loud <- function(env = parent.frame()) {
  withr::local_options(list(googledrive_quiet = FALSE), .local_envir = env)
}

# keeps wrapping from wreaking havoc on snapshot tests, esp. when I have to
# find and replace volatile bits of text
local_drive_loud_and_wide <- function(cli.width = 150, env = parent.frame()) {
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

with_drive_loud <- function(code) {
  withr::with_options(list(googledrive_quiet = FALSE), code = code)
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

# dealing with how we've communicated in the past ---

sq <- function(x) glue::single_quote(x)
bt <- function(x) glue::backtick(x)

message <- function(...) {
  drive_abort("
    Internal error: use the UI functions in {.pkg googledrive} \\
    instead of {.fun message}")
}

warn_for_verbose <- function(verbose = TRUE,
                             env = caller_env(),
                             user_env = caller_env(2)) {
  # This function is not meant to be called directly, so don't worry about its
  # default of `verbose = TRUE`.
  # In authentic, indirect usage of this helper, this picks up on whether
  # `verbose` was present in the **user's** call to the calling function.
  if (!lifecycle::is_present(verbose) || isTRUE(verbose)) {
    return(invisible())
  }

  lifecycle::deprecate_warn(
    when = "2.0.0",
    what = I("The `verbose` argument"),
    details = c(
      "Set `options(googledrive_quiet = TRUE)` to suppress all googledrive messages.",
      "For finer control, use `local_drive_quiet()` or `with_drive_quiet()`.",
      "googledrive's `verbose` argument will be removed in the future."
    ),
    user_env = user_env,
    always = identical(env, global_env()),
    id = "googledrive_verbose"
  )
  # only set the option during authentic, indirect usage
  if (!identical(env, global_env())) {
    local_drive_quiet(env = env)
  }
  invisible()
}
