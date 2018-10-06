## Test environments
* local OS X install, R 3.5.1
* ubuntu 14.04 trusty (on travis-ci), R 3.2 - devel
* Windows Server 2012 R2 (on appveyor), R 3.5.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

This is a patch release to address a deprecation warning coming from glue::collapse(), which has been deprecated in favor of glue::glue_collapse().

## Reverse dependencies

There are 2 reverse dependencies: reproducible, SpaDES.core.
I do not get a clean R CMD check for these 2 packages locally, but the problems I see appear to have nothing to do with googledrive.
