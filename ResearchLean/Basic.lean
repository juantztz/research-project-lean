/-
  First proofs that use Mathlib. Use this file as a template for new modules:
  one topic per file, everything inside the `ResearchLean` namespace.
-/
import Mathlib

namespace ResearchLean

open Finset

/-- The sum of the first `n` odd numbers is `n²`. -/
theorem sum_range_odd (n : ℕ) : ∑ i ∈ range n, (2 * i + 1) = n ^ 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [sum_range_succ, ih]
    ring

/-- Gauss: `2 · (0 + 1 + ⋯ + (n - 1)) = n (n - 1)`. -/
theorem two_mul_sum_range_id (n : ℕ) : 2 * ∑ i ∈ range n, i = n * (n - 1) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [sum_range_succ, mul_add, ih]
    cases n with
    | zero => simp
    | succ m => simp only [Nat.add_sub_cancel]; ring

/-- AM–GM for two real numbers. -/
theorem two_mul_le_sq_add_sq (a b : ℝ) : 2 * a * b ≤ a ^ 2 + b ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- There are infinitely many primes: for every `n` there is a prime `p ≥ n`. -/
theorem exists_prime_ge (n : ℕ) : ∃ p, n ≤ p ∧ p.Prime :=
  Nat.exists_infinite_primes n

end ResearchLean
