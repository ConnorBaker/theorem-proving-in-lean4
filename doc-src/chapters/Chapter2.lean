/-! # Dependent Type Theory

Lean is based on a version of dependent type theory known as the Calculus of 
Constructions, with a countable hierarchy of non-cumulative universes and 
inductive types.

Prefixing a command with a hash (`#`) turns it into an auxiliary command,
allowing you to query the system.

The `#eval` command asks Lean to evaluate an expression.

Use Unicode for an arrow `→` (`\r`) instead of the ASCII `->`

Use the Unicode for product `×` (`\x`) instead of the ASCII `x`

Use the Unicode for alpha `α` (`\a`), beta β (`\b`), and gamma γ (`\g`)
-/
#check Nat × Nat → Nat
#check (Nat → Nat) → Nat -- a "functional"

/-! [Functionals](https://en.wikipedia.org/wiki/Functional_(mathematics)).

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

/-! ## Function Abstraction and Evaluation

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

## Variables and Sections

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

/-! Lean has a `section` command which provides a scoping mechanism. When we 
close a section, the variables defined within are out of scope. You do not need 
to name a section, or indent its contents.
-/
section useful
  variable (α β γ : Type)
  variable (g : β → γ) (f : α → β) (h : α → α)
  variable (x : α)

  def compose := g (f x)
  def doTwice := h (h x)
  def doThrice := h (h (h x))
end useful

/-! ## Namespaces

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

-- #check a  -- error
-- #check f  -- error
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

Types can depend on parameters! For example, the type `Vector α n` is the type of vectors with elements `α : Type` and length `n : Nat`.

If you were to write a function `cons` which prepends an element to a list, the 
function would need to be polymorphic over the type of the list. One could 
imagine that `cons α` would be the function which prepends an element to a 
`List α`. So `cons α` would have type `α → List α → List α`. But what about 
`cons`? It cannot have the type of `Type → α → List α → List α` because `α` is 
unrelated to `Type`. We need to make the type of the elements of the list 
*depend* on `α`: `cons : (α : Type) → α → List α → List α`.
-/
def cons (α : Type) (a : α) (as : List α) : List α :=
  List.cons a as

#check cons Nat        -- Nat → List Nat → List Nat
#check cons Bool       -- Bool → List Bool → List Bool
#check cons            -- (α : Type) → α → List α → List α

/-! This is an instance of the dependent arrow type.

Given `α : Type` and `β : α → Type`, we can think of `β` as a family of types 
indexed by `α`. That is, for each `a : α`, we have a type `β a`. Then
`(a : α) → β a` is the type of functions `f` with the property that `f a` is 
an element of the type `β a` and the type of the value returned by `f` depends 
on its input.

Note: When the value of `β` depends on `a`, `(a : α) → β` is called a dependent 
function type. When `β` doesn't depend on `a`, `(a : α) → β` is equivalent to 
`α → β`. In dependent type theory, `α → β` is the notation used when `β` does 
not depend on `a`.

We can use the `#check` command to inspect the type of the following functions 
from `List`.
-/
#check @List.cons    -- {α : Type u_1} → α → List α → List α
#check @List.nil     -- {α : Type u_1} → List α
#check @List.length  -- {α : Type u_1} → List α → Nat
#check @List.append  -- {α : Type u_1} → List α → List α → List α

/-! In the same way that the dependent arrow type generalizes the function type 
`α → β` by allowing `β` to depend on `α`, the dependent Cartesian product type 
`(a : α) × β a` generalizes the cartesian product `α × β`. Dependent products 
are also called *sigma* types and are written as `Σ a : α, β a`. You can use 
`⟨a, b⟩` (those are angle brackets, which you can insert with `\langle` (or 
`\lan`) and `\rangle` (or `\ran`)), or `Sigma.mk a b` to construct a dependent 
pair.

**TO-DO:** Is there another name for dependent function types if dependent 
Cartesian products are called sigma types? How do dependent pairs relate to 
dependent Cartesian products?
-/
universe u v

def f (α : Type u) (β : α → Type v) (a : α) (b : β a) : (a : α) × β a :=
  ⟨a, b⟩

def g (α : Type u) (β : α → Type v) (a : α) (b : β a) : Σ a : α, β a :=
  Sigma.mk a b

def h1 (x : Nat) : Nat :=
  (f Type (fun α => α) Nat x).2

#eval h1 5 -- 5

def h2 (x : Nat) : Nat :=
  (g Type (fun α => α) Nat x).2

#eval h2 5 -- 5

/-! The functions `f` and `g` above are the same function.

## Implicit Arguments

Omitted. See the original [here](https://leanprover.github.io/theorem_proving_in_lean4/dependent_type_theory.html#implicit-arguments).
-/
