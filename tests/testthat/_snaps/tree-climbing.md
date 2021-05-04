# pth() errors for cycle

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <rlang_error>
      This id has itself as parent, possibly indirect:
      * a
      x Cycles are not allowed.

---

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <rlang_error>
      This id has itself as parent, possibly indirect:
      * a
      x Cycles are not allowed.

# pth() errors for duplicated kid

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <rlang_error>
      This id appears more than once in the role of kid:
      * a

---

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
    Error <rlang_error>
      This id has itself as parent, possibly indirect:
      * a
      x Cycles are not allowed.

