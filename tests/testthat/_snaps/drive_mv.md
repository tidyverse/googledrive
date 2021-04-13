# drive_mv() can rename file

    Code
      out <- drive_mv(renamee, name = me_("DESC-renamed"))
    Message <simpleMessage>
      File renamed:
        * DESC-TEST-drive-mv-jenny -> DESC-renamed-TEST-drive-mv-jenny

# drive_mv() can move a file into a folder given as path

    Code
      out <- drive_mv(movee, paste0(nm_("move-files-into-me"), "/"))
    Message <simpleMessage>
      File moved:
        * DESC-TEST-drive-mv-jenny -> move-files-into-me-TEST-drive-mv/DESC-TEST-drive-mv-jenny

# drive_mv() can move a file into a folder given as dribble

    Code
      out <- drive_mv(movee, destination)
    Message <simpleMessage>
      File moved:
        * DESC-TEST-drive-mv-jenny -> move-files-into-me-TEST-drive-mv/DESC-TEST-drive-mv-jenny

# drive_mv() can rename and move, using `path` and `name`

    Code
      out <- drive_mv(movee, nm_("move-files-into-me"), me_("DESC-renamed"))
    Message <simpleMessage>
      File renamed and moved:
        * DESC-TEST-drive-mv-jenny -> move-files-into-me-TEST-drive-mv/DESC-renamed-TEST-drive-mv-jenny

# drive_mv() can rename and move, using `path` only

    Code
      out <- drive_mv(movee, file.path(nm_("move-files-into-me"), me_("DESC-renamed")))
    Message <simpleMessage>
      File renamed and moved:
        * DESC-TEST-drive-mv-jenny -> move-files-into-me-TEST-drive-mv/DESC-renamed-TEST-drive-mv-jenny

