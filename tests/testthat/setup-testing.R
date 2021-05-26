CLEAN <- SETUP <- FALSE
isFALSE <- function(x) identical(x, FALSE)

with_drive_loud({
  nm_ <- nm_fun("TEST-drive_something", user_run = FALSE)
  me_ <- nm_fun("TEST-drive_something")

  drive_bullets(c(
    "Test file naming scheme:",
    "*" = nm_("foo"),
    "*" = me_("foo")
  ))
  flush.console()
  Sys.sleep(1) # without this, the message still gets mixed in w/ test results
})
