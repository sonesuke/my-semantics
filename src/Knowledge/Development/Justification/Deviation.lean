import Knowledge.Development.Cost.Model

/-! # 逸脱のモデル

PRの理由は、既定路線との差を正当化する。 -/

namespace Knowledge.Development

/-- 既定路線。適用先 `a` にIssueの変更要件をそのまま当て、実装が最小である成果物 `b`。 -/
def PullRequest.DefaultMinimalImplementation (c : CognitiveCost) (p : PullRequest) (a b : Artifact) : Prop :=
  b.requirements = p.issue.changeRequest.requirements a.requirements ∧
    b.behaviors = p.issue.changeRequest.behaviors a.behaviors ∧
    b.rules = p.issue.changeRequest.rules a.rules ∧
    b.MinimalImplementation c

/-- 見積もりを超える。結果のルールと実装の費用が、既定路線の見積もりより大きい。 -/
def PullRequest.OverEstimate (c : CognitiveCost) (p : PullRequest) (a : Artifact) : Prop :=
  p.body.estimate < (p.result a).ruleImplementationCost c

open Classical in
/-- 逸脱。既定路線との差のうち、承認で理由を読まなければならないもの。 -/
noncomputable def PullRequest.deviations (c : CognitiveCost) (p : PullRequest) (a : Artifact) :
    List Justification :=
  (if p.Rescoped then [p.body.scope.justification] else []) ++
    (if p.Verified a then [] else [p.body.verification.justification]) ++
    (if p.OverEstimate c a then [p.body.implementationJustification] else [])

end Knowledge.Development
