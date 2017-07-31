library(rprojroot)
library(jsonlite)
library(httr)
library(tidyverse)

## load the API spec, including download if necessary
dd_cache <- find_package_root_file("data-raw") %>%
  list.files(pattern = "discovery-document.json$", full.names = TRUE)
if (length(dd_cache) == 0) {
  dd_get <- GET("https://www.googleapis.com/discovery/v1/apis/drive/v3/rest")
  dd_content <- content(dd_get)
  json_fname <- dd_content[c("revision", "id")] %>%
    c("discovery-document") %>%
    map(~ str_replace_all(.x, ":", "-")) %>%
    str_c(collapse = "_") %>%
    str_c(".json") %>%
    find_package_root_file("data-raw", .)
  write_lines(
    content(dd_get, as = "text"),
    json_fname
  )
} else {
  json_fname <- rev(dd_cache)[1]
}
dd_content <- fromJSON(json_fname)
##View(dd_content)
##listviewer::jsonedit(dd_content)

## extract the method collections and bring to same level of hierarchy
about <- dd_content[[c("resources", "about", "methods")]]
names(about) <- paste("about", names(about), sep = ".")
files <- dd_content[[c("resources", "files", "methods")]]
names(files) <- paste("files", names(files), sep = ".")
permissions <- dd_content[[c("resources", "permissions", "methods")]]
names(permissions) <- paste("permissions", names(permissions), sep = ".")
revisions <- dd_content[[c("resources", "revisions", "methods")]]
names(revisions) <- paste("revisions", names(revisions), sep = ".")

endpoints <- c(about, files, permissions, revisions)
# str(endpoints, max.level = 1)
# listviewer::jsonedit(endpoints)

add_schema_params <- function(endpoint, nm) {
  req <- endpoint$request$`$ref`
  if (is.null(req) || req == "Channel") return(endpoint)
  message_glue("{nm} gains {req} schema params\n")
  endpoint$parameters <- c(
    endpoint$parameters,
    dd_content[[c("schemas",  req, "properties")]]
  )
  endpoint
}
endpoints <- imap(endpoints, add_schema_params)

## add API-wide params to all endpoints
add_global_params <- function(x) {
  x[["parameters"]] <- c(x[["parameters"]], dd_content[["parameters"]])
  x
}
endpoints <- map(endpoints, add_global_params)


## add in simple upload and resumable upload
endpoints <- c(
  endpoints,
  files.update.media = list(
    list(
      id = "drive.files.update.media",
      path = "/upload/drive/v3/files/{fileId}",
      httpMethod = endpoints$files.update$httpMethod,
      parameters = c(
        endpoints$files.update$parameters,
        uploadType = list(
          list(type = "string",
               required = TRUE,
               location = "query")
        )
      ),
      parameterOrder = endpoints$files.update$parameterOrder,
      scopes = endpoints$files.update$scopes
    )
  ),
  files.update.media.resumable = list(
    list(
      id = "drive.files.update.media.resumable",
      path = "/resumable/upload/drive/v3/files/{fileId}",
      httpMethod = endpoints$files.update$httpMethod,
      parameters = c(
        endpoints$files.update$parameters,
        uploadType = list(
          list(type = "string",
               required = TRUE,
               location = "query")
        )
      ),
      parameterOrder = endpoints$files.update$parameterOrder,
      scopes = endpoints$files.update$scopes
    )
  )
)

nms <- endpoints %>%
  map(names) %>%
  reduce(union)

## tibble with one row per endpoint
edf <- endpoints %>%
  transpose(.names = nms) %>%
  simplify_all(.type = character(1)) %>%
  as_tibble()
View(edf)

## clean up individual variables

## enforce my own order
edf <- edf %>%
  select(id, httpMethod, path, parameters, scopes, description, everything())

edf$path <- edf$path %>%
  modify_if(~ !grepl("upload", .x), ~ paste0("drive/v3/", .x))

edf$scopes <- edf$scopes %>%
  map(~ gsub("https://www.googleapis.com/auth/", "", .)) %>%
  map_chr(str_c, collapse = ", ")

edf$parameterOrder <- edf$parameterOrder %>%
  modify_if(~ length(.x) < 1, ~ NA_character_) %>%
  map_chr(str_c, collapse = ", ")

edf$response <- edf$response %>%
  map_chr("$ref", .null = NA_character_)
edf$request <- edf$request %>%
  map_chr("$ref", .null = NA_character_)
View(edf)

## loooong side journey to clean up parameters
## give them common sub-elements, in a common order
params <- edf %>%
  select(id, parameters) %>% {
    ## unnest() won't work with a list ... doing it manually
    tibble(
      id = rep(.$id, lengths(.$parameters)),
      parameters = purrr::flatten(.$parameters),
      pname = names(parameters)
    )
  } %>%
  select(id, pname, parameters)
#params$parameters %>% map(names) %>% reduce(union)

## keeping repeated and enum so it can generalize to sheets in the future..
nms <-
  c("location", "required", "type", "repeated", "format", "enum", "description")

## tibble with one row per parameter
## variables method and pname keep track of endpoint and parameter name
params <- params$parameters %>%
  transpose(.names = nms) %>%
  as_tibble() %>%
  add_column(pname = params$pname, .before = 1) %>%
  add_column(id = params$id, .before = 1)
params <- params %>%
  mutate(
    location = location %>% map(1, .null = "body") %>% flatten_chr(),
    required = required %>% map(1, .null = NA) %>% flatten_lgl(),
    type = type %>% map(1, .null = NA) %>% flatten_chr(),
    repeated = repeated %>% map(1, .null = NA) %>% flatten_lgl(),
    format = format %>%  map(1, .null = NA) %>% flatten_chr(),
    enum = enum %>% map(1, .null = NA) %>% flatten_chr(),
    description = description %>% map(1, .null = NA) %>% flatten_chr()
  )
## repack all the info for each parameter into a list
repacked <- params %>%
  select(-id, -pname) %>%
  pmap(list)
params <- params %>%
  select(id, pname) %>%
  mutate(pdata = repacked)
## repack all the parameters for each method into a named list
params <- params %>%
  group_by(id) %>%
  nest(.key = parameters) %>%
  mutate(parameters = map(parameters, deframe))

## replace the parameters in the main endpoint tibble
edf <- edf %>%
  select(-parameters) %>%
  left_join(params) %>%
  select(id, httpMethod, path, parameters, everything())
View(edf)



## WE ARE DONE (THANK YOU JENNY!!)
## saving in various forms

## full spec as tibble, one row per endpoint
out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-tibble.rds"
)
saveRDS(edf, file = out_fname)

## full spec as list
## transpose again, back to a list with one component per endpoint
elist <- edf %>%
  pmap(list) %>%
  set_names(edf$id)
##View(elist)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-list.rds"
)
saveRDS(elist, file = out_fname)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-list.json"
)
elist %>%
  toJSON(pretty = TRUE) %>%
  writeLines(out_fname)

## partial spec as list, i.e. keep only the variables I currently use to
## create the API
## convert to my naming scheme, which is more consistent with general use
.endpoints <- edf %>%
  select(id, method = httpMethod, path, parameters) %>%
  pmap(list) %>%
  set_names(edf$id)
## View(.endpoints)

devtools::use_data(.endpoints, internal = TRUE, overwrite = TRUE)
