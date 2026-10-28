# Assembles R/sysdata.rda from two components:
#
# * `.endpoints`: Drive API method metadata, derived from the Discovery
#   Document.
#
# * `googledrive_obfuscate_key()`: a built-in key that can be used by
#   drive_token_write() / drive_token_read().

library(usethis)

.endpoints <- local({
  source("data-raw/discovery-doc-ingest.R", local = TRUE)
  .endpoints
})

googledrive_obfuscate_key <- local({
  source("../gargle-internal/googledrive/place-built-in-key.R", local = TRUE)
  googledrive_obfuscate_key
})

stopifnot(
  is.list(.endpoints),
  !is.null(attr(.endpoints, "base_url")),
  is.function(googledrive_obfuscate_key),
  is.raw(googledrive_obfuscate_key()),
  length(googledrive_obfuscate_key()) == 32
)

use_data(
  .endpoints,
  googledrive_obfuscate_key,
  internal = TRUE,
  overwrite = TRUE
)
