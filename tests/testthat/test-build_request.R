test_that("build_request default works properly", {

  ## by default, it should give the endpoint drive.files.list

  req <- build_request()
  expect_type(req, "list") ## should be a list
  expect_length(req, 10) ## should have 10 elements
  expect_identical(req$endpoint, "drive.files.list")
  expect_identical(req$verb, "GET")
  expect_identical(req$url, "https://www.googleapis.com/drive/v3/files")

})

test_that("build_request messages effectively single incorrect input", {
  ## the only piece that is "user facing" is you can supply
  ## parameters to the ...

  ## if we give a crazy parameter that isn't found in our
  ## master tibble, housed in .drive$params, we should error
  params <- list(chicken = "muffin")
  expect_message(build_request(params = params),
                 paste(
                   c(
                     "Ignoring these unrecognized parameters:",
                     glue::glue_data(
                       tibble::enframe(params),
                       "{name}: {value}"
                     )
                   ),
                   collapse = "\n")
  )
})

test_that("build_request messages effectively multiple incorrect inputs", {
  params <- list(chicken = "muffin",
                 bunny = "pippin")
  expect_message(build_request(params = params),
                 paste(
                   c(
                     "Ignoring these unrecognized parameters:",
                     glue::glue_data(
                       tibble::enframe(params),
                       "{name}: {value}"
                     )
                   ),
                   collapse = "\n")
  )
})

test_that("build_request messages effectively mixed correct/incorrect input", {

  params <- list(chicken = "muffin",
                 q = "fields='files/id'")
  params_wrong <- params[1]
  params_right <- params[2]
  expect_message(build_request(params = params),
                 paste(
                   c(
                     "Ignoring these unrecognized parameters:",
                     glue::glue_data(
                       tibble::enframe(params_wrong),
                       "{name}: {value}"
                     )
                   ),
                   collapse = "\n")
  )
  ## let's make sure the correct parameter (q) still passed
  expect_identical(suppressMessages(build_request(params = params)$query),
                   params_right)
})


test_that("build_request messages effectively with sometimes correct but this time incorrect input", {
  ## what if you give a parameter that is accepted in a
  ## different endpoint, but not the one you specified?
  ## should still give a message

  ## for the permissions, must supply fileId
  params <- list(q = "this is not the q you're looking for",
                 fileId = 1)

  ## q is not an allowed parameter for listing permissions
  params_wrong <- params[1]

  expect_message(build_request(endpoint = "drive.permissions.list",
                               params = params),
                 paste(
                   c(
                     "Ignoring these unrecognized parameters:",
                     glue::glue_data(
                       tibble::enframe(params_wrong),
                       "{name}: {value}"
                     )
                   ),
                   collapse = "\n")
  )


})

test_that("build_request catches if you pass fileId when endpoint doesn't need it", {

  params <- list(fileId = 1)
  expect_message(build_request(endpoint = "drive.files.list",
                               params = params),
                 paste(
                   c(
                     "Ignoring these unrecognized parameters:",
                     glue::glue_data(
                       tibble::enframe(params),
                       "{name}: {value}"
                     )
                   ),
                   collapse = "\n")
  )

})

test_that("build_request catches if you pass fileId when endpoint DOES need it", {

  ## here, fileId = 1 is the fileId that I pass,
  ## fileId = 2 is the one that was passed in the ...
  ## want to make it throws an error
  params <- list(fileId = 1,
                 fileId = 2)

  expect_error(build_request(endpoint = "drive.files.get",
                             params = params),
               paste(
                 c("These parameters are not allowed to appear more than once:",
                   "fileId"), collapse = "\n"
               )
  )
})
