# googledrive *development version*

* The storage of OAuth tokens has been reworked to encourage storage outside the project, to encourage token reuse, and to better accomodate multiple Google identities.

  - Path of least resistance for typical user: delete a pre-existing `.httr-oauth`. Let yourself be guided through the OAuth browser flow to get a new token, cached in the new way (by default, in `~/.R/gargle/gargle-oauth`).

* The gargle package (currently GitHub-only) is used under-the-hood for operations that are generic across many Google APIs, e.g. auth and request formation. The main user-facing change is that OAuth tokens are now stored in a user-level cache, by default (see separate bullet). There are other small changes to the low-level developer-facing API (#102, #204):

  - The arguments and usage of `drive_auth()` and `drive_auth_config()` have changed. See their docs for details.
  - `generate_request()` has been renamed to `request_generate()`.
  - `make_request()` had been renamed to `request_make()` and is a very thin wrapper around `gargle::request_make()` that only adds googledrive's user agent.
  - `build_request()` has been removed. If you can't do what you need with `request_generate()`, use `gargle::request_develop()` or `gargle::request_build()`.
  - `drive_oauth_app()` is a newly exported function that exposes the current OAuth app.

# googledrive 0.1.3

Minor patch release for compatibility with the imminent release of purrr 0.3.0.

# googledrive 0.1.2

* Internal usage of `glue::collapse()` modified to call `glue::glue_collapse()` if glue v1.3.0 or later is installed and `glue::collapse()` otherwise. Eliminates a deprecation warning emanating from glue. (#222 @jimhester)

# googledrive 0.1.1

* initial CRAN release
