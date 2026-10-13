# Introduction

This book documents a research project whose objective is to **build mathematical proofs with the Lean 4 theorem prover** {cite}`moura2021lean4`. Every theorem presented here is checked by Lean's kernel: the source lives in the `ResearchLean` library of this repository, and `lake build` fails if any proof is wrong. Most proofs rely on Mathlib, the community library of formalized mathematics {cite}`mathlib2020`.

The book is organized as follows:

* **Repository Documentation** explains how to install the tools, synchronize data with Google Drive, write new proofs, and build this book.
* **Proofs** presents the formalized results. Each page explains the mathematics in prose and embeds the Lean source that proves it, so the text and the checked code never drift apart.

## Writing conventions

* Each Lean file in `ResearchLean/` has a page in `docs/docs/proofs/`.
* Lean code is embedded with `{literalinclude}` (never copied by hand), pointing to the file in `ResearchLean/`.
* A theorem is only described as *proved* when `lake build` succeeds and `make -f MAKE check_sorry` reports no `sorry` in it.
