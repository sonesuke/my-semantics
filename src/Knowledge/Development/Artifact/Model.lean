import Knowledge.Development.Justification.Model

/-! # 成果物のモデル -/

namespace Knowledge.Development

/-- 実装 -/
opaque Implementation : Type

/-- 振る舞い。成果物が何をするか。一つの振る舞いは複数の実装の協調で実現されるので、実装全体を相手にする。 -/
structure Behavior where
  RealizedBy : List Implementation → Prop  -- 実装全体が振る舞いを実現する

/-- 要求。振る舞いが満たすべき条件。 -/
structure Requirement where
  SatisfiedBy : List Behavior → Prop  -- 振る舞い全体が要求を満たす

/-- 設計ルール。実装が従う決まり。要求でも振る舞いでもない。
ルールは各実装の書き方についての決まりなので、振る舞いと違い実装一つずつを相手にする。 -/
structure Rule where
  ConformedBy : Implementation → Prop  -- 実装一つがルールに適合する

/-- 成果物。開発者が作り、保守するもの。設計ルールも含める。 -/
structure Artifact where
  requirements : List Requirement        -- 要求
  behaviors : List Behavior              -- 振る舞い
  implementations : List Implementation  -- 実装
  rules : List Rule                      -- 設計ルール

/-- 正しい。どの要求も振る舞い全体が満たし、どの振る舞いも実装全体が実現する。 -/
def Artifact.Correct (a : Artifact) : Prop :=
  (∀ r ∈ a.requirements, r.SatisfiedBy a.behaviors) ∧
    ∀ b ∈ a.behaviors, b.RealizedBy a.implementations

/-- 適合する。どの実装も、すべての設計ルールに適合する。 -/
def Artifact.Conforms (a : Artifact) : Prop :=
  ∀ r ∈ a.rules, ∀ i ∈ a.implementations, r.ConformedBy i

/-- 差分。操作ではなく前後の組にするのは、どの成果物に対する差分かを自分で示すため。 -/
structure Artifact.Diff where
  before : Artifact  -- 変更前
  after : Artifact   -- 変更後

/-- 変更要件。要求・振る舞い・設計ルールをどう変えるか。実装の変更は持たない。
変更前の状態を持たず変え方として持つのは、どの時点の成果物にも当てられるようにするため。
理由は差の正当化ではなく、要求の価値を述べる。 -/
structure Artifact.ChangeRequest where
  requirements : List Requirement → List Requirement  -- 要求の変え方
  behaviors : List Behavior → List Behavior           -- 振る舞いの変え方
  rules : List Rule → List Rule                       -- 設計ルールの変え方
  justification : Justification                       -- なぜこの変更を求めるか

/-- 変更要件を当てた成果物。適用先 `a` に変更要件 `cr` を当て、実装を `is` にしたもの。 -/
def Artifact.ChangeRequest.apply (cr : Artifact.ChangeRequest) (a : Artifact)
    (is : List Implementation) : Artifact :=
  { requirements := cr.requirements a.requirements
    behaviors := cr.behaviors a.behaviors
    implementations := is
    rules := cr.rules a.rules }

end Knowledge.Development
