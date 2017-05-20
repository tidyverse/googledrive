get_leaf <- function(path = NULL) {

  root_id <- root_folder() ## store to avoid repeated API calls
  path_pieces <- split_path(path)
  d <- length(path_pieces)
  if (d == 0) {
    return(root_id)
  }

  hits <- drive_list(
    fields = "files/parents,files/name,files/mimeType,files/id",
    q = form_query(path_pieces, leaf_is_folder = grepl("/$", path)),
    verbose = FALSE
  )

  if (!all(path_pieces %in% hits$name)) {
    stop(glue::glue("The path '{path}' does not exist.", call. = FALSE))
  }
  ## guarantee: we have found at least one item with correct name for
  ## each piece of path

  hits$depth <- match(hits$name, path_pieces)
  hits <- hits[order(hits$depth), ]

  ## leaf candidate(s)
  leaf_id <- hits$id[hits$depth == d]

  ## for each candidate, try to establish path back to root
  root_paths <- leaf_id %>%
    purrr::map(pth, kids = hits$id, elders = hits$parents, stop_value = root_id)
  root_path_exists <- root_paths %>%
    purrr::at_depth(2, ~ !is.na(last(.x))) %>%
    purrr::map(purrr::flatten_lgl) %>%
    purrr::map_lgl(any)

  if (sum(root_path_exists) > 1) {
    line0 <- glue::glue("The path '{path}' identifies more than one file:")
    lines <- glue::glue_data(
      hits[hits$id %in% leaf_id[root_path_exists], ],
      "File of type {type}, with id {id}."
    )
    stop(glue::collapse(c(line0, lines), "\n"), call. = FALSE)
  }
  if (sum(root_path_exists) < 1) {
    stop(glue::glue("The path '{path}' does not exist.", call. = FALSE))
  }
  leaf_id[root_path_exists]
}

## gets the root folder id
root_folder <- function() {
  request <- build_request(
    endpoint = "drive.files.get",
    params = list(fileId = "root"))
  response <- make_request(request)
  proc_res <- process_request(response)
  proc_res$id

}

pth <- function(id, kids, elders, stop_value) {
  this <- last(id)
  i <- which(kids == this)
  if (length(i) < 1) {
    ## parent not found, end it here with sentinel NA
    list(c(id, NA))
  } else {
    parents <- elders[[i]]
    if (stop_value %in% parents) {
      ## we're done, e.g. have found way to root, end it here
      list(c(id, stop_value))
    } else {
      unlist(
        lapply(parents, function(p) pth(c(id, p), kids, elders, stop_value)),
        recursive = FALSE
      )
    }
  }
}

split_path <- function(path = "") {
  path <- path %||% ""
  path <- sub("^~?/*", "", path)
  unlist(strsplit(path, "/"))
}

## path  path pieces  dir pieces  leaf pieces
## a/b/  a b          a b
## a/b   a b          a           b
## a/    a            a
## a     a                        a
form_query <- function(path_pieces, leaf_is_folder = FALSE) {
  nms <- paste0("name = ", sq(path_pieces))
  leaf_q <- utils::tail(nms, !leaf_is_folder)
  dirs_q <- glue::glue(
    "(({dir_pieces}) and mimeType = 'application/vnd.google-apps.folder')",
    dir_pieces = collapse2(crop(nms, !leaf_is_folder), sep = " or ")
  )
  glue::collapse(c(leaf_q, dirs_q), last = " or ")
}
