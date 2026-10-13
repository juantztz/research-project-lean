# First proofs with Mathlib

Source: `ResearchLean/Basic.lean`.

## Sum of the first odd numbers

```{prf:theorem}
:label: thm-sum-odd
For every $n \in \mathbb{N}$, $\displaystyle\sum_{i=0}^{n-1} (2i + 1) = n^2$.
```

*Proof idea.* Induction on $n$: the case $n = 0$ is an empty sum; in the inductive step, $\sum_{i=0}^{n}(2i+1) = n^2 + 2n + 1 = (n+1)^2$, which `ring` closes after splitting off the last term with `Finset.sum_range_succ`.

## Gauss sum

```{prf:theorem}
:label: thm-gauss
For every $n \in \mathbb{N}$, $\displaystyle 2\sum_{i=0}^{n-1} i = n(n-1)$.
```

The Lean statement keeps natural-number subtraction, so the inductive step distinguishes $n = 0$ from $n = m + 1$ before calling `ring`.

## AM–GM for two reals

```{prf:theorem}
:label: thm-amgm
For all $a, b \in \mathbb{R}$, $2ab \le a^2 + b^2$.
```

`nlinarith` finds the proof from the hint $(a - b)^2 \ge 0$.

## Infinitely many primes

```{prf:theorem}
:label: thm-primes
For every $n \in \mathbb{N}$ there is a prime $p \ge n$.
```

This is Euclid's theorem, already in Mathlib as `Nat.exists_infinite_primes`.

## Source

```{literalinclude} ../../../ResearchLean/Basic.lean
:language: lean
:linenos:
```
