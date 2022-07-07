# Chapter 3: Notes

## Propositions as Types

How is it we can say that

> In other words, whenever we have `p : Prop`, we can interpret `p` as a type,
> namely, the type of its proofs. We can then read `t : p` as the assertion that
> `t` is a proof of `p`.

I interpret `p : Prop` ("`p` has type `Prop`") as `p` being an element of the
set of propositions. (Although, the text refers to `p` as being an "assertion".)

1. When talking about type theory, does it make sense to talk about `Prop` as a
   set, where being a member of the set means being a proposition?
2. Are types taken as axiomatic structures?
3. Does talking about membership make sense with respect to types? Or do we
   prefer the term "inhabits"?
4. If `p` is a type (presumably `Type 0`?), `p` is an inhabitant of `Prop`,
   `Prop = Sort 0`, and `Type u = Sort (u+1)`, then wouldn't it mean that `p`
   is an inhabitant of `Sort 1`? If that is the case, does that mean that the
   type of `p` is higher in the type hierarchy than `Prop`? What does this
   hierarchy look like, graphically?

> _Definition:_ Proof Irrelevance
>
> Given a proposition `p : Prop` any two elements of `p` are treated as
> definitionally equal since they carry no information beyond the fact that `p`
> is true.

1. Is it misleading to say "elements" when referring to types? In the language
   of type theory, would we normally call them "terms"?

## Working with Propositions as Types

The `theorem` command is really just the `def` command, with a few differences:

> There are a few pragmatic differences between definitions and
> theorems, however. In normal circumstances, it is never necessary to
> unfold the "definition" of a theorem; by proof irrelevance, any two
> proofs of that theorem are definitionally equal. Once the proof of a
> theorem is complete, typically we only need to know that the proof
> exists; it doesn't matter what the proof is. In light of that fact,
> Lean tags proofs as _irreducible_, which serves as a hint to the
> parser (more precisely, the _elaborator_) that there is generally no
> need to unfold it when processing a file. In fact, Lean is generally
> able to process and check proofs in parallel, since assessing the
> correctness of one proof does not require knowing the details of
> another.
