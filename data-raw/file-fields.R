library(here)
library(jsonlite)
library(tidyverse)
library(fs)

json_fname <- dir_ls(here("data-raw"), regexp = "drive-v3")
stopifnot(length(json_fname) == 1)
dd_content <- fromJSON(json_fname)

ff <- pluck(dd_content, "schemas", "File", "properties")
df <- tibble(
  name = names(ff),
  desc = map_chr(ff, "description")
)

write_csv(df, here("inst", "extdata", "files_fields.csv"))
