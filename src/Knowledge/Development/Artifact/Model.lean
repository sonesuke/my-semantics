import Knowledge.Development.Justification.Model

/-! # 成果物のモデル -/

namespace Knowledge.Development

/-- 実装。中身は明かさない。 -/
opaque Implementation : Type

/-- 振る舞い。成果物が何をするか。 -/
structure Behavior where
  /-- `RealizedBy is` は「実装 `is` 全体が振る舞いを実現する」。
  全体を相手にするのは、一つの振る舞いが複数の実装の協調で実現されるため。 -/
  RealizedBy : List Implementation → Prop

/-- 要求。振る舞いが満たすべき条件。 -/
structure Requirement where
  /-- `SatisfiedBy bs` は「振る舞い `bs` 全体が要求を満たす」。 -/
  SatisfiedBy : List Behavior → Prop

/-- 設計ルール。実装が従う決まり。要求でも振る舞いでもない。 -/
structure Rule where
  /-- `ConformedBy i` は「実装 `i` がルールに適合する」。
  振る舞いと違い実装一つずつを相手にするのは、ルールが各実装の書き方についての決まりであるため。 -/
  ConformedBy : Implementation → Prop

/-- 成果物。開発者が作り、保守するもの。設計ルールも含める。 -/
structure Artifact where
  requirements : List Requirement
  behaviors : List Behavior
  implementations : List Implementation
  rules : List Rule

/-- 正しい。どの要求も振る舞い全体が満たし、どの振る舞いも実装全体が実現する。 -/
def Artifact.Correct (a : Artifact) : Prop :=
  (∀ r ∈ a.requirements, r.SatisfiedBy a.behaviors) ∧
    ∀ b ∈ a.behaviors, b.RealizedBy a.implementations

/-- 適合する。どの実装も、すべての設計ルールに適合する。 -/
def Artifact.Conforms (a : Artifact) : Prop :=
  ∀ r ∈ a.rules, ∀ i ∈ a.implementations, r.ConformedBy i

/-- 差分。操作ではなく前後の組にするのは、どの成果物に対する差分かを自分で示すため。 -/
structure Artifact.Diff where
  before : Artifact
  after : Artifact

/-- 変更要件。要求・振る舞い・設計ルールをどう変えるか。実装の変更は持たない。
変更前の状態を持たず変え方として持つのは、どの時点の成果物にも当てられるようにするため。 -/
structure Artifact.ChangeRequest where
  requirements : List Requirement → List Requirement
  behaviors : List Behavior → List Behavior
  rules : List Rule → List Rule
  /-- なぜこの変更をするか -/
  justification : Justification

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
structure Artifact.Verification (d : Artifact.Diff) where
  /-- 証拠。複数あるのは検証ではなく、一つの検証を支える証拠である。 -/
  evidences : List Evidence
  behaviors : ∀ b ∈ d.after.behaviors, Coverage (b.RealizedBy d.after.implementations)
  rules : ∀ r ∈ d.after.rules, Coverage (∀ i ∈ d.after.implementations, r.ConformedBy i)

/-- 確かめない部分の理由 -/
def Artifact.Verification.uncovered {d : Artifact.Diff} (v : Artifact.Verification d) :
    List Justification :=
  Coverage.justifications d.after.behaviors v.behaviors ++ Coverage.justifications d.after.rules v.rules

/-- 確かめない部分がなければ、変更後は振る舞いが実現され、ルールに適合する。 -/
theorem Artifact.Verification.realizes_of_uncovered_nil {d : Artifact.Diff}
    (v : Artifact.Verification d) (h : v.uncovered = []) :
    (∀ b ∈ d.after.behaviors, b.RealizedBy d.after.implementations) ∧ d.after.Conforms := by
  simp only [Artifact.Verification.uncovered, List.append_eq_nil_iff, Coverage.justifications,
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
