get_leafmost_id <- function(path) {

  path_pieces <- unlist(strsplit(path, "/"))

  root_id <- root_folder() ## store so we don't make repeated API calls

  if (all(path_pieces == "~")) {
    return(root_id)
  }

  ## remove ~ if it was added to the beginning of the path (like ~/foo/bar/baz instead of foo/bar/baz)
  if (path_pieces[1] == "~") {
    path_pieces <- path_pieces[-1]
  }

  d <- length(path_pieces)
  path_pattern <- paste0("^", path_pieces, "$", collapse = "|")
  folders <- drive_list(
    pattern = path_pattern,
    fields = "files/parents,files/name,files/mimeType,files/id",
    q = "mimeType='application/vnd.google-apps.folder'",
    verbose = FALSE
  )

  if (!all(path_pieces %in% folders$name)){
    spf("We could not find the file path '%s' on your Google Drive", path)
  }
  ## guarantee: we have found at least one folder with correct name for
  ## each piece of path

  folders$depth <- match(folders$name, path_pieces)
  folders <- folders[order(folders$depth), ]

  ## the candidate return value(s)
  folder <- folders$id[folders$depth == d]

  ## TO DO:
  ## add a test case that explores path = foo/bar/baz when
  ## foo/yo/baz also exists, i.e. when folder will be of length >1 here

  ## can you get from folder to root by traversing a child-->parent chain
  ## within this set of folders?

  ## TO DO: add this as a test
  ## path = foo/bar/baz
  ## foo/bar/baz DOES exist
  ## but there are two folders named bar under foo, one of which hosts baz

  parent_is_present <- purrr::map_lgl(
    folders$parents,
    ~ any(.x %in% folders$id) | root_id %in% .x
  )
  parents <- folders$parents %>% purrr::flatten() %>% purrr::simplify()
  child_is_present <- purrr::map_lgl(
    folders$id,
    ~ .x %in% parents | .x %in% folder
  )

  ## pare down, now we know all but the final layer
  folders <- folders[parent_is_present & child_is_present, ]

  ## I have to rerun this because if there are x folders named foo and
  ## the one we are interested in is in the root, we will have multiple
  ## in "folder", but just want one.
  folder <- folders$id[folders$depth == d]

  # if there are multiple in depth d & it isn't the root
  if (length(folder) > 1) {
    leafmost_parent <- folders[folders$depth == d - 1, ]

    ## if there are 2 leafmost parents that got to this point, we have a
    ## double naming, throw an error
    if (length(leafmost_parent) > 1) {
      spf("The path '%s' is not uniquely defined.", path)
    }
    child_is_leafmost <- purrr::map_lgl(
      folders$parents,
      ~ .x == leafmost_parent$id
    )
    folder <- folders$id[child_is_leafmost]
  }
  if (!all(seq_len(d) %in% folders$depth)) {
    spf("Path not found: '%s'", path)
  }
  if (length(folder) > 1) {
    spf("Path is not unique: '%s'", path)
  }
  folder
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
