drive_path_exists <- function(path, verbose = TRUE) {
  stopifnot(is_path(path))
  if (length(path) < 1) return(logical(0))
  stopifnot(length(path) == 1)
  nrow(drive_get(path = path)) > 0
}

## path helpers -------------------------------------------------------

## input:
##   path: a single target path, e.g. "~/", "abc", "~/abc", "a/b/c"
##   partial_ok: if path does not exist, but some prefix does, ok to report that?
##   .rships, .root: (optional) tibble of relationships & id of the root folder
##         for internal use, i.e. testing logic without calling the API
## output:
##   a dribble of Drive files whose paths match the target
##   if partial_ok = FALSE, match(es) is/are exact
##   if partial_ok = TRUE, match(es) is/are on maximally existing partial path
##   output contains an extra column, `path`, with the effective target path
get_paths <- function(path = NULL,
                      partial_ok = FALSE,
                      .rships = NULL,
                      .root = "ROOT") {
  stopifnot(is_path(path), length(path) == 1)
  path <- rootize_path(path)
  if (is_root(path)) {
    return(tibble::add_column(root_folder(), path = path))
  }

  path_pieces <- split_path(path)
  d <- length(path_pieces)
  if (d == 0) {
    return(tibble::add_column(dribble(), path = character(0)))
  }
  rooted <- path_pieces[1] == "~"
  path_pieces <- if (rooted) path_pieces[-1] else path_pieces

  if (is.null(.rships)) {
    ## query restricts to names in path_pieces and, for all pieces that are
    ## known to be folder, to mimeType = folder
    .rships <- drive_find(
      fields = "*",
      q = form_query(path_pieces, leaf_is_folder = grepl("/$", path)),
      verbose = FALSE
    )
    .rships <- promote(.rships, "parents")
    ## fetch fileId of user's My Drive root folder
    .root <- root_id()
  } else {
    .rships <- .rships[.rships$name %in% path_pieces, ]
  }

  ## input path is just a name
  if (d == 1) {
    return(
      tibble::add_column(
        .rships[c("name", "id", "files_resource")],
        path = path_pieces
      )
    )
  }

  ## input path has > 1 pieces

  ## revise target path to be longest partial path that is compatible
  ## with folder names that exist
  nm_detected <- purrr::set_names(path_pieces %in% .rships$name, path_pieces)
  d <- last_all(nm_detected)
  if (d < length(path_pieces) && !partial_ok) {
    return(tibble::add_column(dribble(), path = character(0)))
  }

  repeat {
    ## leaf candidate(s)
    leaf_id <- .rships$id[.rships$name == path_pieces[d]]

    ## for each candidate, enumerate all paths
    leaf_tbl <- leaf_id %>%
      purrr::map(pth_tbl, .rships = .rships, stop_value = .root)
    leaf_tbl <- do.call(rbind, leaf_tbl)

    ## require rooted paths if input was rooted
    if (rooted) {
      is_rooted <- purrr::map_lgl(leaf_tbl$pths, ~ !is.na(last(.x)))
      leaf_tbl <- leaf_tbl[is_rooted, ]
    }

    ## form the path, as a string
    leaf_tbl$path <- purrr::map_chr(
      leaf_tbl$pths,
      ~ make_path(
        .x,
        ids = .rships$id, nms = .rships$name, rooted = rooted, d = d
      )
    )

    ## require path to match target, in manner appropriate to partial_ok
    ## glue() gives me this: length 0 in --> length 0 out
    path_matches <- purrr::map_lgl(
      glue("^{leaf_tbl$path}{if (partial_ok) '' else '$'}"),
      grepl, x = strip_slash(path)
    )
    leaf_tbl <- leaf_tbl[path_matches, ]

    if (d == 1 || !partial_ok || nrow(leaf_tbl) > 0) {
      break
    }
    d <- d - 1
  }

  ## remove the parents and pths columns
  ## but keep the non-standard path column for downstream internal use, i.e.
  ## determining how much of a path exists vs. what we need to build
  nms_to_remove <- c("parents", "pths")
  leaf_tbl <- as_dribble(leaf_tbl[!names(leaf_tbl) %in% nms_to_remove])

  ## ensure only 1 row per id
  ## rare but possible: multiple distinct paths that have same path string
  ## recall that files can have multiple parents and names need not be unique
  leaf_tbl[!duplicated(leaf_tbl$id), ]

}

## calls pth() on one id
## returns a tibble that replicates the relevant row of .rships
## once per rooted path found
## adds the paths as the variable `pths` = a list-column of character vectors
pth_tbl <- function(id, .rships, stop_value) {
  i <- which(.rships$id == id)
  pths <- pth(
    id,
    kids = .rships$id,
    elders = .rships$parents,
    stop_value = stop_value
  )
  tbl <- .rships[rep_len(i, length(pths)), ]
  tibble::add_column(tbl, pths)
}

## enumerates paths in a list
## each component is a character vector:
## id --> parent of id --> grandparent of id --> ... END
## END is either stop_value (root folder id for us) or NA_character_
pth <- function(id, kids, elders, stop_value) {
  this <- last(id)
  i <- which(kids == this)
  if (length(i) < 1) {
    ## id not present as a 'kid', end it here with sentinel NA
    list(c(id, NA))
  } else {
    parents <- elders[[i]]
    seen_before <- intersect(id, parents)
    if (length(seen_before)) {
      msg <- c(
        "This id has itself as parent, possibly indirect:",
        sq(seen_before),
        "Cycles are not allowed."
      )
      stop(collapse(msg, sep = "\n"), call. = FALSE)
    }
    if (is.null(parents)) {
      ## parents not given, end it here with sentinel NA
      return(list(c(id, NA)))
    }
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

## path  path pieces  dir pieces  leaf pieces
## a/b/  a b          a b
## a/b   a b          a           b
## a/    a            a
## a     a                        a
form_query <- function(path_pieces, leaf_is_folder = FALSE) {
  nms <- glue("name = {sq(path_pieces)}")
  leaf_q <- utils::tail(nms, !leaf_is_folder)
  dirs_q <- glue(
    "(({dir_pieces}) and mimeType = 'application/vnd.google-apps.folder')",
    dir_pieces = collapse(crop(nms, !leaf_is_folder), sep = " or ")
  )
  collapse(c(leaf_q, dirs_q), last = " or ")
}

## pth is a character vector of ids produced by pth() aboven
## here we look up the names of those ids and make a string for the path
make_path <- function(pth, ids, nms, rooted, d) {
  pth <- rev(pth)
  pth_nms <- nms[match(pth, ids)]
  if (rooted) {
    pth_nms[1] <- "~"
  } else {
    pth_nms <- pth_nms[-1]
  }
  pth_nms <- utils::tail(pth_nms, d + rooted)
  collapse(pth_nms, sep = "/")
}
