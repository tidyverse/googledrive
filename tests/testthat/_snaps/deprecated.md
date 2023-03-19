# drive_auth_config() is deprecated

    Code
      drive_auth_config()
    Condition
      Error:
      ! `drive_auth_config()` was deprecated in googledrive 1.0.0 and is now defunct.
      i Use `drive_auth_configure()` to configure your own OAuth client or API key.
      i Use `drive_deauth()` to go into a de-authorized state.
      i Use `drive_oauth_client()` to retrieve a user-configured client, if it exists.
      i Use `drive_api_key()` to retrieve a user-configured API key, if it exists.

# drive_oauth_app() is deprecated

    Code
      absorb <- drive_oauth_app()
    Condition
      Warning:
      `drive_oauth_app()` was deprecated in googledrive 2.1.0.
      i Please use `drive_oauth_client()` instead.

# drive_auth_configure(app =) is deprecated in favor of client

    Code
      drive_auth_configure(app = client)
    Condition
      Warning:
      The `app` argument of `drive_auth_configure()` is deprecated as of googledrive 2.1.0.
      i Please use the `client` argument instead.

