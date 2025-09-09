.onLoad <- function(libname, pkgname) {
  # .auth is created in R/drive_auth.R
  # this is to insure we get an instance of gargle's AuthState using the
  # current, locally installed version of gargle
  utils::assignInMyNamespace(
    ".auth",
    gargle::init_AuthState(package = "googledrive", auth_active = TRUE)
  )

  if (identical(Sys.getenv("IN_PKGDOWN"), "true")) {
    tryCatch(
      drive_auth_docs(),
      googledrive_auth_internal_error = function(e) NULL
    )
  }

  # in rlang 0.4.10, `is_installed()` doesn't have `version` arg yet
  if (is_installed("dplyr") && utils::packageVersion("dplyr") >= "1.0.0") {
    s3_register(
      "dplyr::dplyr_reconstruct",
      "dribble",
      method = dribble_maybe_reconstruct
    )
  }

  invisible()
}

release_bullets <- function() {
  c(
    '`devtools::build_rmd("index.Rmd")`'
  )
}
