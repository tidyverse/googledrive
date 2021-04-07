library(tidyverse)

source(
  system.file("discovery-doc-ingest", "ingest-functions.R", package = "gargle")
)

existing <- list_discovery_documents("drive")
if (length(existing) > 1) {
  rlang::warn("MULTIPLE DISCOVERY DOCUMENTS FOUND. FIX THIS!")
}

if (length(existing) < 1) {
  rlang::inform("Downloading Discovery Document")
  x <- download_discovery_document("drive:v3")
} else {
  msg <- glue::glue("
    Using existing Discovery Document:
      * {existing}
    ")
  rlang::inform(msg)
  x <- here::here("data-raw", existing)
}

dd <- read_discovery_document(x)

methods      <- get_raw_methods(dd)

methods <- methods %>% map(groom_properties,  dd)
methods <- methods %>% map(add_schema_params, dd)
methods <- methods %>% map(add_global_params, dd)

## duplicate two methods to create a companion for media
## simpler to do this here, in data, than in wrapper functions
mediafy <- function(target_id, methods) {
  new <- target_method <- methods[[target_id]]

  new$id <- paste0(target_id, ".media")
  new$path <-
    pluck(target_method, "mediaUpload", "protocols", "simple", "path")
  new$parameters <- c(
    new$parameters,
    uploadType = list(list(type = "string", required = TRUE, location = "query"))
  )

  methods[[new$id]] <- new
  methods
}

methods <- mediafy("drive.files.update", methods)
methods <- mediafy("drive.files.create", methods)

.endpoints <- methods
attr(.endpoints, "base_url") <- dd$rootUrl
# View(.endpoints)

usethis::use_data(.endpoints, internal = TRUE, overwrite = TRUE)
