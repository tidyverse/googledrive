# Edit and view auth configuration

These functions give more control over and visibility into the auth
configuration than
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md)
does. `drive_auth_configure()` lets the user specify their own:

- OAuth client, which is used when obtaining a user token.

- API key. If googledrive is de-authorized via
  [`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md),
  all requests are sent with an API key in lieu of a token.

See the
[`vignette("get-api-credentials", package = "gargle")`](https://gargle.r-lib.org/articles/get-api-credentials.html)
for more. If the user does not configure these settings, internal
defaults are used.

`drive_oauth_client()` and `drive_api_key()` retrieve the currently
configured OAuth client and API key, respectively.

## Usage

``` r
drive_auth_configure(client, path, api_key, app = deprecated())

drive_api_key()

drive_oauth_client()
```

## Arguments

- client:

  A Google OAuth client, presumably constructed via
  [`gargle::gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.html).
  Note, however, that it is preferred to specify the client with JSON,
  using the `path` argument.

- path:

  JSON downloaded from [Google Cloud
  Console](https://console.cloud.google.com), containing a client id and
  secret, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://rdrr.io/pkg/jsonlite/man/fromJSON.html)
  (typically, a file path or JSON string).

- api_key:

  API key.

- app:

  **\[deprecated\]** Replaced by the `client` argument.

## Value

- `drive_auth_configure()`: An object of R6 class
  [gargle::AuthState](https://gargle.r-lib.org/reference/AuthState-class.html),
  invisibly.

- `drive_oauth_client()`: the current user-configured OAuth client.

- `drive_api_key()`: the current user-configured API key.

## See also

Other auth functions:
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md),
[`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md),
[`drive_scopes()`](https://googledrive.tidyverse.org/dev/reference/drive_scopes.md)

## Examples

``` r
# see and store the current user-configured OAuth client (probaby `NULL`)
(original_client <- drive_oauth_client())
#> NULL

# see and store the current user-configured API key (probaby `NULL`)
(original_api_key <- drive_api_key())
#> NULL

# the preferred way to configure your own client is via a JSON file
# downloaded from Google Developers Console
# this example JSON is indicative, but fake
path_to_json <- system.file(
  "extdata", "client_secret_installed.googleusercontent.com.json",
  package = "gargle"
)
drive_auth_configure(path = path_to_json)

# this is also obviously a fake API key
drive_auth_configure(api_key = "the_key_I_got_for_a_google_API")

# confirm the changes
drive_oauth_client()
#> <gargle_oauth_client>
#> name: a_project_d1c5a8066d2cbe48e8d94514dd286163
#> id: abc.apps.googleusercontent.com
#> secret: <REDACTED>
#> type: installed
#> redirect_uris: http://localhost
drive_api_key()
#> [1] "the_key_I_got_for_a_google_API"

# restore original auth config
drive_auth_configure(client = original_client, api_key = original_api_key)
```
