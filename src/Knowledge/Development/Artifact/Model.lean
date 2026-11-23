/-! # 成果物のモデル -/

namespace Knowledge.Development

/-- 実装。中身は明かさない。 -/
opaque Implementation : Type

/-- 振る舞い。成果物が何をするか。 -/
structure Behavior where
  /-- `RealizedBy is` は「実装 `is` 全体が振る舞いを実現する」。 -/
  RealizedBy : List Implementation → Prop

/-- 要求。振る舞いが満たすべき条件。 -/
structure Requirement where
  /-- `SatisfiedBy bs` は「振る舞い `bs` 全体が要求を満たす」。 -/
  SatisfiedBy : List Behavior → Prop

/-- 設計ルール。実装が従う決まり。要求でも振る舞いでもない。 -/
structure Rule where
  /-- `ConformedBy i` は「実装 `i` がルールに適合する」。 -/
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

/-- 要求の変更 -/
structure Requirement.Diff where
  before : List Requirement
  after : List Requirement

/-- 振る舞いの変更 -/
structure Behavior.Diff where
  before : List Behavior
  after : List Behavior

/-- 設計ルールの変更 -/
structure Rule.Diff where
  before : List Rule
  after : List Rule

/-- 実装の変更 -/
structure Implementation.Diff where
  before : List Implementation
  after : List Implementation

/-- 理由。中身は明かさない。 -/
opaque Justification : Type

/-- 変更要件。要求・振る舞い・設計ルールをどう変えるか。実装の変更は持たない。 -/
structure Artifact.ChangeRequest where
  requirements : Requirement.Diff
  behaviors : Behavior.Diff
  rules : Rule.Diff
  /-- なぜこの変更をするか -/
  justification : Justification

/-- 証拠。中身は明かさない。 -/
opaque Evidence : Type

/-- 検証。変更後が正しく、ルールに適合することが本来の基準なのに対し、実際に確かめられる基準。
複数あるのは検証ではなく、一つの検証を支える証拠である。 -/
structure Artifact.Verification where
  /-- `verified d` は「差分 `d` が検証を通る」。 -/
  verified : Artifact.Diff → Prop
  evidences : List Evidence
  /-- なぜこの検証で十分か。確かめていない部分があれば、なぜ確かめなくてよいか -/
  justification : Justification

/-- 健全。検証を通る差分は、変更後が正しく、ルールに適合する。 -/
def Artifact.Verification.Sound (v : Artifact.Verification) : Prop :=
  ∀ d, v.verified d → d.after.Correct ∧ d.after.Conforms

end Knowledge.Development
