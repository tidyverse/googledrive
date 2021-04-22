# drive_mv() can rename file

    Code
      writeLines(drive_mv_message)
    Output
      Original file:
      * {name_1} <id: {RANDOM}>
      Has been renamed:
      * {name_2} <id: {RANDOM}>

# drive_mv() can move a file into a folder given as path

    Code
      writeLines(drive_mv_message)
    Output
      Original file:
      * {mv_name} <id: {RANDOM}>
      Has been moved:
      * move-files-into-me-TEST-drive-mv/{mv_name} <id: {RANDOM}>

# drive_mv() can move a file into a folder given as dribble

    Code
      writeLines(drive_mv_message)
    Output
      Original file:
      * {mv_name} <id: {RANDOM}>
      Has been moved:
      * move-files-into-me-TEST-drive-mv/{mv_name} <id: {RANDOM}>

# drive_mv() can rename and move, using `path` and `name`

    Code
      writeLines(drive_mv_message)
    Output
      Original file:
      * {name_1} <id: {RANDOM}>
      Has been renamed and moved:
      * move-files-into-me-TEST-drive-mv/{name_2} <id: {RANDOM}>

# drive_mv() can rename and move, using `path` only

    Code
      writeLines(drive_mv_message)
    Output
      Original file:
      * {name_1} <id: {RANDOM}>
      Has been renamed and moved:
      * move-files-into-me-TEST-drive-mv/{name_2} <id: {RANDOM}>

