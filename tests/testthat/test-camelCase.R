test_that("snake_case() works", {
  expect_equal(snake_case("name"), "name")
  expect_equal(snake_case("drive_resource"), "drive_resource")

  expect_equal(snake_case("mimeType"), "mime_type")
  expect_equal(snake_case("viewedByMeTime"), "viewed_by_me_time")
  expect_equal(snake_case("md5Checksum"), "md5_checksum")
})
