#mime-types tables
#https://developers.google.com/drive/v3/web/mime-types
#https://developers.google.com/drive/v3/web/manage-downloads
library("tidyverse")
library("httr")
library("rvest")
library("rprojroot")
library("googledrive")

## MIME types for local file <--> Drive file
fmts <- generate_request(
  endpoint = "drive.about.get",
  params = list(fields = "importFormats,exportFormats")
  ) %>%
  do_request()

imports <- tibble::enframe(
  fmts$importFormats,
  name = "mime_type_local",
  value = "mime_type_google"
  ) %>%
  mutate(
    mime_type_google = purrr::simplify_all(mime_type_google),
    action = "import"
  ) %>%
  tidyr::unnest()

exports <- tibble::enframe(
  fmts$exportFormats,
  name = "mime_type_google",
  value = "mime_type_local"
  ) %>%
  mutate(
    mime_type_local = purrr::simplify_all(mime_type_local),
    action = "export"
  ) %>%
  tidyr::unnest()

translate_mime_types <- bind_rows(imports, exports)

defaults <- read_csv(
  find_package_root_file("data-raw", "export-mime-type-defaults.csv")
  ) %>%
  mutate(action = "export",
         default = TRUE)

translate_mime_types <- translate_mime_types %>%
  left_join(defaults) %>%
  mutate(default = case_when(
    action == "import" ~ NA,
    is.na(default) ~ FALSE,
    TRUE ~ TRUE
  ))

write_csv(
  translate_mime_types,
  path = find_package_root_file("inst", "extdata", "translate_mime_types.csv")
)

## general table of MIME types Google knows about

## The following table lists MIME types that are specific to G Suite and Google
## Drive.
url <- "https://developers.google.com/drive/v3/web/mime-types"

google_mime_types <- GET(url) %>%
  content() %>%
  html_table(fill = TRUE) %>%
  flatten() %>%
  as_tibble() %>%
  select(mime_type = `MIME Type`)

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

default_ext <- read_csv(
  find_package_root_file("data-raw", "extension-mime-type-defaults.csv")
) %>%
  mutate(default = TRUE)

mime_tbl <- mime_tbl %>%
  left_join(default_ext) %>%
  mutate(default = case_when(
    is.na(ext) ~ NA,
    is.na(default) ~ FALSE,
    TRUE ~ TRUE
  ))

write_csv(mime_tbl, path = find_package_root_file("inst", "extdata", "mime_tbl.csv"))
