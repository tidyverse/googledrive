# as_id() errors for unanticipated input

    Code
      as_id(mean)
    Error <rlang_error>
      Don't know how to coerce an object of class <function> into a
      <drive_id>.

---

    Code
      as_id(1.2)
    Error <rlang_error>
      Don't know how to coerce an object of class <numeric> into a <drive_id>.

---

    Code
      as_id(1L)
    Error <rlang_error>
      Don't know how to coerce an object of class <integer> into a <drive_id>.

# drive_id's are formatted OK

    Code
      print(x$id)
    Output
      <drive_id[10]>
       [1] 1CEefQCUc5T7B4yrawnNfqwdWEbiDyDs9E5OB9p6AXQ8
       [2] 1oUrQNg-2lcAieZyCqoQ_vDwYLMVzhN4-oOSTt2L3Glw
       [3] 1V6qQhCVkgVRLUL24_lExApTklRsrDLv3           
       [4] 1uBR1UMWUXQ02OS9B6sQ3-98Z7QFUGUwn           
       [5] 1U_5_O1-Od_q30wQVhGgZlMevFkcxHr7V           
       [6] 1Y2O_otAmg7BN0Bk_5d-i9ZlGcflmw_uo           
       [7] 1o_UmldMPpRfr4JlVyZKu1ZR2vN_m-uhs           
       [8] 1oa-yeDNPd8x7sddbwHEWjGadY7HkGvMv           
       [9] 1yeH1TqZczcPvhZoJvSOnG2_rfFCycyix           
      [10] 1qSmvJtYUf6w1UtnA4XWUmG_qrVjjTnCN           

# drive_ids look OK in a dribble and truncate gracefully

    Code
      print(x)
    Output
      # A dribble: 10 x 3
         name                        id                               drive_resource  
         <chr>                       <drv_id>                         <list>          
       1 foo_sheet-TEST-drive_publi~ 1CEefQCUc5T7B4yrawnNfqwdWEbiDyD~ <named list [36~
       2 foo_doc-TEST-drive_publish  1oUrQNg-2lcAieZyCqoQ_vDwYLMVzhN~ <named list [36~
       3 DESC-TEST-drive_mv-jenny-7~ 1V6qQhCVkgVRLUL24_lExApTklRsrDL~ <named list [40~
       4 DESC-TEST-drive_mv-jenny-7~ 1uBR1UMWUXQ02OS9B6sQ3-98Z7QFUGU~ <named list [40~
       5 name-collision-TEST-path-u~ 1U_5_O1-Od_q30wQVhGgZlMevFkcxHr~ <named list [39~
       6 DESCRIPTION-TEST-drive-upd~ 1Y2O_otAmg7BN0Bk_5d-i9ZlGcflmw_~ <named list [40~
       7 name-collision-TEST-path-u~ 1o_UmldMPpRfr4JlVyZKu1ZR2vN_m-u~ <named list [39~
       8 DESC-TEST-drive-mv-jenny    1oa-yeDNPd8x7sddbwHEWjGadY7HkGv~ <named list [40~
       9 DESC-TEST-drive-mv-jenny    1yeH1TqZczcPvhZoJvSOnG2_rfFCycy~ <named list [40~
      10 DESC-TEST-drive-mv-jenny    1qSmvJtYUf6w1UtnA4XWUmG_qrVjjTn~ <named list [40~

---

    Code
      print(drive_reveal(x, "mime_type"))
    Output
      # A dribble: 10 x 4
         name               mime_type             id                   drive_resource 
         <chr>              <chr>                 <drv_id>             <list>         
       1 foo_sheet-TEST-dr~ application/vnd.goog~ 1CEefQCUc5T7B4yrawn~ <named list [3~
       2 foo_doc-TEST-driv~ application/vnd.goog~ 1oUrQNg-2lcAieZyCqo~ <named list [3~
       3 DESC-TEST-drive_m~ text/plain            1V6qQhCVkgVRLUL24_l~ <named list [4~
       4 DESC-TEST-drive_m~ text/plain            1uBR1UMWUXQ02OS9B6s~ <named list [4~
       5 name-collision-TE~ application/octet-st~ 1U_5_O1-Od_q30wQVhG~ <named list [3~
       6 DESCRIPTION-TEST-~ text/plain            1Y2O_otAmg7BN0Bk_5d~ <named list [4~
       7 name-collision-TE~ application/octet-st~ 1o_UmldMPpRfr4JlVyZ~ <named list [3~
       8 DESC-TEST-drive-m~ text/plain            1oa-yeDNPd8x7sddbwH~ <named list [4~
       9 DESC-TEST-drive-m~ text/plain            1yeH1TqZczcPvhZoJvS~ <named list [4~
      10 DESC-TEST-drive-m~ text/plain            1qSmvJtYUf6w1UtnA4X~ <named list [4~

---

    Code
      print(x)
    Output
      # A dribble: 10 x 3
         name                        id                               drive_resource  
         <chr>                       <drv_id>                         <list>          
       1 foo_sheet-TEST-drive_publi~ <NA>                             <named list [36~
       2 foo_doc-TEST-drive_publish  1oUrQNg-2lcAieZyCqoQ_vDwYLMVzhN~ <named list [36~
       3 DESC-TEST-drive_mv-jenny-7~ 1V6qQhCVkgVRLUL24_lExApTklRsrDL~ <named list [40~
       4 DESC-TEST-drive_mv-jenny-7~ 1uBR1UMWUXQ02OS9B6sQ3-98Z7QFUGU~ <named list [40~
       5 name-collision-TEST-path-u~ 1U_5_O1-Od_q30wQVhGgZlMevFkcxHr~ <named list [39~
       6 DESCRIPTION-TEST-drive-upd~ 1Y2O_otAmg7BN0Bk_5d-i9ZlGcflmw_~ <named list [40~
       7 name-collision-TEST-path-u~ 1o_UmldMPpRfr4JlVyZKu1ZR2vN_m-u~ <named list [39~
       8 DESC-TEST-drive-mv-jenny    1oa-yeDNPd8x7sddbwHEWjGadY7HkGv~ <named list [40~
       9 DESC-TEST-drive-mv-jenny    1yeH1TqZczcPvhZoJvSOnG2_rfFCycy~ <named list [40~
      10 DESC-TEST-drive-mv-jenny    1qSmvJtYUf6w1UtnA4XWUmG_qrVjjTn~ <named list [40~

# gargle_map_cli() is implemented for drive_id

    Code
      gargle_map_cli(as_id(month.name[1:3]))
    Output
      [1] "{.field January}"  "{.field February}" "{.field March}"   

# validate_drive_id fails informatively

    Code
      validate_drive_id("")
    Error <rlang_error>
      A <drive_id> must match this regular expression: `^[a-zA-Z0-9_-]+$`
      Invalid input:
      x '""'

---

    Code
      validate_drive_id("a@&")
    Error <rlang_error>
      A <drive_id> must match this regular expression: `^[a-zA-Z0-9_-]+$`
      Invalid input:
      x 'a@&'

# you can't insert invalid strings into a drive_id

    Code
      x[2] <- ""
    Error <rlang_error>
      A <drive_id> must match this regular expression: `^[a-zA-Z0-9_-]+$`
      Invalid input:
      x '""'

