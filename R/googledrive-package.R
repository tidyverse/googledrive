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
#' @importFrom rlang %||% :=
#' @importFrom glue glue glue_data glue_collapse
#' @importFrom lifecycle deprecated
#' @keywords internal
"_PACKAGE"


## This function is never called
## Exists to suppress this NOTE:
## "Namespaces in Imports field not imported from:"
## https://github.com/opencpu/opencpu/blob/10469ee3ddde0d0dca85bd96d2873869d1a64cd6/R/utils.R#L156-L165
stub <- function() {
  ## I have to use curl directly somewhere, if I import it.
  ## I have to import it if I want to state a minimum version.
  curl::curl_version()
}
