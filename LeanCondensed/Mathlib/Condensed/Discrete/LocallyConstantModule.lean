import Mathlib.CategoryTheory.Sites.Adjunction
import Mathlib.Condensed.Module
import Mathlib.Topology.LocallyConstant.Algebra
import LeanCondensed.Mathlib.Condensed.Adjunctions
import LeanCondensed.Mathlib.Condensed.Discrete.LocallyConstant
import LeanCondensed.SheafHomForget

universe u

namespace Condensed.LocallyConstant

open CategoryTheory Limits Condensed LocallyConstant Opposite

variable (R : Type (u+1)) [Ring R]

/--
The comparison map from the value of a condensed set on a finite coproduct to the product of the
values on the components.
-/
def sigmaComparisonMod (X : CondensedMod R) {α : Type u} [Finite α] (σ : α → Type u)
    [∀ a, TopologicalSpace (σ a)] [∀ a, CompactSpace (σ a)] [∀ a, T2Space (σ a)] :
    X.val.obj ⟨(CompHaus.of ((a : α) × σ a))⟩ ⟶
      ModuleCat.of R (((a : α) → X.val.obj ⟨CompHaus.of (σ a)⟩)) where
  toFun := fun x a ↦ X.val.map ⟨Sigma.mk a, continuous_sigmaMk⟩ x
  map_add' := by aesop
  map_smul' := by aesop

lemma sigmaComparisonMod_eq_sigmaComparison
    (X : CondensedMod R) {α : Type u} [Finite α] (σ : α → Type u)
      [∀ a, TopologicalSpace (σ a)] [∀ a, CompactSpace (σ a)] [∀ a, T2Space (σ a)] :
        sigmaComparison ((Condensed.forget R).obj X) σ =
          ⇑(sigmaComparisonMod R X σ) :=
  rfl

instance (X : CondensedMod R) {α : Type u} [Finite α] (σ : α → Type u)
    [∀ a, TopologicalSpace (σ a)] [∀ a, CompactSpace (σ a)] [∀ a, T2Space (σ a)] :
    IsIso (sigmaComparisonMod R X σ) := by
  rw [ConcreteCategory.isIso_iff_bijective]
  simp only [ModuleCat.forget_map, ← sigmaComparisonMod_eq_sigmaComparison, ← isIso_iff_bijective]
  exact isIsoSigmaComparison _ _

lemma inv_sigmaComparisonMod_eq_sigmaComparison
    (X : CondensedMod R) {α : Type u} [Finite α] (σ : α → Type u)
      [∀ a, TopologicalSpace (σ a)] [∀ a, CompactSpace (σ a)] [∀ a, T2Space (σ a)] :
        ⇑(inv (sigmaComparisonMod R X σ)) =
          inv (sigmaComparison ((Condensed.forget R).obj X) σ) := by
  apply IsIso.eq_inv_of_hom_inv_id (f := (sigmaComparison ((Condensed.forget R).obj X) σ))
  ext x
  rw [sigmaComparisonMod_eq_sigmaComparison]
  change (_ ≫ inv (sigmaComparisonMod R X σ)) x = x
  simp


/-- The projection of the counit. -/
noncomputable def counitAppAppImageMod {S : CompHaus.{u}} {Y : CondensedMod.{u} R}
    (f : LocallyConstant S (Y.val.obj (op (CompHaus.of PUnit.{u+1})))) :
      ModuleCat.of R ((a : α f) → Y.val.obj ⟨CompHaus.of <| a.val⟩) :=
  fun a ↦ Y.val.map (IsTerminal.from CompHaus.isTerminalPUnit _).op a.image

-- lemma counitAppAppImageMod_add {S : CompHaus.{u}} {Y : CondensedMod.{u} R}
--     (f g : ModuleCat.of R (LocallyConstant S (Y.val.obj (op (CompHaus.of PUnit.{u+1}))))) :
--   counitAppAppImageMod R (f + g) =
--   (counitAppAppImageMod R f) + (counitAppAppImageMod R g) := sorry
-- doesn't make sense

-- def counitAppAppMod₁ (S : CompHaus.{u}) (Y : CondensedMod.{u} R) :
--     ModuleCat.of R (LocallyConstant S (Y.val.obj (op (CompHaus.of PUnit.{u+1})))) ⟶
--     ModuleCat.of R ((a : α ⇑f) → (Y.val.obj ⟨CompHaus.of (σ (⇑f) a)⟩)) := sorry

noncomputable def counitAppAppMod₂ {S : CompHaus.{u}} {Y : CondensedMod.{u} R}
    (f : LocallyConstant S (Y.val.obj (op (CompHaus.of PUnit.{u+1})))) :
    ModuleCat.of R ((a : α ⇑f) → (Y.val.obj ⟨CompHaus.of (σ (⇑f) a)⟩)) ⟶
    Y.val.obj ⟨S⟩ :=
  ((inv (sigmaComparisonMod R Y (σ f))) ≫ (Y.val.mapIso (sigmaIso f).op).inv)

noncomputable def counitAppAppMod (S : CompHaus.{u}) (Y : CondensedMod.{u} R) :
    ModuleCat.of R (LocallyConstant S (Y.val.obj (op (CompHaus.of PUnit.{u+1})))) ⟶
      Y.val.obj ⟨S⟩ where
  toFun := fun (f : LocallyConstant _ _) ↦
    ((inv (sigmaComparisonMod R Y (σ f))) ≫ (Y.val.mapIso (sigmaIso f).op).inv)
    (counitAppAppImageMod R f)
  map_add' x y := by
    -- simp [counitAppAppImageMod]
    dsimp only [Function.comp_apply]
    sorry
    -- rw [← ((inv (sigmaComparisonMod R Y (σ f))) ≫ (Y.val.mapIso (sigmaIso f).op).inv).map_add]
  map_smul' := sorry

