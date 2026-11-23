import Knowledge.Development.Repository.Model

/-! # 費用のモデル

ルールと実装の費用と、承認の費用を区別する。前者は成果物で決まり、読まれるたびにかかる。
後者はPRの構成で決まり、一度だけかかる。 -/

namespace Knowledge.Development

/-- 認知コスト。理解に要する費用を測る一つの物差し。単位は何でもよいが、すべて同じ基準で測る。
一つの組にするのは、同じ基準で測ることを型に表すため。 -/
structure CognitiveCost where
  /-- `rule r` は「設計ルール `r` を覚える費用」。 -/
  rule : Rule → Nat
  /-- `implementation rules i` は「設計ルール `rules` を知った上で実装 `i` を読む費用」。
  ルールに依存させるのは、ルールが実装を読みやすくする効果をこの費用の減少として表すため。 -/
  implementation : List Rule → Implementation → Nat
  /-- `approval s p` は「リポジトリ状態 `s` を知る人間が、PR `p` を理解し承認を判断する費用」。
  PRの読みやすさはこの費用として表れ、PRの分割や提示の順序で変わる。 -/
  approval : Repository → PullRequest → Nat
  /-- 空のPRはPRとして成立しないので、承認の費用は常に正。 -/
  approval_positive : ∀ s p, 0 < approval s p

/-- ルールを覚える費用の合計。ルールの数で測らないのは、一つのルールにすべてを詰め込めるため。 -/
def Rule.cost (c : CognitiveCost) (rules : List Rule) : Nat :=
  (rules.map c.rule).sum

/-- 実装を読む費用の合計。 -/
def Implementation.cost (c : CognitiveCost) (rules : List Rule) (is : List Implementation) : Nat :=
  (is.map (c.implementation rules)).sum

/-- ルールと実装の費用。ルールを覚える費用と、ルールを前提に実装を読む費用の和。
ルールを増やすと前者が増え後者が減るので、この和でルールの釣り合いを測る。 -/
def Artifact.ruleImplementationCost (c : CognitiveCost) (a : Artifact) : Nat :=
  Rule.cost c a.rules + Implementation.cost c a.rules a.implementations

/-- 実装が最小。要求・振る舞い・ルールが同じで、正しくルールに適合するものの中で、
実装を読む費用が最小である。 -/
def Artifact.MinimalImplementation (c : CognitiveCost) (a : Artifact) : Prop :=
  a.Correct ∧ a.Conforms ∧
    ∀ b : Artifact, b.requirements = a.requirements → b.behaviors = a.behaviors →
      b.rules = a.rules → b.Correct → b.Conforms →
      Implementation.cost c a.rules a.implementations ≤ Implementation.cost c b.rules b.implementations

/-- ROI。PRが生む価値を、承認の費用で割ったもの。

分子は、PRが届ける価値 1 に、提案者が見積もったIssueどおりの費用とPRの結果の費用の差を、読まれる回数
`reads` の分だけ足したもの。見積もりは同じ認知コスト `c` で測ったものとする。
価値の項があるので、素直に実装しただけのPRも分母だけで決まらない。
価値を 1 に固定するのは、動かせると差の項を好きなだけ希薄にできるため。費用はPR一つの価値を単位に測ることになる。
差は、範囲を変えて費用が減れば正に、実装に無駄があれば負になる。
見積もりの妥当さと、範囲を変えて失う要求の価値は、承認で判断する。 -/
def PullRequest.roi (c : CognitiveCost) (reads : Nat) (s : Repository) (p : PullRequest) : Rat :=
  let resultCost := p.result.ruleImplementationCost c
  ((1 : Int) + reads * ((p.body.estimate : Int) - resultCost) : Int) / (c.approval s p : Rat)

end Knowledge.Development
