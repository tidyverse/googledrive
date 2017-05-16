#mime-types tables
#https://developers.google.com/drive/v3/web/mime-types
#https://developers.google.com/drive/v3/web/manage-downloads
library('dplyr')

url <- "https://developers.google.com/drive/v3/web/manage-downloads"

download_mime_types <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::flatten() %>%
  tibble::as_tibble() %>%
  filter(rowSums(is.na(.)) != ncol(.)) %>%  #remove NAs
  mutate(google_fmt = replace(`Google Doc Format`,
                              `Google Doc Format` == "", NA)) %>%
  select(google_fmt,
         conversion_fmt = `Conversion Format`,
         mime_type = `Corresponding MIME type`
  ) %>%
  do(zoo::na.locf(.)) #fill

url <- "https://developers.google.com/drive/v3/web/mime-types"
query_mime_types <- httr::GET(url) %>%
  httr::content() %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::flatten() %>%
  tibble::as_tibble() %>%
  select(mime_type = `MIME Type`,
         google_fmt = `Description`)

#.drive$query_mime_types <- query_mime_types
#.drive$download_mime_types <- download_mime_types
