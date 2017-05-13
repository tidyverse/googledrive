## from gh

has_names <- function(x){
  n <- names(x)
  if (is.null(n)){
    rep_len(FALSE, length(x))
  } else{
    !(is.na(n) | n == "")
  }
}

has_no_names <- function(x) all(!has_names(x))

clean_names <- function(x){
  if (has_no_names(x)){
    names(x) <- NULL
  }
  x
}

# fx
spf <- function(...) stop(sprintf(...), call. = FALSE)
