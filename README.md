# lean-gccjit
libgccjit bindings for Lean4.

## Documentaion

- [Lean bindings](https://www.cs.rochester.edu/~yzhu104/lean-gccjit/)
- [GCCJIT C API](https://gcc.gnu.org/onlinedocs/jit/)

## How to use

- Install [`libgccjit`]:
  ```bash
  sudo pacman -S libgccjit # Arch Linux
  sudo apt install libgccjit-12-dev # Debian (bookworm)
  ```

- Add this package to `lakefile.lean`:
  ```lean
  require «doc-gen4» from git "https://github.com/schrodingerzhu/lean-gccjit" @ "0.1.0"
  ```

- Add `libgccjit` to binary dependency (this is required because `extern_lib` does not handle shared libraries yet):
  ```lean
  lean_exe «lmy-exe» {
    root := `Main
    moreLinkArgs := #["-lgccjit"] -- add this line
  }
  ```