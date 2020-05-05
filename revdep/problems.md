# reproducible

<details>

* Version: 1.0.0
* Source code: https://github.com/cran/reproducible
* URL: https://reproducible.predictiveecology.org, https://github.com/PredictiveEcology/reproducible
* BugReports: https://github.com/PredictiveEcology/reproducible/issues
* Date/Publication: 2020-02-20 17:30:02 UTC
* Number of recursive dependencies: 122

Run `revdep_details(,"reproducible")` for more info

</details>

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/test-all.R’ failed.
    Last 13 lines of output:
      3      readRDS   Saving to repo 0.0349459648  secs
      4      readRDS Whole Cache call 0.0486907959  secs
        objectNames hashElements             hash objSize
      1        file         file aef056635a52922b   24139
      2        .FUN         .FUN 7a8f2865ef4bc06d    1256
        functionName         component  elapsedTime units
      1      readRDS           Hashing 0.0008139610  secs
      2      readRDS Loading from repo 0.0008709431  secs
      3      readRDS  Whole Cache call 0.0174100399  secs
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 313 | SKIPPED: 68 | WARNINGS: 30 | FAILED: 1 ]
      1. Error: prepInputs doesn't work (part 3) (@test-postProcess.R#40) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

