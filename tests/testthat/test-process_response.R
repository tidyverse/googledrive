context("Process responses")

# ---- other ----
## how the testing files were made:
## for testing process_response()
## wrong content:
## res <- httr::GET("https://httpbin.org")
## saveRDS(res, rprojroot::find_testthat_root_file("test-files/wrong-content.rds"))
##
## right content:
## x <- drive_find()[1, ] # grab most recent thing on drive
## request <- request_generate(
##   endpoint = "drive.files.get",
##   params = list(
##     fileId = x$id,
##     fields = "*"
##   )
## )
## res <- request_make(request)
## saveRDS(res, rprojroot::find_testthat_root_file("test-files/right-content.rds"))

# ---- tests ----
wrong <- readRDS(rprojroot::find_testthat_root_file("test-files/wrong-content.rds"))
right <- readRDS(rprojroot::find_testthat_root_file("test-files/right-content.rds"))

test_that("stop_for_content_type() catches wrong content type", {
  expect_error(
    stop_for_content_type(wrong),
    "\nExpected content-type.*Actual content-type"
  )
  expect_error(
    stop_for_content_type(wrong, expected = "whatever"),
    "\nExpected content-type"
  )
})

test_that("process_response() brings JSON is as list", {
  expect_type(process_response(right), "list")
})
