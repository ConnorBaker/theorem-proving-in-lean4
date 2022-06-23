/-! # Dependent Type Theory

Lean is based on a version of dependent type theory known as the Calculus of 
Constructions, with a countable hierarchy of non-cumulative universes and 
inductive types.

Prefixing a command with a hash (`#`) turns it into an auxiliary command,
allowing you to query the system.

The `#eval` command asks Lean to evaluate an expression.

Use unicode for an arrow `→` (`\r`) instead of the ASCII `->`

Use the unicode for product `×` (`\x`) instead of the ASCII `x`

Use the unicode for alpha `α` (`\a`), beta β (`\b`), and gamma γ (`\g`)
-/

#check Nat × Nat → Nat
#check (Nat → Nat) → Nat -- a "functional"

/-! TODO: What is a functional?

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

/-! Lean has a universe of types indexed by the natural numbers. `Type` is
an abbreviation for `Type 0`.

We can think of `Type 0` as a universe of "small" types. `Type 1` is a universe 
of larger types, which contains `Type 0`. Likewise, `Type 2` is a larger-still 
universe of types, containing `Type 1` as an element.

Some functions, like `List` and `Prod`, are polymorphic over the universe of 
types.
-/

#check List
#check Prod

/-! We can define polymorphic constants using the `universe` command. -/
universe u₁

def F₁ (α : Type u₁) : Type u₁ := Prod α α

#check F₁    -- Type u → Type u

/-! We can avoid `universe` by providing the universe parameters when defining 
the function.
-/

def F₂.{u₂} (α : Type u₂) : Type u₂ := Prod α α

#check F₂    -- Type u → Type u

/-! # Function Abstraction and Evaluation

In Lean, `fun` and `λ` are the same.

> *Definition:* Alpha Equivalence
>
> Expressions which are the same up to renaming of bound variables are alpha 
> equivalent.

> *Definition:* Definitional Equivalence
>
> Two terms which reduce to the same value are definitionally equivalent.

The command `#eval` executes expressions and is the preferred way of testing 
your functions.

# Variables and Sections

Lean has a `variable` command which declares variables of any type. For example,
-/

def compose₁ (α β γ : Type) (g : β → γ) (f : α → β) (x : α) : γ :=
  g (f x)

def doTwice₁ (α : Type) (h : α → α) (x : α) : α :=
  h (h x)

def doThrice₁ (α : Type) (h : α → α) (x : α) : α :=
  h (h (h x))

/-! becomes -/

variable (α β γ : Type)

def compose₂ (g : β → γ) (f : α → β) (x : α) : γ :=
  g (f x)

def doTwice₂ (h : α → α) (x : α) : α :=
  h (h x)

def doThrice₂ (h : α → α) (x : α) : α :=
  h (h (h x))

/-! Lean has a `section` command which provides a scoping mechanism. When a 
section is closed, the variables defined within are out of scope. You do not 
need to name a section, or indent its  contents.
-/

section useful
  variable (α β γ : Type)
  variable (g : β → γ) (f : α → β) (h : α → α)
  variable (x : α)

  def compose := g (f x)
  def doTwice := h (h x)
  def doThrice := h (h (h x))
end useful

/-! # Namespaces

Namespaces let you group related definitions. Like sections, they can be 
nested. However, unlike sections, they require a name, and can be reopened 
later!

The intended usage is this: namespaces organize data and sections declare 
variables for use in definitions or delimit the scope of commands like 
`set_option` and `open`.
-/

namespace Foo
  def a : Nat := 5
  def f (x : Nat) : Nat := x + 7

  def fa : Nat := f a
  def ffa : Nat := f (f a)

  #check a
  #check f
  #check fa
  #check ffa
  #check Foo.fa
end Foo

#check a  -- error
#check f  -- error
#check Foo.a
#check Foo.f
#check Foo.fa
#check Foo.ffa

/-! The `open` command brings the contents of the namespace into scope. -/

open Foo

#check a
#check f
#check fa
#check Foo.fa

/-! ## What makes dependent type theory dependent?

**TODO**

## Implicit Arguments

**TODO**
-/