CLEAN <- SETUP <- FALSE
isFALSE <- function(x) identical(x, FALSE)

drive_bullets(c(
  "Test file naming scheme:",
  "*" = nm_fun("TEST-context")("foo")
))
