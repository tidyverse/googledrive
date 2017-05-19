#mime-types tables
#https://developers.google.com/drive/v3/web/mime-types
#https://developers.google.com/drive/v3/web/manage-downloads
library('dplyr')

url <- "https://developers.google.com/drive/v3/web/manage-downloads"

download_mime_types <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::flatten() %>%
  tibble::as_tibble() %>%
  filter(rowSums(is.na(.)) != ncol(.)) %>%  #remove NAs
  select(friendly_fmt = `Conversion Format`,
         mime_type = `Corresponding MIME type`)  %>%
  distinct()

url <- "https://developers.google.com/drive/v3/web/mime-types"
query_mime_types <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::flatten() %>%
  tibble::as_tibble() %>%
  select(mime_type = `MIME Type`,
         google_fmt = `Description`)

fmts <- build_request(endpoint = "drive.about.get",
                      params = list(fields = "importFormats,exportFormats")) %>%
  make_request() %>%
  process_request()

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


translate_mime_types <- bind_rows(imports, exports) %>%
  left_join(download_mime_types, by = c("mime_type_local" = "mime_type"))


ok_ext <- paste(c("opt", "ppt", "pptx", "pptm","xls","xlsx","csv","tsv",
            "tab","xlsm","xlt","xltx","xltm","ods","doc, docx","txt",
            "rtf","html","odt","pdf","jpeg","png","gif","bmp"), collapse = "|")

translate_mime_types$ext <- stringr::str_extract(translate_mime_types$mime_type_local, ok_ext)


readr::write_csv(translate_mime_types, path = "inst/extdata/translate_mime_types.csv")
readr::write_csv(query_mime_types, path = "inst/extdata/query_mime_types.csv")
