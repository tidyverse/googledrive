#' Get Drive files by path or id
#'
#' Retrieves metadata for files specified via `path` or via file `id`. This
#' function is quite straightforward if you specify files by `id`. But there are
#' some important considerations when you specify your target files by `path`.
#' See below for more. If the target files are specified via `path`, the
#' returned [`dribble`] will include a `path` column.

#' @section Getting by `path`:
#'
#'   Google Drive does NOT behave like your local file system! File and folder
#'   names need not be unique, even at a given level of the hierarchy. This
#'   means that a single path can describe multiple files (or 0 or exactly 1).
#'
#'   A single file can also be compatible with multiple paths, i.e. one path
#'   could be more specific than the other. A file located at `~/alfa/bravo` can
#'   be found as `bravo`, `alfa/bravo`, and `~/alfa/bravo`. If all 3 of those
#'   were included in the input `path`, they would be represented by a
#'   **single** row in the output.
#'
#'   Therefore, it's best to think of `drive_get()` as a setwise operation when
#'   using file paths. Do not assume that the `i`-th input path corresponds to
#'   row `i` in the output (although it often does!). If there's not a 1-to-1
#'   relationship between the input and output, this will be announced in a
#'   message.

#' @section Files that you don't own:
#'
#'   If you want to get a file via `path` and it's not necessarily on your My
#'   Drive, you may need to specify the `shared_drive` or `corpus` arguments to
#'   search other collections of items. Read more about [shared
#'   drives][shared_drives].
#'
#' @seealso To add path information to any [`dribble`] that lacks it, use
#'   [`drive_reveal(d, "path")`][drive_reveal()]. To list the contents of a
#'   folder, use [drive_ls()]. For general searching, use [drive_find()].
#'
#' Wraps the `files.get` endpoint and, if you specify files by name or
#'   path, also calls `files.list`:
#'   * <https://developers.google.com/drive/api/v3/reference/files/get>
#'   * <https://developers.google.com/drive/api/v3/reference/files/list>
#'
#' @param path Character vector of path(s) to get. Use a trailing slash to
#'   indicate explicitly that a path is a folder, which can disambiguate if
#'   there is a file of the same name (yes this is possible on Drive!). If
#'   `path` appears to contain Drive URLs or is explicitly marked with
#'   [as_id()], it is treated as if it was provided via the `id` argument.
#' @param id Character vector of Drive file ids or URLs (it is first processed
#'   with [as_id()]). If both `path` and `id` are non-`NULL`, `id` is silently
#'   ignored.
#' @template shared_drive-singular
#' @template corpus
#' @template verbose
#' @template team_drive-singular
#'
#' @template dribble-return
#' @export
#'
#' @examplesIf drive_has_token()
#' # get info about your "My Drive" root folder
#' drive_get("~/")
#' # the API reserves the file id "root" for your root folder
#' drive_get(id = "root")
#' drive_get(id = "root") %>% drive_reveal("path")
#'
#' # set up some files to get by path
#' alfalfa <- drive_mkdir("alfalfa")
#' broccoli <- drive_upload(
#'   drive_example("chicken.txt"),
#'   name = "broccoli", path = alfalfa
#' )
#' drive_get("broccoli")
#' drive_get("alfalfa/broccoli")
#' drive_get("~/alfalfa/broccoli")
#' drive_get(c("broccoli", "alfalfa/", "~/alfalfa/broccoli"))
#'
#' # clean up
#' drive_rm(alfalfa)
#'
#' \dontrun{
#' # The examples below are indicative of correct syntax.
#' # But note these will generally result in an error or a
#' # 0-row dribble, unless you replace the inputs with paths
#' # or file ids that exist in your Drive.
#'
#' # multiple names
#' drive_get(c("abc", "def"))
#'
#' # multiple names, one of which must be a folder
#' drive_get(c("abc", "def/"))
#'
#' # query by file id(s)
#' drive_get(id = "abcdefgeh123456789")
#' drive_get(as_id("abcdefgeh123456789"))
#' drive_get(id = c("abcdefgh123456789", "jklmnopq123456789"))
#'
#' # apply to a browser URL for, e.g., a Google Sheet
#' my_url <- "https://docs.google.com/spreadsheets/d/FILE_ID/edit#gid=SHEET_ID"
#' drive_get(my_url)
#' drive_get(as_id(my_url))
#' drive_get(id = my_url)
#'
#' # access the shared drive named "foo"
#' # shared_drive params must be specified if getting by path
#' foo <- shared_drive_get("foo")
#' drive_get(c("this.jpg", "that-file"), shared_drive = foo)
#' # shared_drive params are not necessary if getting by id
#' drive_get(as_id("123456789"))
#'
#' # search all shared drives and other files user has accessed
#' drive_get(c("this.jpg", "that-file"), corpus = "allDrives")
#' }
drive_get <- function(path = NULL,
                      id = NULL,
                      shared_drive = NULL,
                      corpus = NULL,
                      verbose = deprecated(),
                      team_drive = deprecated()) {
  warn_for_verbose(verbose)
  if (length(path) + length(id) == 0) return(dribble_with_path())
  stopifnot(is.null(path) || is.character(path))
  stopifnot(is.null(id) || is.character(id))

  if (lifecycle::is_present(team_drive)) {
    lifecycle::deprecate_warn(
      "2.0.0",
      "drive_get(team_drive)",
      "drive_get(shared_drive)"
    )
    shared_drive <- shared_drive %||% team_drive
  }

  if (!is.null(path) && any(is_drive_url(path))) {
    path <- as_id(path)
  }

  if (!is.null(path) && inherits(path, "drive_id")) {
    id <- path
    path <- NULL
  }

  if (is.null(path)) {
    as_dribble(map(as_id(id), get_one_file))
  } else {
    drive_get_path(path, shared_drive, corpus)
  }
}

get_one_file <- function(id) {
  # when id = "", drive.files.get actually becomes a call to drive.files.list
  # and, therefore, returns 100 files by default ... don't let that happen
  if (!isTRUE(nzchar(id, keepNA = TRUE))) {
    cli_abort("File ids must not be {.code NA} and cannot be the empty string.")
  }
  request <- request_generate(
    endpoint = "drive.files.get",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- request_make(request)
  gargle::response_process(response)
}
