# Generate a table of MIME types that maps between types that are specific to
# Google Workspace and Google Drive and other MIME types

# For example, what MIME types can be uploaded and converted to a Sheet?
# Excel or csv, etc.

# What MIME types can a Sheet be exported to as a local file?
# Excel or csv or even pdf

# Google Workspace and Google Drive supported MIME types
# Example: application/vnd.google-apps.spreadsheet
# https://developers.google.com/drive/api/v3/mime-types

# https://developers.google.com/drive/api/v3/manage-downloads

# Export MIME types for Google Workspace documents
# https://developers.google.com/workspace/drive/api/guides/ref-export-formats

library(tidyverse)
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
  file = here("inst", "extdata", "data", "translate_mime_types.csv")
)
