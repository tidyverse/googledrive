#' Query paths.
#'
#' These functions query files that match one or more paths. The plural `s` of
#' `paths` conveys whether you are allowed to provide more than one input path.
#' Be aware that you can get more than one file back even when the input is a
#' single path! Drive file and folder names need not be unique, even at a given
#' level of the hierarchy. A file or folder can also have multiple parents. Note
#' also that a folder is just a specific type of file on Drive.
#'
#' @param path Character vector of path(s) to query. Use a trailing slash to
#'   indicate explicitly that the path is a folder, which can disambiguate if
#'   there is a file of the same name (yes this is possible on Drive!).
#' @template verbose
#'
#' @name paths
#' @seealso If you want to list the contents of a folder, use [drive_ls()]. For
#'   general searching, use [drive_search()].
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
#'
#' ## limit to files with your My Drive root folder as direct parent
#' drive_path("~/def")
#'
#' ## use the plural forms to query multiple paths at once
#' drive_paths_exist(c("abc", "def"))
#' drive_paths(c("abc", "def"))
#' }
NULL

#' @export
#' @rdname paths
#' @return `drive_path_exists()`: a single `TRUE` or `FALSE`
drive_path_exists <- function(path, verbose = TRUE) {
  stopifnot(is.character(path))
  if (length(path) < 1) return(logical(0))
  nrow(get_paths(path = path, partial_ok = FALSE)) > 0
}

#' @export
#' @rdname paths
#' @return `drive_paths_exist()`: Logical vector of same length as input
drive_paths_exist <- function(path, verbose = TRUE) {
  purrr::map_lgl(path, drive_path_exists)
}

#' @export
#' @rdname paths
#' @template dribble-return
drive_path <- function(path = "~/", verbose = TRUE) {
  stopifnot(is.character(path))
  if (length(path) < 1) return(dribble())
  stopifnot(length(path) == 1)
  path_tbl <- get_paths(path = path, partial_ok = FALSE)
  as_dribble(path_tbl[names(path_tbl) != "path"])
}

#' @export
#' @rdname paths
#' @template dribble-return
drive_paths <- function(path = "~/", verbose = TRUE) {
  stopifnot(is.character(path))
  if (length(path) < 1) return(dribble())
  do.call(rbind, purrr::map(path, drive_path))
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
  stopifnot(is.character(path), length(path) == 1)
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
    .rships <- drive_search(
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
    ## parent not found, end it here with sentinel NA
    list(c(id, NA))
  } else {
    parents <- elders[[i]]
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
  nms <- glue::glue("name = {sq(path_pieces)}")
  leaf_q <- utils::tail(nms, !leaf_is_folder)
  dirs_q <- glue::glue(
    "(({dir_pieces}) and mimeType = 'application/vnd.google-apps.folder')",
    dir_pieces = glue::collapse(crop(nms, !leaf_is_folder), sep = " or ")
  )
  glue::collapse(c(leaf_q, dirs_q), last = " or ")
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
  glue::collapse(pth_nms, sep = "/")
}
