/-! # 成果物のモデル -/

namespace Knowledge.Development

/-- 実装。中身は明かさない。 -/
opaque Implementation : Type

/-- 振る舞い。成果物が何をするか。 -/
structure Behavior where
  /-- `RealizedBy i` は「実装 `i` が振る舞いを実現する」。 -/
  RealizedBy : Implementation → Prop

/-- 要求。振る舞いが満たすべき条件。 -/
structure Requirements where
  /-- `SatisfiedBy b` は「振る舞い `b` が要求を満たす」。 -/
  SatisfiedBy : Behavior → Prop

/-- 設計ルール。実装が従う決まり。要求でも振る舞いでもない。 -/
structure Rule where
  /-- `ConformedBy i` は「実装 `i` がルールに適合する」。 -/
  ConformedBy : Implementation → Prop

/-- 成果物。開発者が作り、保守するもの。設計ルールも含める。 -/
structure Artifact where
  requirements : Requirements
  behavior : Behavior
  implementation : Implementation
  rules : List Rule

/-- 正しい。振る舞いが要求を満たし、実装が振る舞いを実現する。 -/
def Artifact.Correct (a : Artifact) : Prop :=
  a.requirements.SatisfiedBy a.behavior ∧ a.behavior.RealizedBy a.implementation

/-- 適合する。実装がすべての設計ルールを満たす。 -/
def Artifact.Conforms (a : Artifact) : Prop :=
  ∀ r ∈ a.rules, r.ConformedBy a.implementation

/-- 差分。操作ではなく前後の組にするのは、どの成果物に対する差分かを自分で示すため。 -/
structure Artifact.Diff where
  before : Artifact
  after : Artifact

/-- 理由。中身は明かさない。 -/
opaque Justification : Type

/-- 変更要件。要求の書き換えではなく差分の条件にするのは、充足を差分についての命題にするため。 -/
structure Artifact.Modification where
  /-- 受け入れる -/
  admits : Artifact.Diff → Prop
  /-- なぜこの変更をするか -/
  justification : Justification

/-- 証拠。中身は明かさない。 -/
opaque Evidence : Type

/-- 検証。変更要件が本来の基準なのに対し、実際に確かめられる基準。
複数あるのは検証ではなく、一つの検証を支える証拠である。 -/
structure Artifact.Verification where
  /-- `verified d` は「差分 `d` が検証を通る」。 -/
  verified : Artifact.Diff → Prop
  evidences : List Evidence
  /-- なぜこの検証で十分か。確かめていない部分があれば、なぜ確かめなくてよいか -/
  justification : Justification

/-- 健全。検証を通る差分は、変更要件に受け入れられる。 -/
def Artifact.Verification.Sound (v : Artifact.Verification) (m : Artifact.Modification) : Prop :=
  ∀ d, v.verified d → m.admits d

end Knowledge.Development
