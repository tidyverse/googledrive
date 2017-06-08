# fx
spf <- function(...) stop(sprintf(...), call. = FALSE)

last <- function(x) x[length(x)]

sq <- function(x) glue::single_quote(x)

## removes last abs(n) elements
crop <- function(x, n = 6L) if (n == 0) x else utils::head(x, -1 * abs(n))

## version of glue::collapse() that returns x if length(x) == 0
collapse2 <- function(x, sep = "", width = Inf, last = "") {
  if (length(x) == 0) {
    x
  } else
    glue::collapse(x = x, sep = sep, width = width, last = last)
}

## finds max i such that all(x[1:i])
last_all <- function(x) {
  Position(isTRUE, as.logical(cumprod(x)), right = TRUE, nomatch = 0)
}
