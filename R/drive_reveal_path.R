drive_reveal_path <- function(file) {
  ## refresh file metadata
  ## TO DO: is this really necessary? it makes things slow
  if (is_dribble(file)) {
    file <- as_id(file)
  }
  file <- as_dribble(file)
  if (no_file(file)) return(dribble_with_path())

  team_drive <- NULL
  corpus <- NULL
  tid <- purrr::map_chr(file$drive_resource, "teamDriveId", .default = NA)
  tid <- unique(tid[!is.na(tid)])
  if (length(tid) > 0) {
    if (length(tid) == 1) {
      team_drive <- as_id(tid)
    } else {
      corpus <- "all"
    }
  }

  ## nodes = the specific files we have + all folders
  nodes <- rbind(
    file,
    drive_find(type = "folder", team_drive = team_drive, corpus = corpus),
    make.row.names = FALSE
  ) %>% promote("parents")
  nodes <- nodes[!duplicated(nodes$id), ]

  ROOT_ID <- root_id()
  x <- purrr::map(file$id, ~pathify_one_id(.x, nodes, ROOT_ID))

  ## TO DO: if (verbose), message if a dribble doesn't have exactly 1 row?
  rlang::exec(rbind, !!!x)
}

pathify_one_id <- function(id, nodes, root_id) {
  if (id == "root") return(dribble_with_path_for_root())
  leaf <- nodes$id == id
  if (!any(leaf)) return(dribble_with_path())
  pathify_prune_unnest(nodes, root_id = root_id, leaf = leaf)
}

## essentially the same as drive_reveal_path,
## but for files specified via path vs. id
## does the actual work for drive_get(path = ...)
dribble_from_path <- function(path = NULL,
                              team_drive = NULL,
                              corpus = NULL) {
  if (length(path) == 0) return(dribble_with_path())
  stopifnot(is_path(path))
  path <- rootize_path(path)

  ## nodes = files with names implied by our paths + all folders
  nodes <- get_nodes(path, team_drive, corpus)
  if (nrow(nodes) == 0) return(dribble_with_path())

  ROOT_ID <- root_id()
  x <- purrr::map(path, ~pathify_one_path(.x, nodes, ROOT_ID))

  ## TO DO: if (verbose), message if a dribble doesn't have exactly 1 row?
  rlang::exec(rbind, !!!x)
}

pathify_one_path <- function(op, nodes, root_id) {
  if (is_rootpath(op)) return(dribble_with_path_for_root())

  name <- last(split_path(op))
  leaf <- nodes$name == name
  if (grepl("/$", op)) {
    leaf <- leaf & is_folder(nodes)
  }
  if (!any(leaf)) return(dribble_with_path())
  out <- pathify_prune_unnest(nodes, root_id = root_id, leaf = leaf)

  target <- paste0(escape_regex(strip_slash(op)), "/?$")
  if (is_rooted(op)) {
    target <- paste0("^", target)
  }
  out <- out[grepl(target, out$path), ]
  ## eliminate this type of duplicate:
  ## a single file that is present >1 times because it has multiple paths,
  ## in the id sense, but they map to same path in the string sense
  out[!duplicated(out[c("path", "id")]), ]
}

## given a vector of paths,
## retrieves metadata for all files that could be needed to resolve paths
get_nodes <- function(path,
                      team_drive = NULL,
                      corpus = NULL) {
  path_parts <- purrr::map(path, partition_path, maybe_name = TRUE)
  ## workaround for purrr <= 0.2.2.2
  name <- purrr::map(path_parts, "name")
  name <- purrr::flatten_chr(purrr::map_if(name, is.null, ~NA_character_))
  # name <- purrr::map_chr(path_parts, "name", .default = NA)
  names <- unique(name)
  names <- names[!is.na(names)]
  names <- glue("name = {sq(names)}")
  folders <- "mimeType = 'application/vnd.google-apps.folder'"
  q_clauses <- or(c(folders, names))

  nodes <- drive_find(
    team_drive = team_drive,
    corpus = corpus,
    q = q_clauses,
    verbose = FALSE
  )

  if (any(is_rootpath(path))) {
    nodes <- rbind(nodes, root_folder())
  }

  promote(nodes, "parents")
}

## given a tibble of known nodes, resolve paths for leaves
## if leaf-hood not specified, all nodes are assumed to be leaves
## result = input, filtered down to leaves, unnested, with new 'path' variable
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
  nodes[c("name", "path", "id", "drive_resource")]
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
    ~pth(.x, kids = nodes$id, elders = nodes$parents, stop_value = root_id)
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
    ~purrr::map(
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
  nms <- as.list(rev(nms))
  rlang::exec(file.path, !!!nms)
}
