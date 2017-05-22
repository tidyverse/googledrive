## input: a path, such as "foo/bar/baz"
## output: a list about the leafmost member, i.e. "baz"
##   * file id
##   * mimeType
##   * id of one direct parent (there could be more)
get_leaf <- function(path = NULL) {

  root_id <- root_folder() ## store to avoid repeated API calls
  path_pieces <- split_path(path)
  d <- length(path_pieces)
  if (d == 0) {
    return(list(
      id = root_id,
      mimeType = "application/vnd.google-apps.folder",
      parent_id <- NA_character_
    ))
  }

  ## query will restrict to the names seen in path and to mimeType = folder, for
  ## all pieces where that is known
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

  ## for each candidate, enumerate all upward paths, hopefully to root
  root_path <- leaf_id %>%
    purrr::map(pth, kids = hits$id, elders = hits$parents, stop_value = root_id)
  ## retain candidate paths with d + 1 elements = d path pieces + root_id
  root_path <- root_path %>%
    purrr::map(require_length, len = d + 1)
  ## for each candidate, get an immediate parent on a path back to root
  ## will be NA is there is no such path
  root_parent <- root_path %>%
    purrr::map_chr(rootwise_parent)
  root_path_exists <- !is.na(root_parent)

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

  i <- which(hits$id == leaf_id[root_path_exists])
  list(
    id = hits$id[i],
    mimeType = hits$gfile[[i]][["mimeType"]],
    parent_id = root_parent
  )
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

## returns a list
## each component is a character vector:
## id --> parent of id --> grandparent of id --> ... END
## END is either stop_value (root_id, for us) or NA_character_
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

require_length <- function(paths, len) {
  paths %>% purrr::keep(~ length(.x) == len)
}

rootwise_parent <- function(paths) {
  ## retain only paths that end with root_id <==> not NA
  paths <- paths %>% purrr::keep(~ !is.na(last(.x)))
  if (length(paths) == 0) return(NA_character_)
  ## return one -- of possibly many -- direct parents
  paths[[1]][2]
}
