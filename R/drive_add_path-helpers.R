## given a tibble of known nodes, resolve paths for leaves
## if leaf-hood not specified, all nodes are assumed to be leaves
## result = input, filtered down to leaves, unnested, with new `path` variable
pathify_prune_unnest <- function(nodes, root_id, leaf = NULL) {
  ## pathify
  leaf <- leaf %||% rep.int(TRUE, nrow(nodes))
  nodes <- add_id_path(nodes, root_id = root_id, leaf = leaf)
  nodes <- add_path(nodes, root_id = root_id)

  ## prune back to leaves
  nodes <- nodes[leaf, ]

  ## unnest to get one row per path, can imply >1 row per leaf!
  path_pre_unnest <- nodes$path
  nodes <- nodes[rep.int(seq_len(nrow(nodes)), lengths(nodes$path)), ]
  nodes$path <- unlist(path_pre_unnest)

  ## add trailing slash where appropriate, if we know folder status
  folder <- if (is_dribble(nodes)) {
    is_folder(nodes)
  } else {
    rep.int(FALSE, nrow(nodes))
  }
  nodes$path <- ifelse(folder, append_slash(nodes$path), nodes$path)

  ## drop working variables
  nodes[c("name", "path", "id", "files_resource")]
}

## construct file paths, in terms of file ids
## by walking root-wards up the file tree from leaf --> ?root?
##
## nodes = tibble with all known nodes
##   must have AT LEAST these variables:
##   * id = character vector of file ids
##   * parents = list-column of character vectors of file ids
## root_id = file id of root folder, i.e. when visited, the walk is over
## leaf = logical vector indicating if this is a potential leaf, i.e.
##        should this path be built?
##        if absent, all ids are treated as a leaf
##
## returns its input with a new variable, id_path
## id_path = list-column of lists of character vectors of ids
## each such character vector is a root-ward path for a leaf
add_id_path <- function(nodes, root_id, leaf = NULL) {
  stopifnot(!anyDuplicated(nodes$id))
  leaf <- leaf %||% rep.int(TRUE, nrow(nodes))
  nodes$id_path <- list(character())
  nodes$id_path[leaf] <- purrr::map(
    nodes$id[leaf],
    ~ pth(.x, kids = nodes$id, elders = nodes$parents, stop_value = root_id)
  )
  nodes
}

## constructs file paths, in the string sense, out of paths based on file ids
## nodes = tibble with AT LEAST these variables:
##   * id = character vector of ids
##   * name =  character vector of names
##   * id_path = list-column of lists of character vectors of ids
## root_id = character id of root, i.e. the id that should be represented as `~`
##
## returns its input with a new variable:
##   * path = list-column of lists of length-1 character vectors of paths
## each such character vector is a root-ward path for a leaf
add_path <- function(nodes, root_id) {
  nodes$path <- purrr::map(
    nodes$id_path,
    ~ purrr::map(
      .x,
      stringify_path,
      key = nodes$id,
      value = nodes$name,
      root_id = root_id
    )
  )
  nodes
}

stringify_path <- function(id_path, key, value, root_id) {
  if (length(id_path) == 0) return(id_path)
  ## put (key = root_id, value = "~" at the front, not the back
  ## why? I don't want match() to find (key = root_id, value = "My Drive"),
  ## if happens to be present
  key <- c(root_id, key)
  value <- c("~", value)
  nms <- value[match(id_path, key)]
  nms <- nms[!is.na(nms)]
  do.call(file.path, as.list(rev(nms)))
}

dribble_with_path <- function() {
  tibble::add_column(dribble(), path = character(), .after = "name")
}

dribble_with_path_for_root <- function() {
  tibble::add_column(root_folder(), path = "~/", .after = "name")
}

root_folder <- function() drive_get(id = "root")
root_id <- function() root_folder()$id

drive_path_exists <- function(path, verbose = TRUE) {
  stopifnot(is_path(path))
  if (length(path) == 0) return(logical(0))
  stopifnot(length(path) == 1)
  some_files(drive_get(path = path))
}
