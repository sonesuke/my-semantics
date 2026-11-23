import Knowledge.Development.Justification.Model

/-! # 成果物のモデル -/

namespace Knowledge.Development

/-- 実装 -/
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
  /-- なぜこの変更を求めるか。差の正当化ではなく、要求の価値を述べる。 -/
  justification : Justification

/-- 変更要件を当てた成果物。適用先 `a` に変更要件 `cr` を当て、実装を `is` にしたもの。 -/
def Artifact.ChangeRequest.apply (cr : Artifact.ChangeRequest) (a : Artifact)
    (is : List Implementation) : Artifact :=
  { requirements := cr.requirements a.requirements
    behaviors := cr.behaviors a.behaviors
    implementations := is
    rules := cr.rules a.rules }

end Knowledge.Development
