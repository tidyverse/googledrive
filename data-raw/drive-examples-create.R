library(here)
library(glue)
library(googledrive)
library(tidyverse)

# auth with the special-purpose service account
filename <- glue("~/.R/gargle/googledrive-file-keeper.json")
drive_auth(path = filename)
drive_user()

# files that are the pre-existing local example files
x <- drive_upload(drive_example_local("chicken.csv"))
drive_share_anyone(x)

x <- drive_upload(drive_example_local("chicken.jpg"))
drive_share_anyone(x)

x <- drive_upload(drive_example_local("chicken.pdf"))
drive_share_anyone(x)

x <- drive_upload(drive_example_local("chicken.txt"))
drive_share_anyone(x)

# added June 2021; originally from
# https://matthew-brett.github.io/cfd2019/data/imdblet_latin.csv",
x <- drive_upload(drive_example_local("imdb_latin1.csv"))
drive_share_anyone(x)

# added June 2021; ships with R
# https://stat.ethz.ch/R-manual/R-patched/doc/html/logo.jpg
# r_logo_path <- R.home("doc/html/logo.jpg")
# file.copy(r_logo_path, here("inst", "extdata", "example_files", "r_logo.jpg"))
x <- drive_upload(drive_example_local("r_logo.jpg"))
drive_share_anyone(x)

# added June 2021; ships with R
# https://stat.ethz.ch/R-manual/R-patched/doc/html/about.html
# r_about_path <- R.home("doc/html/about.html")
# file.copy(r_about_path, here("inst", "extdata", "example_files", "r_about.html"))
x <- drive_upload(drive_example_local("r_about.html"))
drive_share_anyone(x)

# export 2 local examples for native Google file types
x <- drive_upload(
  drive_example_local("chicken.txt"),
  type = "document",
  name = "chicken_doc"
)
drive_share_anyone(x)

x <- drive_upload(
  drive_example_local("chicken.csv"),
  type = "spreadsheet",
  name = "chicken_sheet"
)
drive_share_anyone(x)

# files I played with when writing drive_read_string() and drive_read_raw()
# but, so far, have no included
# curl::curl_download("https://httpbin.org/html", destfile = tfile)
# curl::curl_download("https://httpbin.org/xml", destfile = tfile)
# curl::curl_download("https://httpbin.org/json", destfile = tfile)
