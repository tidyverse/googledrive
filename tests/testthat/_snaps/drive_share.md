# drive_share() errors for invalid `role` or `type`

    Code
      drive_share(dribble(), role = "chef")
    Error <simpleError>
      'arg' should be one of "reader", "commenter", "writer", "fileOrganizer", "owner", "organizer"

---

    Code
      drive_share(dribble(), type = "pet")
    Error <simpleError>
      'arg' should be one of "user", "group", "domain", "anyone"

