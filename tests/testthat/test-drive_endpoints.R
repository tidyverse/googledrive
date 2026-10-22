test_that("drive_endpoint(s)() work(s)", {
  expect_length(drive_endpoints(), length(.endpoints))
  expect_length(drive_endpoints(c(1, 3, 5)), 3)
  nms <- names(drive_endpoints())
  expect_identical(
    drive_endpoints(c(1, 3, 5)),
    drive_endpoints(nms[c(1, 3, 5)])
  )
  expect_identical(drive_endpoints(2)[[1]], drive_endpoint(2))
  expect_identical(drive_endpoints(nms[2])[[1]], drive_endpoint(nms[2]))
})

test_that("drive_endpoint() checks `i`", {
  expect_snapshot(drive_endpoint(c("a", "b")), error = TRUE)
  expect_snapshot(drive_endpoint(1.5), error = TRUE)
  expect_snapshot(drive_endpoint(TRUE), error = TRUE)
})
