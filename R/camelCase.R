## taken from
## https://github.com/rstats-db/bigrquery/blob/master/R/camelCase.R

## ulimately belongs in gargle
## https://github.com/r-lib/gargle
## but googledrive will be released on CRAN before gargle

## camelCase vs snake_case policy
## ** all arguments in functions exported by googledrive shall be snake_case**
##
## HOWEVER, the Drive API is camelCase
## both wrt parameter names and many of their string values
## examples: `pageSize`, `mimeType`, `corpora = "allDrives"`
## therefore, whenever we pass `...` through, we process with toCamel()
## this means user can say `page_size = 20` and we send `pageSize = 20`
##
## we do not trumpet this snake_case to camelCase conversion in the docs,
## because many of the strings/values we handle are camelCase and we ARE not
## going to alter them
## there's too much potential for confusion
##
## at this point, snake_case to camelCase is a very quiet feature
camelCase <- function(x) {
  gsub("_(.)", "\\U\\1", x, perl = TRUE)
}

toCamel <- function(x) {
  if (is.list(x)) {
    x[] <- lapply(x, toCamel)
  }

  if (!is.null(names(x))) {
    names(x) <- camelCase(names(x))
  }

  x
}
