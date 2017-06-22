context("Process responses")

## for testing process_response
## wrong content:
## res <- httr::GET("https://httpbin.org")
## saveRDS(res, rprojroot::find_testthat_root_file("test-files/wrong-content.rds"))
## res <- httr::GET()
##
## right content:
## x <- drive_list()[1,] # grab most recent thing on drive
## url <- httr::modify_url(url = .drive$base_url,
##                         path = paste0("drive/v3/files/",x$id),
##                         query = list(fields = "name"))
## res <- httr::GET(url, drive_token())
## saveRDS(res, rprojroot::find_testthat_root_file("test-files/right-content.rds"))


wrong <- readRDS(rprojroot::find_testthat_root_file("test-files/wrong-content.rds"))
right <- readRDS(rprojroot::find_testthat_root_file("test-files/right-content.rds"))

test_that("stop_for_content_type() catches wrong content type", {
  expect_error(
    stop_for_content_type(wrong),
    "Expected content-type.*Actual content-type"
  )
  expect_error(
    stop_for_content_type(wrong, expected = "whatever"),
    "Expected content-type:\nwhatever.*Actual content-type"
  )
})

test_that("process_response is okay with correct content type and default expected type", {

  ## should return a list with an element named name
  expect_type(process_response(right), "list")
  expect_length(process_response(right), 1)
  expect_equal(names(process_response(right)), "name")
})
