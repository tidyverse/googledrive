# readLines <- function(...) {
#   drive_abort("In this house, we use ??? for UTF-8 reasons.")
# }

writeLines <- function(...) {
  drive_abort("In this house, we use {.fun write_utf8} for UTF-8 reasons.")
}

# https://github.com/gaborcsardi/rencfaq#with-base-r
write_utf8 <- function(text, path = NULL) {
  # sometimes we use writeLines() basically to print something for a snapshot
  if (is.null(path)) {
    return(base::writeLines(text))
  }

  # step 1: ensure our text is utf8 encoded
  utf8 <- enc2utf8(text)
  upath <- enc2utf8(path)

  # step 2: create a connection with 'native' encoding
  # this signals to R that translation before writing
  # to the connection should be skipped
  con <- file(upath, open = "w+", encoding = "native.enc")
  withr::defer(close(con))

  # step 3: write to the connection with 'useBytes = TRUE',
  # telling R to skip translation to the native encoding
  base::writeLines(utf8, con = con, useBytes = TRUE)
}

# used for building functions that construct Drive file names in tests ----
nm_fun <- function(context, user_run = TRUE) {
  user_run <- if (isTRUE(user_run)) nm_user_run() else NULL
  y <- purrr::compact(list(context, user_run))
  function(x = character()) as.character(glue_collapse(c(x, y), sep = "-"))
}

nm_user_run <- function() {
  if(as.logical(Sys.getenv("GITHUB_ACTIONS", unset = "false"))) {
    glue("gha-{Sys.getenv('GITHUB_WORKFLOW')}-{Sys.getenv('GITHUB_RUN_ID')}")
  } else {
    random_id <- strsplit(uuid::UUIDgenerate(TRUE), "-")[[1]][[1]]
    glue("{Sys.info()['user']}-{random_id}")
  }
}
