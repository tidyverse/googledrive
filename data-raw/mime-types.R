#mime-types tables
#https://developers.google.com/drive/v3/web/mime-types
#https://developers.google.com/drive/v3/web/manage-downloads
library("dplyr")
library("rprojroot")
library("readr")

url <- "https://developers.google.com/drive/v3/web/mime-types"

google_mime_types <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::flatten() %>%
  tibble::as_tibble() %>%
  select(mime_type = `MIME Type`)

fmts <- generate_request(endpoint = "drive.about.get",
                      params = list(fields = "importFormats,exportFormats")) %>%
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
  right_join(mime_tbl, by = "mime_type") %>%
  mutate(human_type = ifelse(grepl("application/vnd.google-apps.", mime_type),
                             gsub("application/vnd.google-apps.", "", mime_type),
                             ext))


write_csv(translate_mime_types, path = find_package_root_file("inst", "extdata", "translate_mime_types.csv"))
write_csv(mime_tbl, path = find_package_root_file("inst", "extdata", "mime_tbl.csv"))
