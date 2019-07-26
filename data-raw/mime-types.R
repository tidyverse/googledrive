# mime-types tables
# https://developers.google.com/drive/v3/web/mime-types
# https://developers.google.com/drive/v3/web/manage-downloads
library(tidyverse)
library(httr)
library(rvest)
library(here)
library(googledrive)

conflicted::conflict_prefer("pluck", "purrr")

## MIME types for local file <--> Drive file
fmts <- request_generate(
  endpoint = "drive.about.get",
  params = list(fields = "importFormats,exportFormats")
  ) %>%
  do_request()

imports <- fmts %>%
  pluck("importFormats") %>%
  enframe(
    name = "mime_type_local",
    value = "mime_type_google"
  ) %>%
  unnest_longer(mime_type_google) %>%
  mutate(action = "import")

exports <- fmts %>%
  pluck("exportFormats") %>%
  enframe(
    name = "mime_type_google",
    value = "mime_type_local"
  ) %>%
  unnest_longer(mime_type_local) %>%
  mutate(action = "export")

translate_mime_types <- bind_rows(imports, exports)

defaults <- here("data-raw", "export-mime-type-defaults.csv") %>%
  read_csv() %>%
  mutate(
    action = "export",
    default = TRUE
  )

translate_mime_types <- translate_mime_types %>%
  left_join(defaults) %>%
  mutate(
    default = case_when(
      action == "import" ~ NA,
      is.na(default)     ~ FALSE,
      TRUE               ~ TRUE
    )
  )

write_csv(
  translate_mime_types,
  path = here("inst", "extdata", "translate_mime_types.csv")
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
    ext
  ))

default_ext <- here("data-raw", "extension-mime-type-defaults.csv") %>%
  read_csv() %>%
  mutate(default = TRUE)

mime_tbl <- mime_tbl %>%
  left_join(default_ext) %>%
  mutate(
    default = case_when(
      is.na(ext)     ~ NA,
      is.na(default) ~ FALSE,
      TRUE           ~ TRUE
    )
  )

mime_tbl <- mime_tbl %>%
  add_row(
    # TODO(jennybc): consider also "application/vnd.google.colaboratory"
    mime_type = "application/vnd.google.colab",
    ext = "ipynb",
    human_type = "colab",
    default = TRUE
  )

write_csv(mime_tbl, path = here("inst", "extdata", "mime_tbl.csv"))
