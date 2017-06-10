drive_fields <- function(fields = NULL,
                         prep = TRUE,
                         which = c("default", "all")) {
  which <- match.arg(which)
  if (is.null(fields)) {
    out <- switch(
      which,
      default = .drive$files_fields$name[.drive$files_fields$default],
      all = .drive$files_fields$name)
  } else {
    stopifnot(is.character(fields))
    out <- intersect(fields, .drive$files_fields$name)
    if (!setequal(fields, ok)) {
      warning(
        glue::collapse(
          c("Ignoring fields that are non-standard for the files resource:",
            setdiff(fields, ok)),
          sep = "\n"
        )
      )
    }
  }
  if (prep) {
    prep_fields(out)
  } else {
    out
  }
}

prep_fields <- function(fields, resource = "files") {
  collapse2(glue::glue("{resource}/{fields}"), sep = ",")
}
