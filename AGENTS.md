# AI Context

## Research Goal
Build and document mathematical proofs formalized in the Lean 4 theorem prover with Mathlib.

## Technology
- Lean 4 + Mathlib (managed with elan / Lake; versions pinned in `lean-toolchain` and `lakefile.toml`)
- MyST / Jupyter Book 2 for documentation (`docs/`)
- uv for the Python environment
- rclone + Google Drive for data and assets

## Design Principles
- Every statement in the docs must be backed by a Lean proof that `lake build` accepts
- One topic per file in `ResearchLean/`; everything inside the `ResearchLean` namespace
- Explicit variables (`autoImplicit = false`)
- Prefer Mathlib lemmas over reproving them; name theorems following Mathlib conventions
- Docstrings (`/-- ... -/`) on every theorem and definition
- Readability over cleverness: short tactic proofs, comment non-obvious steps

## Expectations for AI
- Read `docs/docs/README.md` before working.
- Run `lake build` after editing Lean files and report errors faithfully.
- Never leave `sorry` without saying so; check with `make -f MAKE check_sorry`.
- Avoid unnecessary refactoring. Preserve naming.
- Explain assumptions.
