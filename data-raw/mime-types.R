#mime-types tables
#https://developers.google.com/drive/v3/web/mime-types
#https://developers.google.com/drive/v3/web/manage-downloads
library('dplyr')

url <- "https://developers.google.com/drive/v3/web/mime-types"

google_mime_types <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::flatten() %>%
  tibble::as_tibble() %>%
  select(mime_type = `MIME Type`)


fmts <- list(url = httr::modify_url(.drive$base_url, path = paste0("drive/v3/about")),
             query = list(fields = "importFormats,exportFormats"),
             method = "GET",
             token = drive_token()) %>%
  make_request() %>%
  process_response()

imports <- tibble::enframe(fmts$importFormats,
                           name = "mime_type_local",
                           value = "mime_type_google") %>%
  mutate(mime_type_google = purrr::simplify_all(mime_type_google),
         action = "import") %>%
  tidyr::unnest()

exports <- tibble::enframe(fmts$exportFormats,
                           name = "mime_type_google",
                           value = "mime_type_local") %>%
  mutate(mime_type_local = purrr::simplify_all(mime_type_local),
         action = "export") %>%
  tidyr::unnest()

translate_mime_types <- bind_rows(imports, exports)


## use mime::mimemap map extensions
mime_ext <- tibble::tibble(
  mime_type = mime::mimemap
)

mime_ext$ext <- names(mime::mimemap)

mime_tbl <- translate_mime_types %>%
  select(mime_type = mime_type_local) %>%
  distinct() %>%
  bind_rows(google_mime_types)

mime_tbl <- mime_ext %>%
  right_join(mime_tbl, by = "mime_type")


readr::write_csv(translate_mime_types, path = "inst/extdata/translate_mime_types.csv")
readr::write_csv(mime_tbl, path = "inst/extdata/mime_tbl.csv")
