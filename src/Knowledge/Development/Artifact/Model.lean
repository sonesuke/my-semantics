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

/-- 成果物 -/
structure Artifact where
  requirements : Requirements
  behavior : Behavior
  implementation : Implementation

/-- 正しい。振る舞いが要求を満たし、実装が振る舞いを実現する。 -/
def Artifact.Correct (a : Artifact) : Prop :=
  a.requirements.SatisfiedBy a.behavior ∧ a.behavior.RealizedBy a.implementation

/-- 差分。操作ではなく前後の組にするのは、どの成果物に対する差分かを自分で示すため。 -/
structure Artifact.Diff where
  before : Artifact
  after : Artifact

end Knowledge.Development
