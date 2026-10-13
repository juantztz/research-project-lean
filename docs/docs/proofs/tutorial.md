# A short Lean 4 tutorial

Source: `ResearchLean/Tutorial.lean`. It only uses Lean's core library (no Mathlib), so it is the quickest file to experiment with. Open it in VS Code with the Lean 4 extension and move the cursor through the proofs to see the goals in the *Infoview*.

## Propositions are types, proofs are terms

In Lean a proposition `p : Prop` is a type and a proof of `p` is a term of that type. `theorem two_plus_two : 2 + 2 = 4 := rfl` is proved by computation; `and_swap_term` is proved by an explicit function that takes a proof of $p \land q$ and returns a proof of $q \land p$.

## Tactic mode

After `by`, a proof is built step by step with *tactics* (`intro`, `apply`, `exact`, `cases`, `induction`, `rw`, `simp`, `omega`, ...), each transforming the current goal.

## Source

```{literalinclude} ../../../ResearchLean/Tutorial.lean
:language: lean
:linenos:
```
