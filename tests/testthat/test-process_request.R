test_that("process_request properly errors on wrong content type", {

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

  ## let's try if I feed it an expected type
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

  ## let's try it if it's okay
  actual = "application/json; charset=UTF-8"
  res <- list(headers = list("content-type" = actual))

  ## should return NULL
  expect_equal(process_request(res, internet = FALSE), NULL)

  ## also if we set a new expectation
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

test_that("process_request properly errors on wrong content type", {

  skip_on_appveyor()
  skip_on_travis()

  ## something we know won't be correct
  res <- httr::GET("http://livefreeordichotomize.com")

  expected = "application/json; charset=UTF-8"
  actual = res$headers$`content-type`
  ## let's make sure our test is actually good, this should be true
  expect_true(actual != expected)

  expect_error(process_request(res),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               expected,
               actual)
  )

  x <- drive_list()[1,] # grab most recent thing on drive

  ## should just pull the name
  url <- httr::modify_url(url = .drive$base_url,
                          path = paste0("drive/v3/files/",x$id),
                          query = list(fields = "name"))

  res <- httr::GET(url, drive_token())

  ## this should just be a list 2 one element, name
  proc_res <- process_request(res)
  expect_equal(proc_res, list(name = x$name))

})

