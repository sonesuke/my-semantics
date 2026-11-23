import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model

/-! # PRのモデル -/

namespace Knowledge.Development

/-! ## 本文 -/

/-- 本文 -/
structure PullRequest.Body where
  /-- このPRが充足する変更要件。Issueの変更要件をPRで修正したものでもよい。 -/
  modification : Artifact.Modification
  verifications : List Artifact.Verification

/-- 要約。本文に依存する型なので、そのPRの本文の要約でしかあり得ない。 -/
structure PullRequest.Summary (body : PullRequest.Body) where

/-! ## PR -/

/-- PR。Issueに応えて、提案は差分に、理由は本文とCI結果に置く。 -/
structure PullRequest where
  issue : Issue
  diff : Artifact.Diff
  body : PullRequest.Body
  title : PullRequest.Summary body
  ciResults : List Artifact.Verification

/-- 適用可能。差分の変更前が、適用先の成果物と一致する。 -/
def PullRequest.Applicable (p : PullRequest) (a : Artifact) : Prop :=
  p.diff.before = a

/-- 変更要件を修正した。修正の理由は、修正後の変更要件が持つ理由に置く。 -/
def PullRequest.Amended (p : PullRequest) : Prop :=
  p.body.modification ≠ p.issue.modification

/-- 充足する。差分についての一つの命題なので、部分的な充足は表せない。 -/
def PullRequest.Fulfills (p : PullRequest) : Prop :=
  p.body.modification.admits p.diff

/-- 検証。CI結果も含める。 -/
def PullRequest.verifications (p : PullRequest) : List Artifact.Verification :=
  p.body.verifications ++ p.ciResults

end Knowledge.Development
