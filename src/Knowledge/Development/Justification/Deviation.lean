import Knowledge.Development.Cost.Model

/-! # 逸脱のモデル

PRの理由は、既定路線との差を正当化する。 -/

namespace Knowledge.Development

/-- 既定路線。作った時点の成果物にIssueの変更要件をそのまま当て、実装が最小である成果物 `b`。 -/
def PullRequest.DefaultMinimalImplementation (c : CognitiveCost) (p : PullRequest) (b : Artifact) :
    Prop :=
  b.requirements = p.issue.changeRequest.requirements p.base.requirements ∧
    b.behaviors = p.issue.changeRequest.behaviors p.base.behaviors ∧
    b.rules = p.issue.changeRequest.rules p.base.rules ∧
    b.MinimalImplementation c

/-- 見積もりを超える。結果のルールと実装の費用が、既定路線の見積もりより大きい。 -/
def PullRequest.OverEstimate (c : CognitiveCost) (p : PullRequest) : Prop :=
  p.body.estimate < p.result.ruleImplementationCost c

/-- 範囲を変えた理由。変えていなければない。 -/
def PullRequest.Scope.justifications : PullRequest.Scope → List Justification
  | .asIssued => []
  | .rescoped _ j => [j]

open Classical in
/-- 逸脱。既定路線との差のうち、承認で理由を読まなければならないもの。 -/
noncomputable def PullRequest.deviations (c : CognitiveCost) (p : PullRequest) : List Justification :=
  p.body.scope.justifications ++
    p.body.verification.uncovered ++
    (if p.OverEstimate c then [p.body.implementationJustification] else [])

end Knowledge.Development
