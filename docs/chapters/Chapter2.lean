/-!
# Dependent Type Theory

Lean is based on a version of dependent type theory known as the Calculus of Constructions, with a countable hierarchy of non-cumulative universes and inductive types.

Prefixing a command with a hash (`#`) turns it into an auxilliary command, allowing you to query the system.

The `#eval` command asks Lean to evaluate an expression.

Use unicode for an arrow `→` (`\r`) instead of the ASCII ->

Use the unicode for product `×` (`\x`) instead of the ASCII x

Use the unicode for alpha `α` (`\a`), beta β (`\b`), and gamma γ (`\g`)
-/

#check Nat × Nat → Nat
#check (Nat → Nat) → Nat -- a "functional"

/-!
TODO: What is a functional?

Whitespace is function application.

Arrows are right-associative.
-/


def α : Type := Nat
def β : Type := Bool
def F : Type → Type := List
def G : Type → Type → Type := Prod

#check α        -- Type
#check F α      -- Type
#check F Nat    -- Type
#check G α      -- Type → Type
#check G α β    -- Type
#check G α Nat  -- Type


-- Prod is a type constructor -- the infix version is ×


#check Prod -- Type → Type → Type
#check Prod α β       -- Type
#check α × β          -- Type

#check Prod Nat Nat   -- Type
#check Nat × Nat      -- Type

/-!
Lean has a universe of types indexed by the natural numbers. `Type` is an abbreviation for `Type 0`.

Do we not run into any issues as a result of indxing by the natral numbers?
-/