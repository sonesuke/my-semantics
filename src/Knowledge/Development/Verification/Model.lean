import Knowledge.Development.Artifact.Model

/-! # 検証のモデル -/

namespace Knowledge.Development

/-- 証拠。中身は明かさない。 -/
opaque Evidence : Type

/-- 確かめたか。確かめたなら `P` の証明を、確かめないならその理由を持つ。 -/
inductive Coverage (P : Prop) where
  | covered (h : P)
  | uncovered (j : Justification)

/-- 確かめない理由。確かめたなら持たない。 -/
def Coverage.justification {P : Prop} : Coverage P → Option Justification
  | .covered _ => none
  | .uncovered j => some j

/-- 確かめない部分の理由の一覧 -/
def Coverage.justifications {α : Type} {P : α → Prop} (l : List α) (f : ∀ x ∈ l, Coverage (P x)) :
    List Justification :=
  l.attach.filterMap fun ⟨x, h⟩ => (f x h).justification

/-- 検証。差分 `d` の変更後の振る舞いとルールのそれぞれについて、確かめたか、確かめない理由を持つ。
すべてについて持たせるのは、足りない部分を書かずに済ませられないようにするため。
要求を振る舞いが満たすかは承認で判断する。 -/
structure Verification (d : Artifact.Diff) where
  /-- 証拠。複数あるのは検証ではなく、一つの検証を支える証拠である。 -/
  evidences : List Evidence
  behaviors : ∀ b ∈ d.after.behaviors, Coverage (b.RealizedBy d.after.implementations)
  rules : ∀ r ∈ d.after.rules, Coverage (∀ i ∈ d.after.implementations, r.ConformedBy i)

/-- 確かめない部分の理由 -/
def Verification.uncovered {d : Artifact.Diff} (v : Verification d) :
    List Justification :=
  Coverage.justifications d.after.behaviors v.behaviors ++ Coverage.justifications d.after.rules v.rules

/-- 確かめない部分がなければ、変更後は振る舞いが実現され、ルールに適合する。 -/
theorem Verification.realizes_of_uncovered_nil {d : Artifact.Diff}
    (v : Verification d) (h : v.uncovered = []) :
    (∀ b ∈ d.after.behaviors, b.RealizedBy d.after.implementations) ∧ d.after.Conforms := by
  simp only [Verification.uncovered, List.append_eq_nil_iff, Coverage.justifications,
    List.filterMap_eq_nil_iff] at h
  obtain ⟨hb, hr⟩ := h
  constructor
  · intro b hb'
    have := hb ⟨b, hb'⟩ (List.mem_attach _ _)
    revert this
    cases v.behaviors b hb' with
    | covered p => intro _; exact p
    | uncovered j => intro h; simp [Coverage.justification] at h
  · intro r hr' i hi
    have := hr ⟨r, hr'⟩ (List.mem_attach _ _)
    revert this
    cases v.rules r hr' with
    | covered p => intro _; exact p i hi
    | uncovered j => intro h; simp [Coverage.justification] at h

end Knowledge.Development
