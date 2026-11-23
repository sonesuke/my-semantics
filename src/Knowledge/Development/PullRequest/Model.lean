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

/-- 変更前の成果物 -/
def PullRequest.base (p : PullRequest) : Artifact :=
  { requirements := p.body.scope.requirements.before
    behaviors := p.body.scope.behaviors.before
    implementations := p.diff.before
    rules := p.body.scope.rules.before }

/-- 変更後の成果物 -/
def PullRequest.result (p : PullRequest) : Artifact :=
  { requirements := p.body.scope.requirements.after
    behaviors := p.body.scope.behaviors.after
    implementations := p.diff.after
    rules := p.body.scope.rules.after }

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
  p.result.requirements = p.issue.changeRequest.requirements.after ∧
    p.result.behaviors = p.issue.changeRequest.behaviors.after ∧
    p.result.rules = p.issue.changeRequest.rules.after ∧
    p.result.Correct ∧ p.result.Conforms

/-- 範囲を変えていなければ、届けることと解決することは一致する。 -/
theorem PullRequest.delivers_iff_resolves (p : PullRequest) (h : ¬p.Rescoped) :
    p.Delivers ↔ p.Resolves := by
  obtain ⟨hr, h⟩ := not_or.mp h
  obtain ⟨hb, hu⟩ := not_or.mp h
  have hr := Classical.not_not.mp hr
  have hb := Classical.not_not.mp hb
  have hu := Classical.not_not.mp hu
  simp [PullRequest.Delivers, PullRequest.Resolves, PullRequest.result, hr, hb, hu]

/-- 検証を通る -/
def PullRequest.Verified (p : PullRequest) : Prop :=
  p.body.verification.verified p.artifactDiff

/-- 健全な検証を通るPRは、範囲を届ける。 -/
theorem PullRequest.delivers_of_verified (p : PullRequest)
    (hs : p.body.verification.Sound) (hv : p.Verified) : p.Delivers :=
  hs p.artifactDiff hv

/-- 承認。人間がPRを受け入れる判断。理由と見積もりの妥当さ、要求の価値はここで判断する。 -/
opaque PullRequest.Approval : PullRequest → Type

/-- 承認されたPR -/
abbrev PullRequest.Approved := (p : PullRequest) × PullRequest.Approval p

/-- 証拠。検証の証拠とCI結果。 -/
def PullRequest.evidences (p : PullRequest) : List Evidence :=
  p.body.verification.evidences ++ p.ciResults

end Knowledge.Development
