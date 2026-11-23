import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model
import Knowledge.Development.Verification.Model

/-! # PRのモデル

PRは、足りない部分を書いていなければ作れない。レビューできるものだけをPRとする。 -/

namespace Knowledge.Development

/-! ## CI -/

/-- CI結果。CIは自動で走るので、その結果は観測されたものとして証拠に使ってよい。 -/
structure PullRequest.CI where
  results : List Evidence
  observed : ∀ e ∈ results, e.Observed

/-! ## 範囲 -/

/-- 範囲。このPRが引き受ける変更要件。Issueのとおりか、変えたか。
変えたなら、変えた変更要件と、なぜ変えたかの理由を持つ。変更要件の理由は「なぜこの変更をするか」のままにする。 -/
inductive PullRequest.Scope where
  | asIssued
  | rescoped (changeRequest : Artifact.ChangeRequest) (j : Justification)

/-- 範囲の変更要件 -/
def PullRequest.Scope.changeRequest (issue : Issue) : PullRequest.Scope → Artifact.ChangeRequest
  | .asIssued => issue.changeRequest
  | .rescoped cr _ => cr

/-! ## 本文 -/

/-- 本文。Issue、作った時点の成果物 `base`、変更後の実装 `is` に依存し、その変更の検証しか持てない。
CI結果 `ci` にも依存し、検証ではCI結果を書き写さずに証拠として使える。 -/
structure PullRequest.Body (issue : Issue) (base : Artifact) (is : List Implementation)
    (ci : PullRequest.CI) where
  scope : PullRequest.Scope
  /-- 検証 -/
  verification : Verification ⟨base, (scope.changeRequest issue).apply base is⟩ ci.results
  /-- 見積もり。既定路線のルールと実装の費用。既定路線の実装はないので、提案者が見積もる。 -/
  estimate : Nat
  /-- 実装の理由。実装の費用が見積もりを超えるとき、なぜ超えてよいか。 -/
  implementationJustification : Justification

/-- 要約。本文に依存させ、その本文の要約でしかあり得ないようにする。 -/
opaque PullRequest.Summary {issue : Issue} {base : Artifact} {is : List Implementation}
  {ci : PullRequest.CI} : PullRequest.Body issue base is ci → Type

/-! ## PR -/

/-- PR。Issueに応えて、作った時点の成果物に対する実装の変更と範囲を持つ。 -/
structure PullRequest where
  issue : Issue
  /-- 作った時点の成果物 -/
  base : Artifact
  /-- 変更後の実装 -/
  implementations : List Implementation
  ci : PullRequest.CI
  body : PullRequest.Body issue base implementations ci
  title : PullRequest.Summary body

/-- 引き受けた変更要件 -/
def PullRequest.changeRequest (p : PullRequest) : Artifact.ChangeRequest :=
  p.body.scope.changeRequest p.issue

/-- 変更後の成果物 -/
def PullRequest.result (p : PullRequest) : Artifact :=
  p.changeRequest.apply p.base p.implementations

/-- 成果物の差分 -/
def PullRequest.artifactDiff (p : PullRequest) : Artifact.Diff :=
  ⟨p.base, p.result⟩

/-- 適用可能 -/
def PullRequest.Applicable (p : PullRequest) (a : Artifact) : Prop :=
  p.base = a

/-- 範囲を変えた -/
def PullRequest.Rescoped (p : PullRequest) : Prop :=
  p.body.scope ≠ .asIssued

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
  have hs : p.body.scope = .asIssued := Classical.not_not.mp h
  simp [PullRequest.Delivers, PullRequest.Resolves, PullRequest.result, PullRequest.changeRequest,
    Artifact.ChangeRequest.apply, PullRequest.Scope.changeRequest, hs]

/-- 承認。人間がPRを受け入れる判断。正しさ、理由と見積もりの妥当さ、要求の価値はここで判断する。
範囲を変えたPRの承認は、その範囲の変更を認めることでもある。 -/
opaque PullRequest.Approval : PullRequest → Type

/-- 承認されたPR -/
abbrev PullRequest.Approved := (p : PullRequest) × PullRequest.Approval p

end Knowledge.Development
