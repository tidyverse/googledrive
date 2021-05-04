# tables of MIME types
# https://developers.google.com/drive/api/v3/mime-types
# https://developers.google.com/drive/api/v3/manage-downloads
# https://developers.google.com/drive/api/v3/ref-export-formats

library(tidyverse)
library(httr)
library(rvest)
library(here)
library(googledrive)

# it doesn't matter who you auth as, but you need to auth as somebody
googledrive:::drive_auth_testing()

# MIME types for local file <--> Drive file
about <- drive_about()
fmts <- about[c("importFormats", "exportFormats")]

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

# where did this csv come from? these must be my decisions, because the
# drive.files.export endpoint has `mimeType` as a required query parameter, i.e.
# I see no basis for saying that the Drive API has default export MIME types
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

# be intentional about row order so diffs are easier to make sense of
# I think it also makes sense to set column order accordingly
translate_mime_types <- translate_mime_types %>%
  arrange(action, mime_type_google, mime_type_local) %>%
  select(action, mime_type_google, everything())

write_csv(
  translate_mime_types,
  file = here("inst", "extdata", "translate_mime_types.csv")
)

# general table of MIME types Google knows about

# The following table lists MIME types that are specific Google Workspace and
# Google Drive
url <- "https://developers.google.com/drive/api/v3/mime-types"

google_mime_types <- GET(url) %>%
  content() %>%
  html_table(fill = TRUE) %>%
  flatten() %>%
  as_tibble() %>%
  select(
    mime_type = `MIME Type`,
    description = Description
  ) %>%
  mutate(description = na_if(description, ""))

mime_tbl <- translate_mime_types %>%
  select(mime_type = mime_type_local) %>%
  distinct() %>%
  bind_rows(google_mime_types)

# use mime::mimemap map extensions
mime_ext <- mime::mimemap %>%
  enframe(name = "ext", value = "mime_type") %>%
  select(mime_type, ext)

mime_tbl <- mime_ext %>%
  right_join(mime_tbl, by = "mime_type")

google_prefix <- "application/vnd.google-apps."
mime_tbl <- mime_tbl %>%
  mutate(
    human_type = ifelse(
      grepl(google_prefix, mime_type, fixed = TRUE),
      sub(google_prefix, "", mime_type, fixed = TRUE),
      ext
    )
  )

# where did this csv come from? these must be my choices
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
    description = "Colab notebook",
    human_type = "colab",
    default = TRUE
  )

mime_tbl <- mime_tbl %>%
  arrange(mime_type, ext)

# remove `description`, to get a good clean diff
# I'll revert this momentarily
write_csv(select(mime_tbl, -description), file = here("inst", "extdata", "mime_tbl.csv"))
