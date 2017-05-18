test_that("process_request properly errors on wrong content type with default expected type", {

  ## create fake res with the wrong content type
  actual <- "test"
  res <- list(headers = list("content-type" = actual))
  expect_error(process_request(res, internet = FALSE),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               "application/json; charset=UTF-8",
               actual)
  )
})

test_that("process_request properly errors on wrong content type with inserted expected type", {

  actual = "test"
  expected = "something else"
  res <- list(headers = list("content-type" = actual))
  expect_error(process_request(res, expected = expected, internet = FALSE),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               expected,
               actual)
  )
})
test_that("process_request is okay with correct content type and default expected type", {

  actual = "application/json; charset=UTF-8"
  res <- list(headers = list("content-type" = actual))

  ## should return NULL
  expect_equal(process_request(res, internet = FALSE), NULL)
})

test_that("process_request is okay with correct content type and given expected type", {

  actual = "test"
  expected = "test"
  res <- list(headers = list("content-type" = actual))

  ## should return NULL
  expect_equal(process_request(res,
                               expected = expected,
                               internet = FALSE),
               NULL)

})

## testing on the API

test_that("process_request properly errors on wrong content type (API)", {

  skip_on_appveyor()
  skip_on_travis()

  ## something we know won't be correct
  res <- httr::GET("https://httpbin.org")

  expected = "application/json; charset=UTF-8"
  actual = res$headers$`content-type`
  ## let's make sure our test is actually good, this should be true
  expect_false(identical(actual, expected))

  expect_error(process_request(res),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               expected,
               actual)
  )
})
