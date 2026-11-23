import Knowledge.Development.Repository.Model

/-! # 費用のモデル

ルールと実装の費用は読まれるたびに、承認の費用（`Cost/Approval`）は一度だけかかる。 -/

namespace Knowledge.Development

/-- 認知コスト。単位は何でもよいが、同じ基準で測るので一つの組にする。 -/
structure CognitiveCost where
  /-- ルールを覚える費用 -/
  rule : Rule → Nat
  /-- ルールを知った上で実装を読む費用。ルールが実装を読みやすくする効果を表すため、ルールに依存させる。 -/
  implementation : List Rule → Implementation → Nat
  /-- PR自体を読む費用。PRの読みやすさはこの費用として表れる。 -/
  reading : Repository → PullRequest → Nat
  /-- 空のPRはPRとして成立しないので、常に正。 -/
  reading_positive : ∀ s p, 0 < reading s p
  /-- 理由を読む費用 -/
  justification : Justification → Nat

/-- ルールを覚える費用の合計。数で測らないのは、一つのルールにすべてを詰め込めるため。 -/
def Rule.cost (c : CognitiveCost) (rules : List Rule) : Nat :=
  (rules.map c.rule).sum

/-- 実装を読む費用の合計。 -/
def Implementation.cost (c : CognitiveCost) (rules : List Rule) (is : List Implementation) : Nat :=
  (is.map (c.implementation rules)).sum

/-- ルールと実装の費用。ルールを増やすと前者が増え後者が減るので、和で釣り合いを測る。 -/
def Artifact.ruleImplementationCost (c : CognitiveCost) (a : Artifact) : Nat :=
  Rule.cost c a.rules + Implementation.cost c a.rules a.implementations

/-- 実装が最小。要求・振る舞い・ルールが同じものの中で、実装の費用が最小である。 -/
def Artifact.MinimalImplementation (c : CognitiveCost) (a : Artifact) : Prop :=
  a.Correct ∧ a.Conforms ∧
    ∀ b : Artifact, b.requirements = a.requirements → b.behaviors = a.behaviors →
      b.rules = a.rules → b.Correct → b.Conforms →
      Implementation.cost c a.rules a.implementations ≤ Implementation.cost c b.rules b.implementations

end Knowledge.Development
