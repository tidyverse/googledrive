library(rprojroot)
library(jsonlite)
library(tidyverse)

dd_cache <- find_package_root_file("data-raw") %>%
  list.files(pattern = "discovery-document.json$", full.names = TRUE)
json_fname <- rev(dd_cache)[1]
dd_content <- fromJSON(json_fname)

ff <- pluck(dd_content, "schemas", "File", "properties")
df <- tibble(
  name = names(ff),
  desc = map_chr(ff, "description")
)

write_csv(df, find_package_root_file("inst", "extdata", "files_fields.csv"))
