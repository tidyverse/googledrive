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

test_that("process_response properly errors on wrong content type with default expected type", {

  ## create fake res with the wrong content type
  actual <- wrong$headers$`content-type`
  expect_error(process_response(wrong),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               "application/json; charset=UTF-8",
               actual)
  )
})

test_that("process_response properly errors on wrong content type with inserted expected type", {

  actual = wrong$headers$`content-type`
  expected = "something else"
  expect_error(process_response(wrong, expected = expected),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               expected,
               actual)
  )
})

test_that("process_response is okay with correct content type and default expected type", {

  ## should return a list with an element named name
  expect_type(process_response(right), "list")
  expect_length(process_response(right), 1)
  expect_equal(names(process_response(right)), "name")
})

