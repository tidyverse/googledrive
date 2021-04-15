# pth() errors for cycle

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <simpleError>
      This id has itself as parent, possibly indirect:
      'a'
      Cycles are not allowed.

---

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <simpleError>
      This id has itself as parent, possibly indirect:
      'a'
      Cycles are not allowed.

# pth() errors for duplicated kid

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <simpleError>
      This id appears more than once in the role of 'kid':
        * 'a'

---

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <simpleError>
      This id has itself as parent, possibly indirect:
      'a'
      Cycles are not allowed.

