import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model

/-! # PRのモデル -/

namespace Knowledge.Development

/-! ## 本文 -/

/-- 本文 -/
structure PullRequest.Body where
  /-- このPRが充足する変更要件。Issueの変更要件をPRで修正したものでもよい。 -/
  modification : Artifact.Modification
  /-- 変更要件を満たすことの検証 -/
  verification : Artifact.Verification

/-- 要約。本文に依存する型なので、そのPRの本文の要約でしかあり得ない。 -/
structure PullRequest.Summary (body : PullRequest.Body) where

/-! ## PR -/

/-- PR。Issueに応えて、提案は差分に、理由は本文とCI結果に置く。 -/
structure PullRequest where
  issue : Issue
  diff : Artifact.Diff
  body : PullRequest.Body
  title : PullRequest.Summary body
  /-- CI結果は証拠として扱う -/
  ciResults : List Evidence

/-- 適用可能。差分の変更前が、適用先の成果物と一致する。 -/
def PullRequest.Applicable (p : PullRequest) (a : Artifact) : Prop :=
  p.diff.before = a

/-- 変更要件を修正した。修正の理由は、修正後の変更要件が持つ理由に置く。 -/
def PullRequest.Amended (p : PullRequest) : Prop :=
  p.body.modification ≠ p.issue.modification

/-- 充足する。差分についての一つの命題なので、部分的な充足は表せない。 -/
def PullRequest.Fulfills (p : PullRequest) : Prop :=
  p.body.modification.admits p.diff

/-- 検証を通る -/
def PullRequest.Verified (p : PullRequest) : Prop :=
  p.body.verification.verified p.diff

/-- 健全な検証を通るPRは、変更要件を充足する。 -/
theorem PullRequest.fulfills_of_verified (p : PullRequest)
    (hs : p.body.verification.Sound p.body.modification) (hv : p.Verified) : p.Fulfills :=
  hs p.diff hv

/-- 証拠。本文の検証の証拠とCI結果を合わせたもの。 -/
def PullRequest.evidences (p : PullRequest) : List Evidence :=
  p.body.verification.evidences ++ p.ciResults

end Knowledge.Development
