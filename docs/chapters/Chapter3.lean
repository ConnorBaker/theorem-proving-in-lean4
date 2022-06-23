/-! # Propositions and Proofs

## Propositions as Types

Dependent types are expressive enough that we can prove properties of our 
programs within the same language. Here we introduce the type `Prop` to 
represent propositions.
-/

def Implies (p q : Prop) : Prop := p → q
#check And     -- Prop → Prop → Prop
#check Or      -- Prop → Prop → Prop
#check Not     -- Prop → Prop
#check Implies -- Prop → Prop → Prop

variable (p q r : Prop)
#check And p q                      -- Prop
#check Or (And p q) r               -- Prop
#check Implies (And p q) (And q p)  -- Prop
