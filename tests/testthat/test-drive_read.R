# ---- nm_fun ----
me_ <- nm_fun("TEST-drive_read")
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
    drive_example("chicken.txt"),
    name = nm_("chicken_doc"),
    type = "document"
  )
  drive_upload(
    drive_example("chicken.csv"),
    name = nm_("chicken_sheet"),
    type = "spreadsheet"
  )
  tfile <- tempfile(fileext = ".csv")
  curl::curl_download(
    "https://matthew-brett.github.io/cfd2019/data/imdblet_latin.csv",
    destfile = tfile
  )
  drive_upload(tfile, name = nm_("imdb_latin1_csv"))
}

# ---- tests ----
test_that("drive_read() can extract text", {
  suppressMessages(
    r_desc <- drive_read(nm_("DESC"))
  )
  r_desc <- as.list(read.dcf(textConnection(r_desc))[1, ])
  expect_equal(r_desc$Package, "base")
  expect_equal(r_desc$Title, "The R Base Package")
})

test_that("drive_read() works on a native Google file", {
  suppressMessages(
    chicken_poem <- drive_read(nm_("chicken_doc"), type = "text/plain")
  )
  chicken_poem <- strsplit(chicken_poem, split = "(\r\n|\r|\n)")[[1]]
  expect_setequal(
    chicken_poem,
    read_utf8(drive_example("chicken.txt"))
  )
})

test_that("drive_read() can handle non UTF-8 input, if informed", {
  suppressMessages(
    imdb <- drive_read(nm_("imdb_latin1_csv"), encoding = "latin1")
  )
  imdb <- read.csv(text = imdb, stringsAsFactors = FALSE, encoding = "UTF-8")
  expect_equal(
    names(imdb),
    c("Votes", "Rating", "Title", "Year", "Decade")
  )
  leon <- "\u004C\u00E9\u006F\u006E"
  expect_equal(imdb$Title[[1]], leon)
  eight_and_a_half <- "\u0038\u00BD"
  expect_equal(imdb$Title[[31]], eight_and_a_half)
})
