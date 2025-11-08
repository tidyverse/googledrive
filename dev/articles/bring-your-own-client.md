# Bring your own OAuth client or API key

## Role of the OAuth client and API key

googledrive helps you obtain a token to work with the Google Drive API
from R primarily through the
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md)
function. Under the hood, that process relies on an OAuth client and
secret, a.k.a. an “OAuth client”.

googledrive can also make unauthorized calls to the Google Drive API,
for example accessing a file available to “Anyone with a link”, by
sending an API key, instead of a user token.

If there is a problem with googledrive’s internal OAuth client or API
key or if you would prefer to use your own, you can configure this.
Below we describe how.

## Get an OAuth client and tell googledrive about it

Follow the instructions in the gargle article [How to get your own API
credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
to get an OAuth client ID and secret. Now register it with googledrive.

Preferred method: Provide the path to the JSON file downloaded from the
[Google Cloud Platform Console](https://console.cloud.google.com).

``` r
drive_auth_configure(
  path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
)
```

It is also possible, though discouraged, to directly use the constructor
[`gargle::gargle_oauth_client()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.html).

Confirm success and carry on! You can see the currently configured OAuth
client like so:

``` r
drive_oauth_client()
```

You should see your own client there now.

For the rest of this R session, when you get a new token with
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md),
your OAuth client is used.

## Get an API key and tell googledrive about it

Follow the instructions in the gargle article [How to get your own API
credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
to get an API key. You probably want to use the same GCP project to
create both your OAuth client (above) and your API key. Now register it
with googledrive.

``` r
drive_auth_configure(api_key = "YOUR_API_KEY_GOES_HERE")
```

Confirm success and carry on! You can see the currently configured API
key like so:

``` r
drive_api_key()
```

You should see your own API key now.

For the rest of this R session, if you go into a de-authorized state via
[`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md),
your API key will be sent with the request.
