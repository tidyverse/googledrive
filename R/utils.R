# fx
spf <- function(...) stop(sprintf(...), call. = FALSE)

last <- function(x) x[length(x)]

sq <- function(x) glue::single_quote(x)

## removes last abs(n) elements
crop <- function(x, n = 6L) if (n == 0) x else utils::head(x, -1 * abs(n))

## finds max i such that all(x[1:i])
last_all <- function(x) {
  Position(isTRUE, as.logical(cumprod(x)), right = TRUE, nomatch = 0)
}

## Sys.getenv() but for exactly 1 env var and returns NULL if unset
Sys_getenv <- function(x) {
  stopifnot(length(x) == 1)
  out <- Sys.getenv(x = x, unset = NA_character_)
  if (is.na(out)) NULL else out
}

## vectorized isTRUE()
is_true <- function(x) vapply(x, isTRUE, logical(1))
