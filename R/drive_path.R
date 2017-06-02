#' Query a path on Google Drive.
#'
#' These functions gather information about a single path, which may very well
#' correspond to more than one file. Note that a folder is a specific type of
#' file on Drive. If you want to list the contents of a folder or do general
#' searching, use [drive_search()].
#'
#' @param path Character. A single path to query on Google Drive. All matching
#'   files are returned. Folders are a specific type of file. Use a trailing
#'   slash to indicate explicitly that the path is a folder, which can
#'   disambiguate if there is a file of the same name (yes this is possible on
#'   Drive!).
#' @template verbose
#'
#' @template dribble-return
#' @name paths
#' @examples
#' \dontrun{
#' ## get info about your "My Drive" root folder
#' drive_path()
#' drive_path("~/")
#'
#' ## determine if path 'abc' exists and list matching paths
#' drive_path_exists("abc")
#' drive_path("abc")
#'
#' ## be more specific: consider only folder(s) that match 'abc'
#' drive_path_exists("abc/")
#' drive_path("abc/")
#' }
NULL

#' @export
#' @rdname paths
#' @return `drive_path_exists()`: `TRUE` or `FALSE`
drive_path_exists <- function(path, verbose = TRUE) {
  nrow(get_paths(path = path, partial_ok = FALSE)) > 0
}

#' @export
#' @rdname paths
#' @template dribble-return
drive_path <- function(path = "~/", verbose = TRUE) {
  path_tbl <- get_paths(path = path, partial_ok = FALSE)
  as_dribble(path_tbl[names(path_tbl) != "path"])
}

## path helpers -------------------------------------------------------

## input:
##   path: a target path
##   partial_ok: if path does not exist, but some prefix does, ok to report that?
##   .rships, .root: (optional) tibble of relationships & id of the root folder
##         for internal use, i.e. testing logic without calling the API
## output:
##   a dribble of Drive files whose paths match the target
##   if partial_ok = FALSE, match(es) is/are exact
##   if partial_ok = TRUE, match(es) is/are on the maximally existing partial path
get_paths <- function(path = NULL,
                      partial_ok = FALSE,
                      .rships = NULL,
                      .root = "ROOT") {
  stopifnot(is.character(path), length(path) == 1)
  if (is_root(path)) {
    return(tibble::add_column(root_folder(), path = "~/"))
  }
  path <- normalize_path(path)
  path_pieces <- split_path(path)
  d <- length(path_pieces)
  if (d == 0) {
    return(tibble::add_column(dribble(), path = character(0)))
  }

  if (is.null(.rships)) {
    ## query restricts to names in path_pieces and, for all pieces that are
    ## known to be folder, to mimeType = folder
    .rships <- drive_search(
      fields = "files/parents,files/name,files/mimeType,files/id,files/kind,files/owners",
      q = form_query(path_pieces, leaf_is_folder = grepl("/$", path)),
      verbose = FALSE
    )
    .rships <- promote(.rships, "parents")
    ## fetch fileId of user's My Drive root folder
    .root <- root_id()
  }

  ## revise target path to be longest partial path that is compatible
  ## with folder names that exist
  nm_detected <- purrr::set_names(path_pieces %in% .rships$name, path_pieces)
  d <- last_all(nm_detected)
  if (d == 0 || (!partial_ok && d < length(path_pieces))) {
    return(dribble())
  }

  repeat {
    ## leaf candidate(s)
    leaf_id <- .rships$id[.rships$name == path_pieces[d]]

    ## for each candidate, enumerate all rooted paths
    leaf_tbl <- leaf_id %>%
      purrr::map(pth_tbl, .rships = .rships, stop_value = .root)
    leaf_tbl <- do.call(rbind, leaf_tbl)

    ## require path to match target, in manner appropriate to partial_ok
    ## glue::glue() gives me this: length 0 in --> length 0 out
    path_matches <- purrr::map_lgl(
      glue::glue("^{leaf_tbl$path}{if (partial_ok) '' else '$'}"),
      grepl, x = strip_slash(path)
    )
    leaf_tbl <- leaf_tbl[path_matches, ]

    if (d == 1 || !partial_ok || nrow(leaf_tbl) > 0) {
      break
    }
    d <- d - 1
  }

  ## remove the parents column
  ## keep the non-standard path column for downstream internal use, i.e.
  ## determining how much of a path exists vs. we need to build
  cols_to_keep <- ! names(leaf_tbl) %in% "parents"
  as_dribble(leaf_tbl[cols_to_keep])
}

## calls pth() on one id
## returns a tibble that replicates the relevant row of .rships
## once per rooted path found
## adds a variable of the corresponding paths
pth_tbl <- function(id, .rships, stop_value) {
  i <- which(.rships$id == id)
  paths <- pth(
    id,
    kids = .rships$id,
    elders = .rships$parents,
    stop_value = stop_value
  )
  rooted_paths <- purrr::keep(paths, ~ !is.na(last(.x)))
  path <- purrr::map_chr(
    rooted_paths,
    ~ collapse2(rev(.rships$name[match(crop(.x, 1), .rships$id)]), sep = "/")
  )
  tbl <- .rships[rep_len(i, length(path)), ]
  tibble::add_column(tbl, path)
}

## enumerates paths in a list
## each component is a character vector:
## id --> parent of id --> grandparent of id --> ... END
## END is either stop_value (root folder id for us) or NA_character_
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

## path utilities -----------------------------------------------------

## path  path pieces  dir pieces  leaf pieces
## a/b/  a b          a b
## a/b   a b          a           b
## a/    a            a
## a     a                        a
form_query <- function(path_pieces, leaf_is_folder = FALSE) {
  nms <- glue::glue("name = {sq(path_pieces)}")
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

## "a/b/" and "a/b" both return "a/b/"
append_slash <- function(path) {
  if (length(path) < 1 || path == "") return(path)
  ifelse(grepl("/$", path), path, paste0(path, "/"))
}

## "a/b/" and "a/b" both return "a/b"
strip_slash <- function(path) {
  gsub("/$", "", path)
}

split_path <- function(path = "") {
  path <- path %||% ""
  path <- sub("^~?/*", "", path)
  unlist(strsplit(path, "/"))
}

unsplit_path <- function(...) {
  gsub("^/*", "", file.path(...))
}

null_path <- function() {
  tibble::tibble(
    id = character(), path = character(), mimeType = character(),
    parent_id = character(), root_path = list(), path_orig = character()
  )
}

is_root <- function(path) {
  length(path) == 1 && is.character(path) && grepl("^~$|^/$|^~/$", path)
}

root_folder <- function() drive_get('root')

root_id <- function() root_folder()$id
