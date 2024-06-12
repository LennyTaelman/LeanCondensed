/-
Copyright (c) 2024 Dagur Asgeirsson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Dagur Asgeirsson
-/
import Mathlib.Algebra.Homology.ShortComplex.FunctorEquivalence
import Mathlib.Algebra.Homology.ShortComplex.Limits
import Mathlib.Algebra.Homology.ShortComplex.ModuleCat
import Mathlib.Algebra.Homology.ShortComplex.ShortExact
import Mathlib.Condensed.Light.Module
/-!

# Project: AB axioms, light condensed abelian groups has countable AB4*, etc.


-/

open CategoryTheory Limits ShortComplex

universe v u w

namespace CategoryTheory.Limits

section

variable (I : Type*) [Category I]
variable (A : Type*) [Category A] [HasZeroMorphisms A]


example : I ⥤ ShortComplex A ≌ ShortComplex (I ⥤ A) :=
  (functorEquivalence I A).symm

class HasExactLimitsOfShape : Prop where
  hasLimitsOfShape : HasLimitsOfShape I A := by infer_instance
  exact_limit : ∀ (F : I ⥤ ShortComplex A), ∀ i, (F.obj i).ShortExact → (limit F).ShortExact

class HasExactColimitsOfShape : Prop where
  hasColimitsOfShape : HasColimitsOfShape I A := by infer_instance
  exact_colimit : ∀ (F : I ⥤ ShortComplex A), ∀ i, (F.obj i).ShortExact → (colimit F).ShortExact

end

section

variable (A : Type u) [Category.{v} A] [HasZeroMorphisms A]

abbrev AB4 : Prop := ∀ (I : Type w), HasExactColimitsOfShape (Discrete I) A

abbrev AB4star : Prop := ∀ (I : Type w), HasExactLimitsOfShape (Discrete I) A

abbrev countableAB4star : Prop := ∀ (I : Type) [Countable I], HasExactLimitsOfShape (Discrete I) A

abbrev AB5 : Prop := ∀ (I : Type v) [SmallCategory I] [IsFiltered I], HasExactColimitsOfShape I A

end

section

variable (A : Type*) [Category A] [Preadditive A]
variable (I : Type*) [Category I] (F : I ⥤ ShortComplex A)


lemma mono_of_mono [HasLimitsOfShape I A] (h : ∀ i, Mono (F.obj i).f) :
    Mono (ShortComplex.limitCone F).pt.f := by
  simp only [ShortComplex.limitCone, Functor.const_obj_obj]
  have : Mono (whiskerLeft F ShortComplex.π₁Toπ₂) := by
    apply (config := {allowSynthFailures := true}) NatTrans.mono_of_mono_app
    exact h
  infer_instance

lemma forall_exact_iff_functorEquivalence_exact : (∀ i, (F.obj i).Exact) ↔
    ((functorEquivalence I A).inverse.obj F).Exact := by
  constructor
  · intro h
    simp only [functorEquivalence_inverse, FunctorEquivalence.inverse]
    sorry
  · sorry

lemma left_exact_of_left_exact [HasLimitsOfShape I A]
    (h : ∀ i, Mono (F.obj i).f ∧ (F.obj i).Exact) :
    Mono (ShortComplex.limitCone F).pt.f ∧ (ShortComplex.limitCone F).pt.Exact := by
  sorry

lemma epi_of_epi [HasColimitsOfShape I A] (h : ∀ i, Epi (F.obj i).g) :
    Epi (ShortComplex.colimitCocone F).pt.g := by
  simp only [ShortComplex.colimitCocone, Functor.const_obj_obj]
  have : Epi (whiskerLeft F ShortComplex.π₂Toπ₃) := by
    apply (config := {allowSynthFailures := true}) NatTrans.epi_of_epi_app
    exact h
  infer_instance

lemma abStar_of_preserves_epi [HasLimitsOfShape I A] (h : (∀ i, Epi (F.obj i).g) →
  Epi (ShortComplex.limitCone F).pt.g) : HasExactLimitsOfShape I A := sorry

lemma ab_of_preserves_mono [HasColimitsOfShape I A] (h : (∀ i, Mono (F.obj i).f) →
  Epi (ShortComplex.colimitCocone F).pt.f) : HasExactColimitsOfShape I A := sorry

lemma finite_abStar [Finite I] : HasExactLimitsOfShape I A := sorry

lemma finite_ab [Finite I] : HasExactColimitsOfShape I A := sorry

end

end CategoryTheory.Limits

namespace LightCondensed

variable (R : Type u) [Ring R]

-- the goal (maybe we need some conditions on `R`):
instance : countableAB4star (LightCondMod.{u} R) := sorry

end LightCondensed
