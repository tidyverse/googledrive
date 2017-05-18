library("dplyr")

## Grab metadata on all resources/methods

url <- "https://developers.google.com/drive/v3/reference"
id <-c("commentId",
       "fileId",
       "permissionId",
       "replyId",
       "revisionId",
       "teamDriveId")
id_sub <- paste0("{",id,"}")

metadata <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table()

names(metadata) <- c("about",
                     "changes",
                     "channels",
                     "comments",
                     "files",
                     "permissions",
                     "replies",
                     "revisions",
                     "teamdrives")
metadata <- metadata %>%
  bind_rows(.id = "resource") %>%
  tibble::as_tibble() %>%
  mutate(verb = sub("([A-Za-z]+).*", "\\1", `HTTP request`),
         path = gsub(".*? (.+)", "\\1", `HTTP request`)) %>%
  select(resource,
         method = Method,
         verb,
         path,
         method_description = Description) %>%
  filter(method != "URIs relative to https://www.googleapis.com/drive/v3, unless otherwise noted",
         !grepl("and", path)) %>%  #2 finicky ones have 2 paths, we'll fix those by hand
  tibble::add_row(
    resource = "files",
    method = "create",
    verb = "POST",
    path = "/files",
    method_description = "Creates a new file.") %>%
  tibble::add_row(
    resource = "files",
    method = "update",
    verb = "PATCH",
    path = "/files/fileId",
    method_description = "Updates a file's content with patch semantics."
  ) %>%
  mutate(path = Hmisc::sedit(path, id, id_sub))

## Pull out acceptable query parameters
wrangle_query <- function(resource, method) {
  url <- "https://developers.google.com/drive/v3/reference"
  url <- file.path(url, resource, method)
  tbl_lst <- xml2::read_html(url) %>%
    rvest::html_node(css = "#request_parameters")
  if (length(tbl_lst) == 0L) {
    return(NULL)
  }
  tbl_lst %>%
    rvest::html_table() %>%
    tibble::as_tibble() %>%
    select(param_name = `Parameter name`,
           description = Description,
           expects = Value) %>%
    mutate(full_type = ifelse(grepl(" parameters", param_name),
                              param_name, NA),
           type = "query",
           method = method,
           resource = resource) %>%
    tidyr::fill(full_type) %>%
    filter(!grepl(" parameters", param_name) & grepl("query", full_type))  %>%
    mutate(param_name = ifelse(param_name == "parents[]", "parents", param_name))
}

## wrangle body

wrangle_body <- function(resource, method) {
  url <- "https://developers.google.com/drive/v3/reference"
  url <- file.path(url, resource, method)
  tbl_lst <- xml2::read_html(url) %>%
    rvest::html_node(css = "#request_properties_JSON")

  if (length(tbl_lst) == 0L) {
    return(NULL)
  }
  tbl_lst %>%
    rvest::html_table() %>%
    tibble::as_tibble() %>%
    mutate(writable = ifelse(is.na(Notes), 0 , 1)) %>%
    select(param_name = `Property name`,
           description = Description,
           expects = Value,
           writable) %>%
    mutate(full_type = ifelse(grepl(" Properties", param_name),
                              param_name, NA),
           type = "body",
           method = method,
           resource = resource) %>%
    tidyr::fill(full_type) %>%
    filter(!grepl(" Properties", param_name)) %>%
    mutate(param_name = ifelse(param_name == "parents[]", "parents", param_name))
}

query_params <- purrr::map2(metadata$resource, metadata$method, wrangle_query) %>%
  bind_rows()

body_params <- purrr::map2(metadata$resource, metadata$method, wrangle_body) %>%
  bind_rows()


params <- bind_rows(body_params, query_params) %>%
  full_join(metadata, by = c("method", "resource"))

params$endpoint <- glue::glue_data(params, "drive.{resource}.{method}")

readr::write_csv(params, path = "inst/extdata/params.csv")
