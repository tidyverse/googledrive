# googledrive 1.0.0

The release of version 1.0.0 marks two events:

  * The overall design of googledrive has survived ~2 years on CRAN, with very little need for change. The API and feature set is fairly stable.
  * There are changes in the auth interface that are not backwards compatible.

## Auth from gargle

googledrive's auth functionality now comes from the [gargle package](https://gargle.r-lib.org), which provides R infrastructure to work with Google APIs, in general. The same transition is underway in several other packages, such as [bigrquery](https://bigrquery.r-dbi.org). This will make user interfaces more consistent and makes two new token flows available in googledrive:

  * Application Default Credentials
  * Service account tokens from the metadata server available to VMs running on GCE
  
Where to learn more:
  
  * Help for [`drive_auth()`](https://googledrive.tidyverse.org/reference/drive_auth.html) *all that most users need*
  * *details for more advanced users*
    - [How gargle gets tokens](https://gargle.r-lib.org/articles/how-gargle-gets-tokens.html)
    - [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html)
    - [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html) 

### Changes that a user will notice

OAuth2 tokens are now cached at the user level, by default, instead of in `.httr-oauth` in the current project. We recommend that you delete any vestigial `.httr-oauth` files lying around your googledrive projects and re-authorize googledrive, i.e. get a new token, stored in the new way.

The OAuth2 token key-value store now incorporates the associated Google user when indexing, which makes it easier to switch between Google identities.

The arguments and usage of `drive_auth()` have changed.

  * Previous signature (v0.1.3 and earlier)
  
    ``` r  
    drive_auth(
      oauth_token = NULL,
      service_token = NULL,
      reset = FALSE,
      cache = getOption("httr_oauth_cache"),
      use_oob = getOption("httr_oob_default"),
      verbose = TRUE
    )
    ```
  
  * Current signature (>= v1.0.0)
  
    ``` r
    drive_auth(
      email = gargle::gargle_oauth_email(),
      path = NULL,
      scopes = "https://www.googleapis.com/auth/drive",
      cache = gargle::gargle_oauth_cache(),
      use_oob = gargle::gargle_oob_default(),
      token = NULL
    )
    ```

For full details see the resources listed in *Where to learn more* above. The change that probably affects the most code is the way to provide a service account token:
  - Previously: `drive_auth(service_token = "/path/to/your/service-account.json")` (v0.1.3 and earlier)
  - Now: `drive_auth(path = "/path/to/your/service-account.json")` (>= v1.0.0)

Auth configuration has also changed:

  * `drive_auth_configure()` is a variant of the now-deprecated `drive_auth_config()` whose explicit and only job is to *set* aspects of the configuration, i.e. the OAuth app or API key.
    - Use `drive_oauth_app()` and `drive_api_key()` to *retrieve* a user-configured app or API key, if such exist.
      - These functions no longer return built-in auth assets, although built-in assets still exist and are used in the absence of user configuration.
  * `drive_deauth()` is how you go into a de-authorized state, i.e. send an API key in lieu of a token.
  
`drive_has_token()` is a new helper that simply reports whether a token is in place, without triggering the auth flow, as `drive_token()` would do.

There are other small changes to the low-level developer-facing API:

  - `generate_request()` has been renamed to `request_generate()`.
  - `make_request()` had been renamed to `request_make()` and is a very thin wrapper around `gargle::request_make()` that only adds googledrive's user agent.
  - `build_request()` has been removed. If you can't do what you need with `request_generate()`, use `gargle::request_develop()` or `gargle::request_build()`.
  - `process_response()` has been removed. Instead, use `gargle::response_process(response)`, as we do inside googledrive.

## Other changes

`drive_create()` is a new function that creates a new empty file, with an optional file type specification (#258, @ianmcook). `drive_mkdir()` becomes a thin wrapper around `drive_create()`, with the file type hard-wired to "folder".

## Dependency changes

R 3.1 is no longer explicitly supported or tested. Our general practice is to support the current release (3.6), devel, and the 4 previous versions of R (3.5, 3.4, 3.3, 3.2).

gargle and magrittr are newly Imported.

# googledrive 0.1.3

Minor patch release for compatibility with the imminent release of purrr 0.3.0.

# googledrive 0.1.2

* Internal usage of `glue::collapse()` modified to call `glue::glue_collapse()` if glue v1.3.0 or later is installed and `glue::collapse()` otherwise. Eliminates a deprecation warning emanating from glue. (#222 @jimhester)

# googledrive 0.1.1

* initial CRAN release
