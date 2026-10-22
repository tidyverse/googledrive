# drive_share() errors for invalid `role` or `type`

    Code
      drive_share(dribble(), role = "chef")
    Condition
      Error in `drive_share()`:
      ! `role` must be one of "reader", "commenter", "writer", "fileOrganizer", "owner", or "organizer", not "chef".

---

    Code
      drive_share(dribble(), type = "pet")
    Condition
      Error in `drive_share()`:
      ! `type` must be one of "user", "group", "domain", or "anyone", not "pet".

