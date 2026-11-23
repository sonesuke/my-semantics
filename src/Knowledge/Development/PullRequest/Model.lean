import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model

/-! # PRのモデル -/

namespace Knowledge.Development

/-! ## 本文 -/

/-- 本文 -/
structure PullRequest.Body where
  /-- 範囲。このPRが引き受ける変更要件。Issueの変更要件を変えたものでもよい。 -/
  scope : Artifact.ChangeRequest
  /-- 検証 -/
  verification : Artifact.Verification
  /-- 見積もり。Issueどおりに作った場合のルールと実装の費用。Issueどおりの実装はないので、提案者が見積もる。 -/
  estimate : Nat

/-- 要約。本文に依存させ、その本文の要約でしかあり得ないようにする。 -/
opaque PullRequest.Summary : PullRequest.Body → Type

/-! ## PR -/

/-- PR。Issueに応えて、実装の変更と範囲を持つ。 -/
structure PullRequest where
  issue : Issue
  diff : Implementation.Diff
  body : PullRequest.Body
  title : PullRequest.Summary body
  /-- CI結果。証拠として扱う。 -/
  ciResults : List Evidence

/-- 適用可能。実装の変更前が、適用先の実装と一致する。 -/
def PullRequest.Applicable (p : PullRequest) (a : Artifact) : Prop :=
  p.diff.before = a.implementations

/-- 変更後の成果物。適用先 `a` に、範囲と実装の変更を当てたもの。 -/
def PullRequest.result (p : PullRequest) (a : Artifact) : Artifact :=
  { requirements := p.body.scope.requirements a.requirements
    behaviors := p.body.scope.behaviors a.behaviors
    implementations := p.diff.after
    rules := p.body.scope.rules a.rules }

/-- 成果物の差分 -/
def PullRequest.artifactDiff (p : PullRequest) (a : Artifact) : Artifact.Diff :=
  ⟨a, p.result a⟩

/-- 範囲を変えた。理由だけの違いは含めない。 -/
def PullRequest.Rescoped (p : PullRequest) : Prop :=
  p.body.scope.requirements ≠ p.issue.changeRequest.requirements ∨
    p.body.scope.behaviors ≠ p.issue.changeRequest.behaviors ∨
    p.body.scope.rules ≠ p.issue.changeRequest.rules

/-- 届ける。範囲を実現する。 -/
def PullRequest.Delivers (p : PullRequest) (a : Artifact) : Prop :=
  (p.result a).Correct ∧ (p.result a).Conforms

/-- 解決する。Issueの変更要件を実現する。 -/
def PullRequest.Resolves (p : PullRequest) (a : Artifact) : Prop :=
  (p.result a).requirements = p.issue.changeRequest.requirements a.requirements ∧
    (p.result a).behaviors = p.issue.changeRequest.behaviors a.behaviors ∧
    (p.result a).rules = p.issue.changeRequest.rules a.rules ∧
    (p.result a).Correct ∧ (p.result a).Conforms

/-- 範囲を変えていなければ、届けることと解決することは一致する。 -/
theorem PullRequest.delivers_iff_resolves (p : PullRequest) (a : Artifact) (h : ¬p.Rescoped) :
    p.Delivers a ↔ p.Resolves a := by
  obtain ⟨hr, h⟩ := not_or.mp h
  obtain ⟨hb, hu⟩ := not_or.mp h
  have hr := Classical.not_not.mp hr
  have hb := Classical.not_not.mp hb
  have hu := Classical.not_not.mp hu
  simp [PullRequest.Delivers, PullRequest.Resolves, PullRequest.result, hr, hb, hu]

/-- 検証を通る -/
def PullRequest.Verified (p : PullRequest) (a : Artifact) : Prop :=
  p.body.verification.verified (p.artifactDiff a)

/-- 健全な検証を通るPRは、範囲を届ける。 -/
theorem PullRequest.delivers_of_verified (p : PullRequest) (a : Artifact)
    (hs : p.body.verification.Sound) (hv : p.Verified a) : p.Delivers a :=
  hs (p.artifactDiff a) hv

/-- 承認。人間がPRを受け入れる判断。理由と見積もりの妥当さ、要求の価値はここで判断する。 -/
opaque PullRequest.Approval : PullRequest → Type

/-- 承認されたPR -/
abbrev PullRequest.Approved := (p : PullRequest) × PullRequest.Approval p

/-- 証拠。検証の証拠とCI結果。 -/
def PullRequest.evidences (p : PullRequest) : List Evidence :=
  p.body.verification.evidences ++ p.ciResults

end Knowledge.Development
