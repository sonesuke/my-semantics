import Knowledge.Development.Artifact.Model

/-! # 検証のモデル -/

namespace Knowledge.Development

/-- 証拠。テストの実行結果や動作確認など。 -/
opaque Evidence : Type

/-- 観測された。動作確認によって、その証拠が実際に得られた。 -/
opaque Evidence.Observed : Evidence → Prop

/-- 確かめたか。証明は動作確認を伴って成立するので、確かめたなら、追加の証拠とそれが観測されたこと、
自動で確かめられた証拠 `automated` と合わせて観測されれば `P` が成り立つという論証を持つ。
確かめないなら、その理由を持つ。自動で確かめられた証拠は書き写さずに使えるようにする。 -/
inductive Coverage (automated : List Evidence) (P : Prop) where
  | covered (es : List Evidence) (observed : ∀ e ∈ es, e.Observed)  -- 確かめた：追加の証拠とその観測、
      (sufficiency : (∀ e ∈ automated ++ es, e.Observed) → P)      -- 観測されれば成り立つという論証
  | uncovered (j : Justification)                                    -- 確かめない：その理由

/-- 確かめない理由。確かめたなら持たない。 -/
def Coverage.justification {automated : List Evidence} {P : Prop} : Coverage automated P → Option Justification
  | .covered .. => none
  | .uncovered j => some j

/-- 確かめない部分の理由の一覧 -/
def Coverage.justifications {automated : List Evidence} {α : Type} {P : α → Prop} (l : List α)
    (f : ∀ x ∈ l, Coverage automated (P x)) :
    List Justification :=
  l.attach.filterMap fun ⟨x, h⟩ => (f x h).justification

/-- 検証。差分 `d` の変更後の振る舞いとルールのそれぞれについて、確かめたか、確かめない理由を持つ。
すべてについて持たせるのは、足りない部分を書かずに済ませられないようにするため。
`automated` はCIのように自動で確かめられた証拠で、すべてで使える。要求を振る舞いが満たすかは承認で判断する。 -/
structure Verification (d : Artifact.Diff) (automated : List Evidence) where
  behaviors : ∀ b ∈ d.after.behaviors, Coverage automated (b.RealizedBy d.after.implementations)    -- 変更後の振る舞いごと
  rules : ∀ r ∈ d.after.rules, Coverage automated (∀ i ∈ d.after.implementations, r.ConformedBy i)  -- 変更後のルールごと

/-- 確かめない部分の理由 -/
def Verification.uncovered {d : Artifact.Diff} {automated : List Evidence} (v : Verification d automated) :
    List Justification :=
  Coverage.justifications d.after.behaviors v.behaviors ++ Coverage.justifications d.after.rules v.rules

/-- 自動で確かめられた証拠が観測され、確かめない部分がなければ、変更後は振る舞いが実現され、ルールに適合する。 -/
theorem Verification.realizes_of_uncovered_nil {d : Artifact.Diff} {automated : List Evidence}
    (v : Verification d automated) (hs : ∀ e ∈ automated, e.Observed) (h : v.uncovered = []) :
    (∀ b ∈ d.after.behaviors, b.RealizedBy d.after.implementations) ∧ d.after.Conforms := by
  simp only [Verification.uncovered, List.append_eq_nil_iff, Coverage.justifications,
    List.filterMap_eq_nil_iff] at h
  obtain ⟨hb, hr⟩ := h
  constructor
  · intro b hb'
    have := hb ⟨b, hb'⟩ (List.mem_attach _ _)
    revert this
    cases v.behaviors b hb' with
    | covered _ o s => intro _; exact s (fun e he => (List.mem_append.mp he).elim (hs e) (o e))
    | uncovered j => intro h; simp [Coverage.justification] at h
  · intro r hr' i hi
    have := hr ⟨r, hr'⟩ (List.mem_attach _ _)
    revert this
    cases v.rules r hr' with
    | covered _ o s => intro _; exact s (fun e he => (List.mem_append.mp he).elim (hs e) (o e)) i hi
    | uncovered j => intro h; simp [Coverage.justification] at h

end Knowledge.Development
