#' @description Note that Google Drive does NOT behave like your local file
#'   system:
#'   \itemize{
#'   \item File and folder names need not be unique, even at a given level of
#'   the hierarchy. A single name or file path can be associated with multiple
#'   files (or zero or exactly one).
#'   \item A file can have more than one direct parent. This implies that a
#'   single file can be represented by multiple paths.
#'   }
#' @description Bottom line: Do not assume there is a one-to-one relationship
#'   between file name or path and a Drive file or folder. A file id is unique,
#'   which is why googledrive workflows favor storage in a
#'   \code{\link{dribble}}, which holds metadata aimed at computers (file id)
#'   and humans (file name). Finally, note also that a folder is just a specific
#'   type of file on Drive.
