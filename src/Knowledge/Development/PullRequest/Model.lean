import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model

/-! # PRのモデル -/

namespace Knowledge.Development

/-! ## 本文 -/

/-- 本文 -/
structure PullRequest.Body where
  /-- 範囲。このPRが引き受ける要求・振る舞い・設計ルールの変更。
  Issueの変更要件に、PRがさらに変更を加えたものでもよい。 -/
  scope : Artifact.ChangeRequest
  /-- 変更後が正しく、ルールに適合することの検証 -/
  verification : Artifact.Verification
  /-- 見積もり。Issueどおりに作った場合の、ルールと実装の費用を認知コストで測ったもの。
  PRはIssueどおりの実装を持たないので、提案者が見積もり、妥当であることを理由で示し、承認で受け入れられる。 -/
  estimate : Nat

/-- 要約。本文に依存する型なので、そのPRの本文の要約でしかあり得ない。中身は明かさない。 -/
opaque PullRequest.Summary : PullRequest.Body → Type

/-! ## PR -/

/-- PR。Issueに応えて、実装の変更と、要求・振る舞い・設計ルールの変更への変更を持つ。 -/
structure PullRequest where
  issue : Issue
  diff : Implementation.Diff
  body : PullRequest.Body
  title : PullRequest.Summary body
  /-- CI結果は証拠として扱う -/
  ciResults : List Evidence

/-- 変更前の成果物。範囲と実装の変更前から組み立てる。 -/
def PullRequest.base (p : PullRequest) : Artifact :=
  { requirements := p.body.scope.requirements.before
    behaviors := p.body.scope.behaviors.before
    implementations := p.diff.before
    rules := p.body.scope.rules.before }

/-- 変更後の成果物。範囲と実装の変更後から組み立てる。 -/
def PullRequest.result (p : PullRequest) : Artifact :=
  { requirements := p.body.scope.requirements.after
    behaviors := p.body.scope.behaviors.after
    implementations := p.diff.after
    rules := p.body.scope.rules.after }

/-- 成果物の差分。PRを成果物の差分として見たもの。 -/
def PullRequest.artifactDiff (p : PullRequest) : Artifact.Diff :=
  ⟨p.base, p.result⟩

/-- 適用可能。変更前の成果物が、適用先の成果物と一致する。 -/
def PullRequest.Applicable (p : PullRequest) (a : Artifact) : Prop :=
  p.base = a

/-- 範囲を変えた。PRが、Issueの要求・振る舞い・設計ルールの変更のいずれかに、さらに変更を加えた。
理由だけの違いは範囲の変更としない。範囲を変えた理由は、範囲が持つ理由に置く。 -/
def PullRequest.Rescoped (p : PullRequest) : Prop :=
  p.body.scope.requirements ≠ p.issue.changeRequest.requirements ∨
    p.body.scope.behaviors ≠ p.issue.changeRequest.behaviors ∨
    p.body.scope.rules ≠ p.issue.changeRequest.rules

/-- 届ける。変更後の成果物が正しく、ルールに適合する。
変更後の要求・振る舞い・設計ルールは範囲から決まるので、範囲を届けることになる。 -/
def PullRequest.Delivers (p : PullRequest) : Prop :=
  p.result.Correct ∧ p.result.Conforms

/-- 解決する。変更後の要求・振る舞い・設計ルールがIssueの求めるものであり、
変更後の成果物が正しく、ルールに適合する。 -/
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

/-- 承認（Approve）。人間がPRを受け入れる判断。範囲とその理由、見積もり、検証の理由を受け入れることを含む。
要求の価値の判断もここで行う。PRに依存する型なので、そのPRの承認でしかあり得ない。中身は明かさない。 -/
opaque PullRequest.Approval : PullRequest → Type

/-- 承認されたPR。PRとその承認の組。 -/
abbrev PullRequest.Approved := (p : PullRequest) × PullRequest.Approval p

/-- 証拠。本文の検証の証拠とCI結果を合わせたもの。 -/
def PullRequest.evidences (p : PullRequest) : List Evidence :=
  p.body.verification.evidences ++ p.ciResults

end Knowledge.Development
