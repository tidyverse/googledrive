# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive_read", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("DESC"),
    nm_("chicken_doc"),
    nm_("imdb_latin1_csv")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), name = nm_("DESC"))

  drive_upload(
    drive_example_local("chicken.txt"),
    name = nm_("chicken_doc"),
    type = "document"
  )

  tfile <- tempfile(fileext = ".csv")
  curl::curl_download(
    "https://matthew-brett.github.io/cfd2019/data/imdblet_latin.csv",
    destfile = tfile
  )
  drive_upload(tfile, name = nm_("imdb_latin1_csv"))
}

# ---- tests ----
test_that("drive_read_string() extracts text", {
  skip_if_no_token()
  skip_if_offline()

  suppressMessages(
    r_desc <- drive_read_string(nm_("DESC"))
  )
  r_desc <- as.list(read.dcf(textConnection(r_desc))[1, ])
  expect_equal(r_desc$Package, "base")
  expect_equal(r_desc$Title, "The R Base Package")
})

test_that("drive_read_raw() returns bytes", {
  skip_if_no_token()
  skip_if_offline()

  suppressMessages(
    r_desc_raw <- drive_read_raw(nm_("DESC"))
  )
  suppressMessages(
    r_desc_string <- drive_read_string(nm_("DESC"))
  )
  expect_equal(rawToChar(r_desc_raw), r_desc_string)
})

test_that("drive_read() works on a native Google file", {
  skip_if_no_token()
  skip_if_offline()

  suppressMessages(
    chicken_poem <- drive_read_string(nm_("chicken_doc"), type = "text/plain")
  )
  chicken_poem <- strsplit(chicken_poem, split = "(\r\n|\r|\n)")[[1]]
  expect_setequal(
    chicken_poem,
    read_utf8(drive_example_local("chicken.txt"))
  )
})

test_that("drive_read() can handle non UTF-8 input, if informed", {
  skip_if_no_token()
  skip_if_offline()

  suppressMessages(
    imdb <- drive_read_string(nm_("imdb_latin1_csv"), encoding = "latin1")
  )
  imdb <- utils::read.csv(text = imdb, stringsAsFactors = FALSE, encoding = "UTF-8")
  expect_equal(
    names(imdb),
    c("Votes", "Rating", "Title", "Year", "Decade")
  )
  leon <- "\u004C\u00E9\u006F\u006E"
  expect_equal(imdb$Title[[1]], leon)
  eight_and_a_half <- "\u0038\u00BD"
  expect_equal(imdb$Title[[31]], eight_and_a_half)
})
