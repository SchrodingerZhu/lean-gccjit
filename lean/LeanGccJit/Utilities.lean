namespace LeanGccJit
namespace Utilities

def HList : List Type → Type
  | [] => Unit
  | [x] => x
  | h::t => Prod h (HList t)

inductive IsOrderedSubset : List α → List α → Prop
  | Empty xs : IsOrderedSubset xs []
  | Head x xs ys : IsOrderedSubset xs ys → IsOrderedSubset (x::xs) (x::ys)
  | Tail x xs ys : IsOrderedSubset xs ys → IsOrderedSubset (x::xs) ys

def OrderedSubset (β : List α) := Subtype (IsOrderedSubset β)