wrong <- readRDS(rprojroot::find_testthat_root_file("wrong-content.rds"))
right <- readRDS(rprojroot::find_testthat_root_file("right-content.rds"))

test_that("process_request properly errors on wrong content type with default expected type", {

  ## create fake res with the wrong content type
  actual <- wrong$headers$`content-type`
  expect_error(process_request(wrong),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               "application/json; charset=UTF-8",
               actual)
  )
})

test_that("process_request properly errors on wrong content type with inserted expected type", {

  actual = wrong$headers$`content-type`
  expected = "something else"
  expect_error(process_request(wrong, expected = expected),
               sprintf(paste0("Expected content-type:\n%s",
                              "\n",
                              "Actual content-type:\n%s"
               ),
               expected,
               actual)
  )
})

test_that("process_request is okay with correct content type and default expected type", {

  ## should return a list with an element named name
  expect_type(process_request(right), "list")
  expect_length(process_request(right), 1)
  expect_equal(names(process_request(right)), "name")
})

