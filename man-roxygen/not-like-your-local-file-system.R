#' @section Special considerations for paths:
#' Note that Google Drive does NOT behave like your local file system:
#'   \itemize{
#'   \item File and folder names need not be unique, even at a given level of
#'   the hierarchy. A single name or file path can be associated with multiple
#'   files (or zero or exactly one).
#'   \item A file can have more than one direct parent. This implies that a
#'   single file can be represented by multiple paths.
#'   }
#'
#' Bottom line: Do not assume there is a one-to-one relationship between file
#' name or path and a Drive file or folder. This implies the length of the input
#' (i.e. the number of input paths or the number of rows in a dribble) will not
#' necessarily equal the number rows in the output.
