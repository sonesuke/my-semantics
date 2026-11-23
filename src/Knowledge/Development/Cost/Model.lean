import Knowledge.Development.Repository.Model

/-! # 費用のモデル

ルールと実装の費用と、レビューの費用を区別する。前者は成果物で決まり、読まれるたびにかかる。
後者はPRの構成で決まり、一度だけかかる。 -/

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

/-- レビューの費用。PRの分割や提示の順序で変わる。 -/
structure ReviewCost where
  /-- `cost s p` は「リポジトリ状態 `s` を知るレビュアーが、PR `p` を理解し受け入れを判断する費用」。 -/
  cost : Repository → PullRequest → Nat
  /-- 空のPRはPRとして成立しないので、費用は常に正。 -/
  positive : ∀ s p, 0 < cost s p

/-- Issueどおりの成果物。Issueの変更要件の変更後の要求・振る舞い・ルールと、実装 `is` の組。 -/
def PullRequest.issueArtifact (p : PullRequest) (is : List Implementation) : Artifact :=
  { requirements := p.issue.changeRequest.requirements.after
    behaviors := p.issue.changeRequest.behaviors.after
    implementations := is
    rules := p.issue.changeRequest.rules.after }

/-- ROI。PRが生む価値を、レビューの費用で割ったもの。

分子は、PRが届ける価値 1 に、Issueどおりの成果物の費用とPRの結果の費用の差を、読まれる回数 `reads`
の分だけ足したもの。価値の項があるので、素直に実装しただけのPRも分母だけで決まらない。
価値を 1 に固定するのは、動かせると差の項を好きなだけ希薄にできるため。費用はPR一つの価値を単位に測ることになる。
差は、範囲を変えて費用が減れば正に、実装に無駄があれば負になる。
Issueどおりの成果物は、実装 `baseline` が最小（`MinimalImplementation`）であるものを想定する。
PRはIssueどおりの実装を持たないので、最も安い実装を基準にする。

費用だけでは要求をすべて消す変更が常に得になるので、範囲を変えたPRでは、
要求の価値の判断を範囲の理由の受け入れに任せる。 -/
def PullRequest.roi (ruleCost : RuleCost) (implementationCost : ImplementationCost)
    (reviewCost : ReviewCost) (reads : Nat) (baseline : List Implementation)
    (s : Repository) (p : PullRequest) : Rat :=
  let baselineCost := (p.issueArtifact baseline).ruleImplementationCost ruleCost implementationCost
  let resultCost := p.result.ruleImplementationCost ruleCost implementationCost
  ((1 : Int) + reads * ((baselineCost : Int) - resultCost) : Int) / (reviewCost.cost s p : Rat)

end Knowledge.Development
