# request_generate() errors for unrecognized parameters

    Code
      (expect_error(request_generate(endpoint = "drive.files.list", params = params,
        token = NULL), class = "gargle_error_bad_params"))
    Output
      <error/gargle_error_bad_params>
      Error in `gargle::request_develop()`:
      ! These parameters are unknown:
      x 'chicken'
      x 'bunny'
      i API endpoint: 'drive.files.list'

