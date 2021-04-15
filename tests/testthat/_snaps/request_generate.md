# request_generate() errors for unrecognized parameters

    Code
      (expect_error(request_generate(endpoint = "drive.files.list", params = params,
        token = NULL), class = "gargle_error_bad_params"))
    Output
      <error/gargle_error_bad_params>
      These parameters are unknown:
      * chicken
      * bunny

