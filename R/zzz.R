.onLoad <- function(libname, pkgname) {

  .auth <<- gargle::init_AuthState(
    package     = "googledrive",
    auth_active = TRUE
  )

  if (identical(Sys.getenv("IN_PKGDOWN"), "true")) {
    tryCatch(
      drive_auth_docs(),
      googledrive_auth_internal_error = function(e) NULL
    )
  }

  if (is_installed("dplyr", version = "1.0.0")) {
    vctrs::s3_register(
      "dplyr::dplyr_reconstruct",
      "dribble",
      method = dribble_maybe_reconstruct
    )
  }

  invisible()
}
