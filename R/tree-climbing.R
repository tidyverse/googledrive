## the recursive workhorse that walks up a file tree
##
## enumerates paths in a list
## each component is a character vector:
## id --> parent of id --> grandparent of id --> ... END
## END is either stop_value (root folder id for us) or NA_character_
pth <- function(id, kids, elders, stop_value) {
  if (identical(id, stop_value)) {
    return(list(id))
  }

  this <- last(id)
  i <- which(kids == this)

  if (length(i) > 1) {
    sglue("\nThis id appears more than once in the role of 'kid':\n",
          "  * {sq(kids[i[1]])}")
  }

  if (length(i) < 1) {
    return(list(c(id, NA)))
  }

  parents <- elders[[i]]

  seen_before <- intersect(id, parents)
  if (length(seen_before)) {
    scollapse(c(
      "This id has itself as parent, possibly indirect:",
      sq(seen_before),
      "Cycles are not allowed."
    ))
  }

  if (is.null(parents)) {
    return(list(c(id, NA)))
  }

  if (stop_value %in% parents) {
    return(list(c(id, stop_value)))
  }

  ## keep climbing
  unlist(
    lapply(parents, function(p) pth(c(id, p), kids, elders, stop_value)),
    recursive = FALSE
  )
}
