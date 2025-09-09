# Generate a table associating file extensions or "type" with MIME types.
# Used in drive_mime_type() to do these sorts of translations:
# Input type                        Input          MIME type
# ---------------------------------|--------------|-----------------------------------------
# Casual name for native Drive type "spreadsheet"  "application/vnd.google-apps.spreadsheet"
# File extension                    "jpeg"         "image/jpeg"
# MIME type                         "image/gif"    "image/gif"

# So we need to muster file types, file extensions, and MIME types.

library(here)
library(tidyverse)
library(httr)
library(rvest)

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
nrow(google_mime_types) # 20

# Another table we've made for the import and export MIME types for native Drive
# files.
import_and_export <- read_csv(
  file = here("inst", "extdata", "data", "translate_mime_types.csv")
)

# Take the local MIME types that are supported for import or export, get rid of
# duplicates, and add them to the Google Drive/Workspace-specific MIME types.
mime_tbl <- import_and_export %>%
  select(mime_type = mime_type_local) %>%
  distinct() %>%
  bind_rows(google_mime_types)
nrow(mime_tbl)
# 69 rows, i.e. 69 MIME types

# mime::mimemap is a good source of associations between MIME types and  file
# extensions.
mime_ext <- mime::mimemap %>%
  enframe(name = "ext", value = "mime_type") %>%
  select(mime_type, ext)
nrow(mime_ext) # 1548
mime_ext %>%
  summarise(across(everything(), n_distinct))
# # A tibble: 1 × 2
#   mime_type   ext
#       <int> <int>
# 1      1203  1548

mime_tbl_2 <- mime_ext %>%
  right_join(mime_tbl, by = "mime_type")
nrow(mime_tbl_2) # 88
# 69 -> 88 rows, because some MIME types are associated with multiple extensions

# Example: JPEGs
mime_tbl_2 |>
  filter(str_detect(mime_type, "image/jpeg"))
# # A tibble: 4 × 3
#   mime_type  ext   description
#   <chr>      <chr> <chr>
# 1 image/jpeg jpeg  NA
# 2 image/jpeg jpg   NA
# 3 image/jpeg jpe   NA
# 4 image/jpeg jfif  NA

# weird that "text/rtf" appears in the Google Drive/Workspace world, but is not
# covered by mime::mimemap
mime_tbl_2 |>
  filter(str_detect(mime_type, "rtf"))
# # A tibble: 2 × 3
#   mime_type       ext   description
#   <chr>           <chr> <chr>
# 1 application/rtf rtf   NA
# 2 text/rtf        NA    NA

mime_tbl_2 |>
  group_by(mime_type) |>
  count(sort = TRUE) |>
  filter(n > 1)
# # A tibble: 8 × 2
# # Groups:   mime_type [8]
#   mime_type                         n
#   <chr>                         <int>
# 1 application/vnd.ms-excel          6
# 2 text/plain                        5
# 3 image/jpeg                        4
# 4 text/html                         3
# 5 video/mp4                         3
# 6 application/vnd.ms-powerpoint     2
# 7 image/svg+xml                     2
# 8 text/markdown                     2

# We're going to need to resolve such situations where we can by declaring a
# default extension for such MIME types.

# Proposal: any MIME type that appears in the official export (and maybe
# import?) list should have an associated file extension.
# Note that this is *not* about import/export, but rather about upload/download.
# We're just referring to import/export as a semi-authoritative source of
# important MIME types.

mime_tbl_2 |>
  arrange(mime_type) |>
  print(n = Inf)

mime_tbl_2 |>
  filter(is.na(ext)) |>
  arrange(mime_type) |>
  print(n = Inf)
# rows that catch my eye
# ...
# 34 image/jpg                                                  NA    NA
# ...
# 36 image/x-bmp                                                NA    NA
# 37 image/x-png                                                NA    NA
# 38 text/richtext                                              NA    NA
# 39 text/rtf                                                   NA    NA
# 40 text/x-markdown                                            NA    NA

# Fixup for special Google Drive/Workspace MIME types
google_prefix <- "application/vnd.google-apps."
mime_tbl_3 <- mime_tbl_2 %>%
  mutate(
    human_type = ifelse(
      grepl(google_prefix, mime_type, fixed = TRUE),
      sub(google_prefix, "", mime_type, fixed = TRUE),
      ext
    )
  )

mime_tbl_3 |>
  arrange(mime_type) |>
  print(n = Inf)

mime_tbl_3 |>
  count(is.na(ext))
# # A tibble: 2 × 2
#   `is.na(ext)`     n
#   <lgl>        <int>
# 1 FALSE           48
# 2 TRUE            40

# Where did this csv come from? these must be my choices
default_ext <- here("data-raw", "extension-mime-type-defaults.csv") %>%
  read_csv() %>%
  mutate(default = TRUE)

mime_tbl_4 <- mime_tbl_3 %>%
  left_join(default_ext) %>%
  mutate(
    default = case_when(
      is.na(ext) ~ NA,
      is.na(default) ~ FALSE,
      TRUE ~ TRUE
    )
  )

mime_tbl_5 <- mime_tbl_4 %>%
  add_row(
    # TODO(jennybc): consider also "application/vnd.google.colaboratory"
    mime_type = "application/vnd.google.colab",
    ext = "ipynb",
    description = "Colab notebook",
    human_type = "colab",
    default = TRUE
  )

# I want to set up extension affiliation for MIME types:
# text/richtext --> rtf
# text/rtf      --> rtf
# text/x-markdown --> md
# fmt: skip
patch <- tribble(
  ~mime_type, ~ext, ~default,
  "text/richtext", "rtf", TRUE,
  "text/rtf", "rtf", TRUE,
  "text/x-markdown", "md", TRUE

)
mime_tbl_6 <- mime_tbl_5 %>%
  rows_patch(patch, by = "mime_type") |>
  arrange(mime_type, ext)

write_csv(mime_tbl_6, file = here("inst", "extdata", "data", "mime_tbl.csv"))
