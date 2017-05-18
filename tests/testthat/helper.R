## in a session and directory where you are willing to authenticate or have
## an existing .httr-oauth, do this:
## token <- drive_auth()
## make sure you are happy with this user running tests!
## folders and files will be created AND DELETED!
## drive_user()
## saveRDS(token, rprojroot::find_testthat_root_file("testing-token.rds"))
if (!identical(Sys.getenv("APPVEYOR"), "True") &&
    !identical(Sys.getenv("TRAVIS"), "true")) {
  drive_auth(rprojroot::find_testthat_root_file("testing-token.rds"))
}

## for testing process_request
## wrong content:
## res <- httr::GET("https://httpbin.org")
## saveRDS(res, rprojroot::find_testthat_root_file("wrong-content.rds"))
## res <- httr::GET()
##
## right content:
## x <- drive_list()[1,] # grab most recent thing on drive
## url <- httr::modify_url(url = .drive$base_url,
##                         path = paste0("drive/v3/files/",x$id),
##                         query = list(fields = "name"))
## res <- httr::GET(url, drive_token())
## saveRDS(res, rprojroot::find_testthat_root_file("right-content.rds"))

