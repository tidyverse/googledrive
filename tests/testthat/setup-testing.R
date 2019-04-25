CLEAN <- SETUP <- FALSE
isFALSE <- function(x) identical(x, FALSE)

message("Test file naming scheme:\n  * ", nm_fun("TEST-context")("foo"))
