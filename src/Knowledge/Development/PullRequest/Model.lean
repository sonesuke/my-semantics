import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model
import Knowledge.Development.Verification.Model

/-! # PRのモデル -/

namespace Knowledge.Development

/-- 理由。変更要件の充足と証拠から外れるもの（修正、検証の残し）を支える。 -/
structure PullRequest.Justification where

/-- 変更要件の修正。修正前は元の変更要件と食い違い得るので持たない。 -/
structure PullRequest.Amendment where
  after : Issue.Modification
  justification : PullRequest.Justification

/-- 変更要件の充足 -/
structure PullRequest.ModificationFulfillment where
  modification : Issue.Modification
  amendment : Option PullRequest.Amendment

/-- 充足すべき変更要件 -/
def PullRequest.ModificationFulfillment.target (f : PullRequest.ModificationFulfillment) :
    Issue.Modification :=
  match f.amendment with
  | none => f.modification
  | some a => a.after

/-- 検証の状況。理由のない検証の残しは表せない。 -/
structure PullRequest.VerificationStatus where
  verified : List (Verification.Obligation × Verification.Evidence)
  /-- 検証の残し -/
  remaining : List (Verification.Obligation × PullRequest.Justification)

/-- 本文 -/
structure PullRequest.Body where
  modification : PullRequest.ModificationFulfillment
  verification : PullRequest.VerificationStatus

/-- 要約。本文に依存する型なので、そのPRの本文の要約でしかあり得ない。 -/
structure PullRequest.Summary (body : PullRequest.Body) where

/-- PR。提案は差分に、理由は本文とCI結果に置く。 -/
structure PullRequest where
  body : PullRequest.Body
  title : PullRequest.Summary body
  diff : Artifact.Diff
  ciResults : List (Verification.Obligation × Verification.Evidence)

namespace PullRequest

/-- 充足する。差分についての一つの命題なので、部分的な充足は表せない。 -/
def Fulfills (p : PullRequest) : Prop :=
  p.body.modification.target.admits p.diff

/-- 検証済みの検証責務。CI結果も含める。 -/
def verified (p : PullRequest) : List (Verification.Obligation × Verification.Evidence) :=
  p.body.verification.verified ++ p.ciResults

theorem fulfills_of_no_amendment (p : PullRequest)
    (h : p.body.modification.amendment = none) :
    p.Fulfills ↔ p.body.modification.modification.admits p.diff := by
  simp [Fulfills, ModificationFulfillment.target, h]

theorem fulfills_of_amendment (p : PullRequest) (a : Amendment)
    (h : p.body.modification.amendment = some a) : p.Fulfills ↔ a.after.admits p.diff := by
  simp [Fulfills, ModificationFulfillment.target, h]

end PullRequest

end Knowledge.Development
