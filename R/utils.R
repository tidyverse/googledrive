# fx
spf <- function(...) stop(sprintf(...), call. = FALSE)

last <- function(x) x[length(x)]

sq <- function(x) glue::single_quote(x)

## removes last abs(n) elements
crop <- function(x, n = 6L) if (n == 0) x else utils::head(x, -1 * abs(n))

## version of glue::collapse() that returns x if length(x) == 0
collapse2 <- function(x, sep = "", width = Inf, last = "") {
  if (length(x) == 0) {
    x
  } else
    glue::collapse(x = x, sep = sep, width = width, last = last)
}

## finds max i such that all(x[1:i])
last_all <- function(x) {
  Position(isTRUE, as.logical(cumprod(x)), right = TRUE, nomatch = 0)
}

## I expect the links to have /d/ before the fileId
drive_extract_id <- function(x) {
  id_loc <- regexpr("/d/([^/])+", x)
  id <- ifelse(id_loc == -1, NA, gsub("/d/", "", regmatches(x, id_loc)))
  id
}

drive_extract_id_smarter <- function(x) {
  id <- drive_extract_id(x)
  purrr::map2_chr(id, x, redirect_id)
}

redirect_id <- function(id, url) {
  if (!is.na(id)) {
    return(id)
  }
  header <- try(httr::HEAD(url), silent = TRUE)
  if (class(header) == "try-error" || header$status_code > 400) {
    return(id)
  }
  url <- header$url
  drive_extract_id(url)
}

get_mime_type <- function(x) {
  if (!(x %in% c("document", "spreadsheet", "folder", "presentation",
                 "form", "drawing", "script"))) {
    message(glue::glue("Input was not a Google Drive type: {x}"))
    invisible(NULL)
  } else {
  paste0("application/vnd.google-apps.", x)
  }
}
