#' @description googledrive allows you to interact with files on Google Drive
#'   from R.
#'
#'   `googledrive::drive_find(n_max = 50)` lists up to 50 of the files you see
#'   in [My Drive](https://drive.google.com). You can expect to be sent to your
#'   browser here, to authenticate yourself and authorize the googledrive
#'   package to deal on your behalf with Google Drive.
#'
#'   Most functions begin with the prefix `drive_`.
#'
#'   The goal is to allow Drive access that feels similar to Unix file system
#'   utilities, e.g., `find`, `ls`, `mv`, `cp`, `mkdir`, and `rm`.
#'
#'   The metadata for one or more Drive files is held in a `dribble`, a "Drive
#'   tibble". This is a data frame with one row per file. A dribble is returned
#'   (and accepted) by almost every function in googledrive. It is designed to
#'   give people what they want (file name), track what the API wants (file id),
#'   and to hold the metadata needed for general file operations.
#'
#'   googledrive is "pipe-friendly" and, in fact, re-exports `%>%`, but does not
#'   require its use.
#'
#'   Please see the googledrive website for full documentation:
#'   * <https://googledrive.tidyverse.org/index.html>
#'
#'   In addition to function-specific help, there are several articles which are
#'   indexed here:
#'   * [Article index](https://googledrive.tidyverse.org/articles/index.html)
#'
#' @importFrom rlang %||%
#' @importFrom glue glue glue_data
#' @keywords internal
"_PACKAGE"
