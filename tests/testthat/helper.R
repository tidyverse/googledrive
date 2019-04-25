if (gargle:::secret_can_decrypt("googledrive")) {
  json <- gargle:::secret_read("googledrive", "googledrive-testing.json")
  drive_auth(path = rawToChar(json))
}

skip_if_no_token <- function() {
  testthat::skip_if_not(have_token(), "No Drive token")
}

nm_fun <- function(context, user = Sys.info()["user"]) {
  y <- purrr::compact(list(context, user))
  function(x) as.character(glue_collapse(c(x, y), sep = "-"))
}
