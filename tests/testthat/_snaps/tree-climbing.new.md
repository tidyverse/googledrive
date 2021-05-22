# pth() errors for cycle

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
<<<<<<< HEAD:tests/testthat/_snaps/tree-climbing.md
    Error <rlang_error>
      This id has itself as parent, possibly indirect:
      * a
      x Cycles are not allowed.
=======
    Error <simpleError>
      could not find function "pth"
>>>>>>> master:tests/testthat/_snaps/tree-climbing.new.md

---

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
<<<<<<< HEAD:tests/testthat/_snaps/tree-climbing.md
    Error <rlang_error>
      This id has itself as parent, possibly indirect:
      * a
      x Cycles are not allowed.
=======
    Error <simpleError>
      could not find function "pth"
>>>>>>> master:tests/testthat/_snaps/tree-climbing.new.md

# pth() errors for duplicated kid

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
<<<<<<< HEAD:tests/testthat/_snaps/tree-climbing.md
    Error <rlang_error>
      This id appears more than once in the role of kid:
      * a
=======
    Error <simpleError>
      could not find function "pth"
>>>>>>> master:tests/testthat/_snaps/tree-climbing.new.md

---

    Code
      pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT")
<<<<<<< HEAD:tests/testthat/_snaps/tree-climbing.md
    Error <rlang_error>
      This id has itself as parent, possibly indirect:
      * a
      x Cycles are not allowed.
=======
    Error <simpleError>
      could not find function "pth"
>>>>>>> master:tests/testthat/_snaps/tree-climbing.new.md

