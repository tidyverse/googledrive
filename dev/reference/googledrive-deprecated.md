# Deprecated googledrive functions

**\[deprecated\]**

## Usage

``` r
drive_auth_config(active, app, path, api_key)

drive_oauth_app()

drive_example(path = NULL)
```

## Arguments

- app:

  **\[deprecated\]** Replaced by the `client` argument.

- path:

  JSON downloaded from [Google Cloud
  Console](https://console.cloud.google.com), containing a client id and
  secret, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://rdrr.io/pkg/jsonlite/man/fromJSON.html)
  (typically, a file path or JSON string).

- api_key:

  API key.

## `drive_auth_config()`

This function is defunct.

- Use
  [`drive_auth_configure()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md)
  to configure your own OAuth client or API key.

- Use
  [`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md)
  to go into a de-authorized state.

- Use
  [`drive_oauth_client()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md)
  to retrieve a user-configured client, if it exists.

- Use
  [`drive_api_key()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md)
  to retrieve a user-configured API key, if it exists.

## `drive_oauth_app()`

In light of the new
[`gargle::gargle_oauth_client()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.html)
constructor and class of the same name, `drive_oauth_app()` is being
replaced by
[`drive_oauth_client()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md).

## `drive_example()`

This function is defunct. Access example files with
[`drive_examples_local()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md),
[`drive_example_local()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md),
[`drive_examples_remote()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md),
and
[`drive_example_remote()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md).
