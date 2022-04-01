# drive_share() errors for invalid `role` or `type`

    Code
      drive_share(dribble(), role = "chef")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "reader", "commenter", "writer", "fileOrganizer", "owner", "organizer"

---

    Code
      drive_share(dribble(), type = "pet")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "user", "group", "domain", "anyone"

