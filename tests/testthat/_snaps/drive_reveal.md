# drive_reveal() works

    Code
      print(out <- drive_reveal(dat, "starred")[c("name", "starred")])
    Output
      # A tibble: 3 x 2
        name                                   starred
        <chr>                                  <lgl>  
      1 i-am-a-google-doc-TEST-drive-reveal    FALSE  
      2 i-have-a-description-TEST-drive-reveal FALSE  
      3 i-am-starred-TEST-drive-reveal         TRUE   

---

    Code
      print(out <- drive_reveal(dat, "description")[c("name", "description")])
    Output
      # A tibble: 3 x 2
        name                                   description 
        <chr>                                  <chr>       
      1 i-am-a-google-doc-TEST-drive-reveal    <NA>        
      2 i-have-a-description-TEST-drive-reveal description!
      3 i-am-starred-TEST-drive-reveal         <NA>        

---

    Code
      print(out <- drive_reveal(dat, "mimeType")[c("name", "mime_type")])
    Output
      # A tibble: 3 x 2
        name                                   mime_type                           
        <chr>                                  <chr>                               
      1 i-am-a-google-doc-TEST-drive-reveal    application/vnd.google-apps.document
      2 i-have-a-description-TEST-drive-reveal text/plain                          
      3 i-am-starred-TEST-drive-reveal         text/plain                          

