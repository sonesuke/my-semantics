import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model
import Knowledge.Development.Verification.Model

/-! # PRのモデル

PRは、足りない部分を書いていなければ作れない。レビューできるものだけをPRとする。 -/

namespace Knowledge.Development

/-- 変更要件を当てた成果物。適用先 `a` に変更要件 `cr` を当て、実装を `is` にしたもの。 -/
def Artifact.ChangeRequest.apply (cr : Artifact.ChangeRequest) (a : Artifact)
    (is : List Implementation) : Artifact :=
  { requirements := cr.requirements a.requirements
    behaviors := cr.behaviors a.behaviors
    implementations := is
    rules := cr.rules a.rules }

/-! ## 本文 -/

/-- 本文。作った時点の成果物 `base` と変更後の実装 `is` に依存し、その変更の検証しか持てない。 -/
structure PullRequest.Body (base : Artifact) (is : List Implementation) where
  /-- 範囲。このPRが引き受ける変更要件。Issueの変更要件を変えたものでもよい。 -/
  scope : Artifact.ChangeRequest
  /-- 検証 -/
  verification : Verification ⟨base, scope.apply base is⟩
  /-- 見積もり。既定路線のルールと実装の費用。既定路線の実装はないので、提案者が見積もる。 -/
  estimate : Nat
  /-- 実装の理由。実装の費用が見積もりを超えるとき、なぜ超えてよいか。 -/
  implementationJustification : Justification

/-- 要約。本文に依存させ、その本文の要約でしかあり得ないようにする。 -/
opaque PullRequest.Summary {base : Artifact} {is : List Implementation} :
  PullRequest.Body base is → Type

/-! ## PR -/

/-- PR。Issueに応えて、作った時点の成果物に対する実装の変更と範囲を持つ。 -/
structure PullRequest where
  issue : Issue
  /-- 作った時点の成果物 -/
  base : Artifact
  /-- 変更後の実装 -/
  implementations : List Implementation
  body : PullRequest.Body base implementations
  title : PullRequest.Summary body
  /-- CI結果。証拠として扱う。 -/
  ciResults : List Evidence

/-- 変更後の成果物 -/
def PullRequest.result (p : PullRequest) : Artifact :=
  p.body.scope.apply p.base p.implementations

/-- 成果物の差分 -/
def PullRequest.artifactDiff (p : PullRequest) : Artifact.Diff :=
  ⟨p.base, p.result⟩

/-- 適用可能 -/
def PullRequest.Applicable (p : PullRequest) (a : Artifact) : Prop :=
  p.base = a

/-- 範囲を変えた。理由だけの違いは含めない。 -/
def PullRequest.Rescoped (p : PullRequest) : Prop :=
  p.body.scope.requirements ≠ p.issue.changeRequest.requirements ∨
    p.body.scope.behaviors ≠ p.issue.changeRequest.behaviors ∨
    p.body.scope.rules ≠ p.issue.changeRequest.rules

/-- 届ける。範囲を実現する。 -/
def PullRequest.Delivers (p : PullRequest) : Prop :=
  p.result.Correct ∧ p.result.Conforms

/-- 解決する。Issueの変更要件を実現する。 -/
def PullRequest.Resolves (p : PullRequest) : Prop :=
  p.result.requirements = p.issue.changeRequest.requirements p.base.requirements ∧
    p.result.behaviors = p.issue.changeRequest.behaviors p.base.behaviors ∧
    p.result.rules = p.issue.changeRequest.rules p.base.rules ∧
    p.result.Correct ∧ p.result.Conforms

/-- 範囲を変えていなければ、届けることと解決することは一致する。 -/
theorem PullRequest.delivers_iff_resolves (p : PullRequest) (h : ¬p.Rescoped) :
    p.Delivers ↔ p.Resolves := by
  obtain ⟨hr, h⟩ := not_or.mp h
  obtain ⟨hb, hu⟩ := not_or.mp h
  have hr := Classical.not_not.mp hr
  have hb := Classical.not_not.mp hb
  have hu := Classical.not_not.mp hu
  simp [PullRequest.Delivers, PullRequest.Resolves, PullRequest.result,
    Artifact.ChangeRequest.apply, hr, hb, hu]

/-- 承認。人間がPRを受け入れる判断。正しさ、理由と見積もりの妥当さ、要求の価値はここで判断する。 -/
opaque PullRequest.Approval : PullRequest → Type

/-- 承認されたPR -/
abbrev PullRequest.Approved := (p : PullRequest) × PullRequest.Approval p

/-- 証拠。検証の証拠とCI結果。 -/
def PullRequest.evidences (p : PullRequest) : List Evidence :=
  p.body.verification.evidences ++ p.ciResults

end Knowledge.Development
