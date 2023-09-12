import Init.Data.List
namespace LeanGccJit
namespace Utilities

@[reducible]
def HList : List Type → Type
  | [] => Unit
  | [x] => x
  | h::t => Prod h (HList t)

inductive NoDup : List α → Prop
  | nil : NoDup []
  | cons a l : a ∉ l → NoDup l → NoDup (a :: l)

abbrev NoDupList α := @Subtype (List α) NoDup
attribute [simp] NoDup.cons
attribute [simp] NoDup.nil

abbrev AttrList α := List (String × α)

@[reducible]
def AttrListMap (δ : AttrList α) (f : (String × α) → β) : List β := δ.map f

abbrev Names (δ : AttrList α) := AttrListMap δ (·.1)
abbrev AttributeOf (δ : AttrList α) := Subtype (· ∈ (Names δ))

@[reducible]
def ValueOf {δ: AttrList α} (n : AttributeOf δ) : α :=
  match δ, n with
  | [], ⟨_, _⟩ => by contradiction
  | ⟨x, val⟩::xs, ⟨x', prop⟩ => 
    if h : x = x' 
    then val 
    else ValueOf {
        val :=x',
        property := by
          simp [AttributeOf, Names, AttrListMap, List.map] at prop
          cases prop;
          contradiction;
          assumption;
    }

@[reducible]
def Proj (x : List (String × α)) (n : List String) : List α := 
  match x, n with
  | [], _ => []
  | _, [] => []
  | (u, ty) :: xs, v::ns => if u == v then ty :: Proj xs ns else Proj xs n

@[reducible]
def Proj' (x : List (String × α)) (n : List String) : List (String × α) := 
  match x, n with
  | [], _ => []
  | _, [] => []
  | (u, ty) :: xs, v::ns => if u == v then ⟨ u, ty ⟩ :: Proj' xs ns else Proj' xs n

private def ProjEmpty {δ : List (String × α)} : Proj' δ [] = [] := by
  cases δ;
  simp_all [Proj'];
  simp;


def selectList {η : (String × α) → Type} {δ : List (String × α)} (xs : HList (δ.map η)) (n : List String) (f : {φ : (String × α)} → η φ → β) : List β := 
  match δ, xs, n with
  | [], (), _ => []
  | _, _, [] => []
  | [δ], x, n::_ => if δ.1 == n then [f x] else []
  | δ₀::δ₁::δ', (x, xs), n::ns => if δ₀.1 == n then f x :: selectList (δ := δ₁::δ') xs ns f else selectList (δ := δ₁::δ') xs (n::ns) f 

def selectArray {η : (String × α) → Type} {δ : List (String × α)} (xs : HList (δ.map η)) (n : List String) (f : {φ : (String × α)} → η φ → β) : Array β := 
  let rec selectArray' {η : (String × α) → Type} {δ : List (String × α)} (xs : HList (δ.map η)) (n : List String) (f : {φ : (String × α)} → η φ → β) (acc: Array β) : Array β := 
    match δ, xs, n with
    | [], (), _ => acc
    | _, _, [] => acc
    | [δ], x, n::_ => if δ.1 == n then acc.push (f x) else acc
    | δ₀::δ₁::δ', (x, xs), n::ns => if δ₀.1 == n then selectArray' (δ := δ₁::δ') xs ns f <| acc.push (f x) else selectArray' (δ := δ₁::δ') xs (n::ns) f acc
  selectArray' xs n f #[]
    
def collectList {δ : List α} {μ : α → Type} (xs : HList (δ.map μ)) (f: {τ : α} → μ τ → β) : List β := 
  match δ, xs with
  | [], () => []
  | [_], h => [f h]
  | _::t::ts, (b, bs) => f b :: collectList (δ := t::ts) bs f

def collectArray {δ : List α} {μ : α → Type} (xs : HList (δ.map μ)) (f: {τ : α} → μ τ → β) : Array β := 
  let rec collectArray' {δ : List α} {μ : α → Type} (xs : HList (δ.map μ)) (f: {τ : α} → μ τ → β) (acc: Array β) : Array β := 
    match δ, xs with
    | [], () => acc
    | [_], h => acc.push <| f h
    | _::t::ts, (b, bs) => collectArray' (δ := t::ts) bs f <| acc.push (f b)
  collectArray' xs f #[]