/-
  A short Lean 4 tutorial. Open this file in VS Code with the "Lean 4"
  extension and put your cursor on each line to see the Infoview update.
-/

namespace Tutorial

-- 1. Lean as a programming language
def addOne (n : Nat) : Nat := n + 1

#eval addOne 41          -- 42
#check addOne            -- addOne : Nat → Nat

def factorial : Nat → Nat
  | 0     => 1
  | n + 1 => (n + 1) * factorial n

#eval factorial 5        -- 120

-- 2. Propositions are types; proofs are terms
theorem two_plus_two : 2 + 2 = 4 := rfl     -- true by computation

-- A proof written as a plain function (term mode)
theorem and_swap_term (p q : Prop) : p ∧ q → q ∧ p :=
  fun ⟨hp, hq⟩ => ⟨hq, hp⟩

-- 3. Tactic mode: build the proof step by step
theorem and_swap (p q : Prop) (h : p ∧ q) : q ∧ p := by
  obtain ⟨hp, hq⟩ := h    -- split the hypothesis
  exact ⟨hq, hp⟩          -- build the conclusion

theorem imp_trans (p q r : Prop) (hpq : p → q) (hqr : q → r) : p → r := by
  intro hp                -- assume p
  apply hqr               -- goal becomes q
  apply hpq               -- goal becomes p
  exact hp

theorem or_comm' (p q : Prop) : p ∨ q → q ∨ p := by
  intro h
  cases h with
  | inl hp => exact Or.inr hp
  | inr hq => exact Or.inl hq

-- 4. Proof by induction
theorem my_zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero => rfl
  | succ k ih =>
    rw [← Nat.add_assoc, ih]   -- 0 + (k + 1) = (0 + k) + 1 = k + 1

def myLength {α : Type} : List α → Nat
  | []      => 0
  | _ :: xs => 1 + myLength xs

theorem myLength_append {α : Type} (xs ys : List α) :
    myLength (xs ++ ys) = myLength xs + myLength ys := by
  induction xs with
  | nil => simp [myLength]
  | cons x xs ih => simp [myLength, ih, Nat.add_assoc]

-- 5. Automation
example (a b : Nat) (h : a < b) : a + 1 ≤ b := by omega   -- linear arithmetic
example : 10 < 100 := by decide                          -- decidable facts

end Tutorial