/--
The functor from the category of modules to presheaves of modules on `CompHaus` given by locally
constant maps.
-/
@[simps]
noncomputable -- `comapₗ` is still unnecessarily noncomputable
def functorToPresheavesMod : ModuleCat.{u+1} R ⥤ (CompHaus.{u}ᵒᵖ ⥤ ModuleCat.{u+1} R) where
  obj X := {
    obj := fun ⟨S⟩ ↦ ModuleCat.of R (LocallyConstant S X)
    map := fun f ↦ LocallyConstant.comapₗ R f.unop }
  map f := {  app := fun S ↦ LocallyConstant.mapₗ R f }

/-- `Condensed.LocallyConstant.functorToPresheavesMod` lands in condensed modules. -/
@[simps]
noncomputable
def functorMod : ModuleCat.{u+1} R ⥤ CondensedMod.{u} R where
  obj X := {
    val := (functorToPresheavesMod R).obj X
    cond := by
      rw [Presheaf.isSheaf_iff_isSheaf_forget (s := CategoryTheory.forget _)]
      exact (functor.obj X).cond
  }
  map f := ⟨(functorToPresheavesMod R).map f⟩

noncomputable def counitMod : underlying (ModuleCat.{u+1} R) ⋙ functorMod R ⟶ 𝟭 _ where
  app X := by
    refine sheafForgetPromote _ (CategoryTheory.forget _)
      (counit.app ((Condensed.forget R).obj X)).val fun ⟨S⟩ ↦ ⟨counitAppAppMod R S X, ?_⟩
    ext (f : LocallyConstant _ _)
    simp only [Functor.comp_obj, underlying_obj, functorMod_obj_val, Functor.id_obj, counit_app,
      counitApp_val_app, counitAppApp, Functor.mapIso_inv, Iso.op_inv, types_comp_apply,
      LocallyConstant.toFun_eq_coe, ModuleCat.coe_comp, Function.comp_apply]
    erw [← inv_sigmaComparisonMod_eq_sigmaComparison]
    rfl
  naturality X Y f := by
    apply naturality_promote
    exact (Sheaf.Hom.ext_iff _ _).mp <| counit.naturality ((forget R).map f)

/--
The unit of the adjunciton is given by mapping each element to the corresponding constant map.

-- TODO: promote `LocallyConstant.const` to linear map etc. like `comap` and `map`.
-/
@[simps]
noncomputable def unitMod : 𝟭 _ ⟶ functorMod R ⋙ underlying _ where
  app X := {
    toFun := fun x ↦ LocallyConstant.const _ x
    map_add' := fun _ _ ↦ rfl
    map_smul' := fun _ _ ↦ rfl
  }

/--
`Condensed.LocallyConstant.functor` is left adjoint to the forgetful functor.
-/
@[simps! unit_app_apply counit_app_val_app]
noncomputable def adjunctionMod : functorMod R ⊣ underlying _ :=
  Adjunction.mkOfUnitCounit {
    unit := unitMod R
    counit := counitMod R
    left_triangle := by
      ext X
      apply (Condensed.forget R).map_injective
      have := adjunction.left_triangle
      rw [NatTrans.ext_iff] at this
      have := congrFun this ((CategoryTheory.forget _).obj X)
      simp only [Functor.comp_obj, Functor.id_obj, NatTrans.comp_app, underlying_obj,
        functor_obj_val, functorToPresheaves_obj_obj, CompHaus.coe_of, whiskerRight_app,
        whiskerLeft_app, NatTrans.id_app] at this
      simp only [Functor.comp_obj, Functor.id_obj, NatTrans.comp_app, underlying_obj,
        functorMod_obj_val, functorToPresheavesMod_obj_obj, CompHaus.coe_of, whiskerRight_app,
        Functor.associator_hom_app, whiskerLeft_app, Category.id_comp, Functor.map_comp,
        NatTrans.id_app', CategoryTheory.Functor.map_id]
      convert this
      apply Sheaf.hom_ext
      exact map_sheafForgetPromote
        (coherentTopology CompHaus.{u}) (CategoryTheory.forget (ModuleCat.{u+1} R)) _ _
    right_triangle := by
      ext X x
      simp only [Functor.comp_obj, Functor.id_obj, underlying_obj, counit, FunctorToTypes.comp,
        whiskerLeft_app, Functor.associator_inv_app, functor_obj_val, functorToPresheaves_obj_obj,
        types_id_apply, whiskerRight_app, underlying_map, counitApp_val_app, NatTrans.id_app']
      have := adjunction.right_triangle
      rw [NatTrans.ext_iff] at this
      have := congrFun this ((Condensed.forget _).obj X)
      simp only [Functor.comp_obj, underlying_obj, Functor.id_obj, NatTrans.comp_app,
        functor_obj_val, functorToPresheaves_obj_obj, CompHaus.coe_of, whiskerLeft_app,
        whiskerRight_app, underlying_map, NatTrans.id_app] at this
      simp only [NatTrans.comp_app, Functor.comp_obj, underlying_obj, Functor.id_obj,
        functorMod_obj_val, functorToPresheavesMod_obj_obj, CompHaus.coe_of, whiskerLeft_app,
        Functor.associator_inv_app, whiskerRight_app, underlying_map, Category.id_comp,
        ModuleCat.coe_comp, Function.comp_apply, ModuleCat.id_apply]
      have h := congrFun this x
      simp only [types_comp_apply, adjunction_counit_app_val_app, types_id_apply] at h
      convert h
      change ((Condensed.forget R).map _).val.app _ = _
      erw [map_sheafForgetPromote]
      rfl }
