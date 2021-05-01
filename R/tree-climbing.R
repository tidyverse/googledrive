## the recursive workhorse that walks up a file tree
##
## enumerates paths in a list
## each component is a character vector:
## id --> parent of id --> grandparent of id --> ... END
## END is either stop_value (root folder id for us) or NA_character_
pth <- function(id, kids, elders, stop_value) {
  this <- last(id)

  if (identical(this, stop_value)) {
    return(list(id))
  }

  i <- which(kids == this)

  if (length(i) > 1) {
    abort(c(
      "This id appears more than once in the role of {.field kid}:",
      "*" = "{.field {kids[i[1]]}}"
    ))
  }

  if (length(i) < 1) {
    return(list(c(id, NA)))
  }

  parents <- elders[[i]]

  if (is.null(parents)) {
    return(list(c(id, NA)))
  }

  seen_before <- intersect(id, parents)
  if (length(seen_before)) {
    abort(c(
      "This id has itself as parent, possibly indirect:",
      "*" = "{.field {seen_before}}",
      "Cycles are not allowed."
    ))
  }

  ## keep climbing
  unlist(
    lapply(parents, function(p) pth(c(id, p), kids, elders, stop_value)),
    recursive = FALSE
  )
}
