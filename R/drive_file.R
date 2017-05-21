#' Create a Google Drive file object
#'
#' @param id character, Google drive id for file of interest
#' @param ... name-value pairs to query the API
#'
#' @return object of class `gfile` and `list`
#' @export
#'
drive_file <- function(id, ...) {
  request <- build_request(
    endpoint = "drive.files.get",
    params = list(...,
                  fields = paste(.drive$default_fields, collapse = ","),
                  fileId = id)
  )
  response <- make_request(request)
  process_drive_file(response)
}


process_drive_file <- function(response = response) {
  proc_res <- process_request(response)

  metadata <- list(
    name = proc_res$name,
    id = proc_res$id,
    type = sub(".*\\.", "", proc_res$mimeType),
    owner = purrr::map_chr(proc_res$owners, "displayName"),
    last_modified = as.POSIXct(proc_res$modifiedTime),
    created = as.POSIXct(proc_res$createdTime),
    starred = proc_res$starred,
    #make a tibble of permissions - this seems a bit
    #silly how I've done it so far.
    permissions = if (is.null(proc_res$permissions)) {
      tibble::tibble(
        kind = character(),
        id = character(),
        type = character(),
        emailAddress = character(),
        role = character(),
        displayName = character(),
        photoLink = character(),
        deleted = character(),
        allowFileDiscovery = logical()
      )
    } else {
      purrr::map_df(proc_res$permissions, tibble::as_tibble)
    },
    #everything else
    kitchen_sink = proc_res
  )

  perm <- metadata$permissions

  if (sum(perm$id %in% c("anyone")) > 0) {
    access <-
      "Anyone on the internet can find and access. No sign-in required."
  } else if (sum(perm$id %in% c("anyoneWithLink")) > 0) {
    access <- "Anyone who has the link can access. No sign-in required."
  } else
    access <- "Shared with specific people."

  metadata$access <- access

  metadata <- structure(metadata, class = c("gfile", "list"))
  metadata
}

#' @export
print.gfile <- function(x, ...) {
  cat(
    sprintf(
      "File name: %s \nFile owner: %s \nFile type: %s \nLast modified: %s \nAccess: %s",
      x$name,
      x$owner,
      x$type,
      x$last_modified,
      x$access
    )
  )
  invisible(x)
}
