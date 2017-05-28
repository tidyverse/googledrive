## input: a path, such as "foo/bar/baz"
## output: a list about the leafmost member, i.e. "baz"
##   * file id
##   * mimeType
##   * id of one direct parent (there could be more)
get_leaf <- function(path = NULL) {

  rid <- root_id() ## store to avoid repeated API calls
  path_pieces <- split_path(path)
  d <- length(path_pieces)
  if (d == 0) {
    return(list(
      id = rid,
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

  ## leaf candidate(s)
  leaf_id <- hits$id[hits$name == last(path_pieces)]

  ## for each candidate, enumerate all upward paths, hopefully to root
  root_path <- leaf_id %>%
    purrr::map(pth, kids = hits$id, elders = hits$parents, stop_value = rid)

  ## put into a tibble, one row per candidate path
  leaf_tbl <- tibble::tibble(
    id = rep(leaf_id, lengths(root_path)),
    root_path = purrr::flatten(root_path)
  )
  leaf_tbl$path <- purrr::map_chr(
    leaf_tbl$root_path,
    ~ glue::collapse(rev(hits$name[match(crop(.x, 1), hits$id)]), sep = "/")
  )

  ## retain candidate paths that match input path
  keep_me <- which(strip_slash(path) == leaf_tbl$path)

  if (length(keep_me) > 1) {
    line0 <- glue::glue("The path '{path}' identifies more than one file:")
    lines <- glue::glue_data(
      hits[hits$id %in% leaf_id[keep_me], ],
      "File of type {type}, with id {id}."
    )
    stop(glue::collapse(c(line0, lines), "\n"), call. = FALSE)
  }

  if (length(keep_me) < 1) {
    stop(glue::glue("The path '{path}' does not exist.", call. = FALSE))
  }

  i <- which(hits$id == leaf_id[keep_me])
  list(
    id = hits$id[i],
    mimeType = hits$gfile[[i]][["mimeType"]],
    parent_id = leaf_tbl[[keep_me, "root_path"]][2]
  )
}

## gets the root folder id
root_id <- function() {
  request <- build_request(
    endpoint = "drive.files.get",
    params = list(fileId = "root"))
  response <- make_request(request)
  proc_res <- process_response(response)
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

## strip leading ~, / or ~/
## if it's empty string --> target is root --> set path to NULL
normalize_path <- function(path) {
  if (is.null(path)) return(path)
  if (!(is.character(path) && length(path) == 1)) {
    stop("'path' must be a character string.", call. = FALSE)
  }
  path <- sub("^~?/*", "", path)
  if (identical(path, "")) NULL else path
}

## "a/b/c" and "a/b/c/" both return "a/b/c/"
append_slash <- function(path) {
  ifelse(grepl("/$", path), path, paste0(path, "/"))
}

## "a/b/c" and "a/b/c/" both return "a/b/c"
strip_slash <- function(path) {
  ifelse(grepl("/$", path), gsub("/$", "", path), path)
}
