# nocov start

param_path <- function(thing = "THING", default_notes = "") {
  glue("
    @param path Specifies target destination for the {thing} on Google
      Drive. Can be an actual path (character), a file id marked with
      [as_id()], or a [`dribble`]. If specified as an actual path, it is best
      to explicitly indicate if it's a folder by including a trailing slash,
      since it cannot always be worked out from the context of the call.
      {default_notes}")
}

param_name <- function(thing = "THING", default_notes = "") {
  glue("
    @param name Character, new {thing} name if not specified as part of
      `path`. This will force `path` to be interpreted as a folder, even if it
      is character and lacks a trailing slash. {default_notes}")
}

return_dribble <- function(extras = "") {
  glue("
    @return An object of class [`dribble`], a tibble with one row per item.
    {extras}")
}

# nocov end
