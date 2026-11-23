import Knowledge.Development.Repository.Model

/-! # 費用のモデル

リポジトリの費用とレビューの費用を区別する。リポジトリの費用は状態で決まり、
PRの構成では変わらないので、レビューの費用には吸収しない。 -/

namespace Knowledge.Development

/-- ルールの費用。`ruleCost r` は「設計ルール `r` を覚える費用」。 -/
abbrev RuleCost := Rule → Nat

/-- 実装の費用。`implementationCost rules i` は「設計ルール `rules` を知った上で実装 `i` を読む費用」。
ルールに依存させるのは、ルールが実装を読みやすくする効果をこの費用の減少として表すため。 -/
abbrev ImplementationCost := List Rule → Implementation → Nat

/-- ルールを覚える費用の合計。ルールの数で測らないのは、一つのルールにすべてを詰め込めるため。 -/
def Rule.cost (ruleCost : RuleCost) (rules : List Rule) : Nat :=
  (rules.map ruleCost).sum

/-- 実装を読む費用の合計。 -/
def Implementation.cost (implementationCost : ImplementationCost) (rules : List Rule)
    (is : List Implementation) : Nat :=
  (is.map (implementationCost rules)).sum

/-- ルールと実装の費用。ルールを覚える費用と、ルールを前提に実装を読む費用の和。
ルールを増やすと前者が増え後者が減るので、この和でルールの釣り合いを測る。 -/
def Artifact.ruleImplementationCost (ruleCost : RuleCost) (implementationCost : ImplementationCost)
    (a : Artifact) : Nat :=
  Rule.cost ruleCost a.rules + Implementation.cost implementationCost a.rules a.implementations

/-- 実装が最小。要求・振る舞い・ルールが同じで、正しくルールに適合するものの中で、
実装を読む費用が最小である。 -/
def Artifact.MinimalImplementation (implementationCost : ImplementationCost) (a : Artifact) : Prop :=
  a.Correct ∧ a.Conforms ∧
    ∀ b : Artifact, b.requirements = a.requirements → b.behaviors = a.behaviors →
      b.rules = a.rules → b.Correct → b.Conforms →
      Implementation.cost implementationCost a.rules a.implementations ≤
        Implementation.cost implementationCost b.rules b.implementations

/-- レビューの費用。`reviewCost s p` は「リポジトリ状態 `s` を知るレビュアーが、PR `p` を理解し
受け入れを判断する費用」。PRの分割や提示の順序で変わる。 -/
abbrev ReviewCost := Repository → PullRequest → Nat

end Knowledge.Development
