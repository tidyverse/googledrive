# drive_cp() can copy file in place

    Code
      file_cp <- drive_cp(file, name = me_("i-am-a-file"))
    Message <simpleMessage>
      File copied:
        * i-am-a-file-TEST-drive-cp -> i-am-a-file-TEST-drive-cp-jenny

# drive_cp() can copy a file into a different folder

    Code
      file_cp <- drive_cp(file, path = folder, name = me_("i-am-a-file"))
    Message <simpleMessage>
      File copied:
        * i-am-a-file-TEST-drive-cp -> i-am-a-folder-TEST-drive-cp/i-am-a-file-TEST-drive-cp-jenny

# drive_cp() takes name, assumes path is folder if both are specified

    Code
      file_cp <- drive_cp(nm_("i-am-a-file"), path = nm_("i-am-a-folder"), name = me_(
        "file-name"))
    Message <simpleMessage>
      File copied:
        * i-am-a-file-TEST-drive-cp -> i-am-a-folder-TEST-drive-cp/file-name-TEST-drive-cp-jenny

