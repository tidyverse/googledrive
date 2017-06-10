library(rprojroot)
library(jsonlite)
library(tidyverse)

dd_cache <- find_package_root_file("data-raw") %>%
  list.files(pattern = "discovery-document.json$", full.names = TRUE)
json_fname <- rev(dd_cache)[1]
dd_content <- fromJSON(json_fname)

ff <- dd_content[["schemas"]][["File"]][["properties"]]
df <- tibble(
  name = names(ff),
  desc = map_chr(ff, "description")
)

default_fields <- c(
  "appProperties",
  "capabilities",
  "contentHints",
  "createdTime",
  "description",
  "explicitlyTrashed",
  "fileExtension",
  "folderColorRgb",
  "fullFileExtension",
  "headRevisionId",
  "iconLink",
  "id",
  "imageMediaMetadata",
  "kind",
  "lastModifyingUser",
  "md5Checksum",
  "mimeType",
  "modifiedByMeTime",
  "modifiedTime",
  "name",
  "originalFilename",
  "ownedByMe",
  "owners",
  "parents",
  "permissions",
  "properties",
  "quotaBytesUsed",
  "shared",
  "sharedWithMeTime",
  "sharingUser",
  "size",
  "spaces",
  "starred",
  "thumbnailLink",
  "trashed",
  "version",
  "videoMediaMetadata",
  "viewedByMe",
  "viewedByMeTime",
  "viewersCanCopyContent",
  "webContentLink",
  "webViewLink",
  "writersCanShare"
)
df$default <- df$name %in% default_fields
df <- df[c("name", "default", "desc")]

write_csv(df, find_package_root_file("inst", "extdata", "files_fields.csv"))
