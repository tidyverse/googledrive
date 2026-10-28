library(tidyverse)
library(fs)
library(cli)

source(
  system.file("discovery-doc-ingest", "ingest-functions.R", package = "gargle")
)

# Always download the current Discovery Document. The date in the filename is
# the API's revision date (from the document's `revision` field), so a download
# either overwrites the existing JSON or adds a new one. In the latter case,
# move the old JSON to data-raw/old/.
# Naively diffing old vs. new Discovery Documents hasn't proven very useful (a
# 2021 vs. 2025 comparison had 632 diffs). So you'll need to use an appropriate
# tool if you want to do that.

x <- download_discovery_document("drive:v3")

superseded <- setdiff(list_discovery_documents("drive"), path_file(x))
if (length(superseded) > 0) {
  move_code <- glue::glue(
    'fs::file_move("{path("data-raw", superseded)}", "data-raw/old")'
  )
  cli_warn(c(
    "Superseded Drive Discovery Document{?s} found in {.path data-raw/}: \\
     {.file {superseded}}",
    "i" = "Move to {.path data-raw/old/} with:",
    set_names(paste0("{.run ", move_code, "}"), " ")
  ))
}
cli_inform("Ingesting {.file {path_file(x)}}")

dd <- read_discovery_document(x)

methods <- get_raw_methods(dd)

methods <- methods |> map(groom_properties, dd)
methods <- methods |> map(add_schema_params, dd)
methods <- methods |> map(add_global_params, dd)

## duplicate two methods to create a companion for media
## simpler to do this here, in data, than in wrapper functions
mediafy <- function(target_id, methods) {
  new <- target_method <- methods[[target_id]]

  new$id <- paste0(target_id, ".media")
  new$path <-
    pluck(target_method, "mediaUpload", "protocols", "simple", "path")
  new$parameters <- c(
    new$parameters,
    uploadType = list(list(
      type = "string",
      required = TRUE,
      location = "query"
    ))
  )

  methods[[new$id]] <- new
  methods
}

methods <- mediafy("drive.files.update", methods)
methods <- mediafy("drive.files.create", methods)

.endpoints <- methods
attr(.endpoints, "base_url") <- dd$rootUrl
#View(.endpoints)

# This script does NOT write R/sysdata.rda. It is sourced by
# data-raw/sysdata.R, which does that.
