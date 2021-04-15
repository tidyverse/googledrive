# drive_cp() can copy file in place

    Code
      writeLines(drive_cp_message)
    Output
      File copied:
        * i-am-a-file-TEST-drive-cp -> {cp_name}

# drive_cp() can copy a file into a different folder

    Code
      writeLines(drive_cp_message)
    Output
      File copied:
        * i-am-a-file-TEST-drive-cp -> i-am-a-folder-TEST-drive-cp/{cp_name}

# drive_cp() takes name, assumes path is folder if both are specified

    Code
      writeLines(drive_cp_message)
    Output
      File copied:
        * i-am-a-file-TEST-drive-cp -> i-am-a-folder-TEST-drive-cp/{cp_name}

