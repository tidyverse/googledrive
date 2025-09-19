# ---
# repo: r-lib/rlang
# file: standalone-types-check.R
# last-updated: 2023-03-13
# license: https://unlicense.org
# dependencies: none (simplified version for googledrive)
# imports: rlang (>= 1.1.0)
# ---
#
# This is a simplified version of the rlang standalone types-check
# focusing only on the functions needed by googledrive

# nocov start

check_bool <- function(
  x,
  ...,
  allow_na = TRUE,
  allow_null = FALSE,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (!missing(x)) {
    if (allow_null && is.null(x)) {
      return(invisible(NULL))
    }
    if (length(x) == 1L && is.logical(x)) {
      if (allow_na || !is.na(x)) {
        return(invisible(NULL))
      }
    }
  }

  # Create error message based on what we allow
  expected <- "`TRUE` or `FALSE`"
  if (allow_na) {
    expected <- paste(expected, "or `NA`")
  }
  if (allow_null) {
    expected <- paste(expected, "or `NULL`")
  }

  rlang::abort(
    message = paste0("`", arg, "` must be ", expected, "."),
    ...,
    call = call
  )
}

check_string <- function(
  x,
  ...,
  allow_empty = TRUE,
  allow_na = FALSE,
  allow_null = FALSE,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (!missing(x)) {
    if (allow_null && is.null(x)) {
      return(invisible(NULL))
    }
    if (length(x) == 1L && is.character(x)) {
      if (allow_na && is.na(x)) {
        return(invisible(NULL))
      }
      if (!is.na(x) && (allow_empty || nzchar(x))) {
        return(invisible(NULL))
      }
    }
  }

  # Create error message
  expected <- "a single string"
  if (!allow_empty) {
    expected <- "a single non-empty string"
  }
  if (allow_na) {
    expected <- paste(expected, "or `NA`")
  }
  if (allow_null) {
    expected <- paste(expected, "or `NULL`")
  }

  rlang::abort(
    message = paste0("`", arg, "` must be ", expected, "."),
    ...,
    call = call
  )
}

# nocov end
