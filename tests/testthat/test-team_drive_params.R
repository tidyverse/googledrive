context("Team Drive specification")

test_that("new_corpus() checks type and length, if not-NULL", {
  expect_silent(new_corpus())
  expect_silent(
    new_corpus(teamDriveId = "1", corpora = "b", includeTeamDriveItems = FALSE)
  )
  expect_error(
    new_corpus(teamDriveId = c("1", "2")),
    "length\\(teamDriveId\\) == 1 is not TRUE"
  )
  expect_error(
    new_corpus(corpora = c("a", "b")),
    "is_string\\(corpora\\) is not TRUE"
  )
  expect_error(
    new_corpus(includeTeamDriveItems = c(TRUE, FALSE)),
    "length\\(includeTeamDriveItems\\) == 1 is not TRUE"
  )
})

test_that("`corpora` is checked for validity", {
  expect_silent(team_drive_params(corpora = "user"))
  expect_silent(team_drive_params(corpora = "user,allTeamDrives"))
  expect_silent(team_drive_params(corpora = "domain"))
  expect_error(
    team_drive_params(corpora = "foo"),
    "Invalid value for `corpora`"
  )
})

test_that('`corpora = "teamDrive"` requires team drive specification', {
  expect_error(
    team_drive_params(corpora = "teamDrive"),
    "`team_drive` cannot be NULL"
  )
})

test_that('`corpora != "teamDrive"` rejects team drive specification', {
  expect_error(
    team_drive_params(corpora = "user", teamDriveId = "123"),
    "don't specify a Team Drive"
  )
})

test_that("a team drive can be specified w/ corpora", {
  expect_silent(team_drive_params(corpora = "teamDrive", teamDriveId = "123"))
})

test_that('`corpora = "teamDrive" is inferred from team drive specification', {
  out <- team_drive_params(teamDriveId = "123")
  expect_identical(out$corpora, "teamDrive")
})
