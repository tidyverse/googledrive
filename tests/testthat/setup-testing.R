CLEAN <- SETUP <- FALSE
isFALSE <- function(x) identical(x, FALSE)

## call skip_if_no_token() once here, so message re: token is not muffled
## by test_that()
tryCatch(skip_if_no_token(), skip = function(x) NULL)

message("Test file naming scheme:\n  * ", nm_fun("TEST-context")("foo"))
