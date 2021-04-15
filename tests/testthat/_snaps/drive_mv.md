# drive_mv() can rename file

    Code
      writeLines(drive_mv_message)
    Output
      File renamed:
        * {name_1} -> {name_2}

# drive_mv() can move a file into a folder given as path

    Code
      writeLines(drive_mv_message)
    Output
      File moved:
        * {mv_name} -> move-files-into-me-TEST-drive-mv/{mv_name}

# drive_mv() can move a file into a folder given as dribble

    Code
      writeLines(drive_mv_message)
    Output
      File moved:
        * {mv_name} -> move-files-into-me-TEST-drive-mv/{mv_name}

# drive_mv() can rename and move, using `path` and `name`

    Code
      writeLines(drive_mv_message)
    Output
      File renamed and moved:
        * {name_1} -> move-files-into-me-TEST-drive-mv/{name_2}

# drive_mv() can rename and move, using `path` only

    Code
      writeLines(drive_mv_message)
    Output
      File renamed and moved:
        * {name_1} -> move-files-into-me-TEST-drive-mv/{name_2}

