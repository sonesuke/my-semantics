import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model
import Knowledge.Development.PullRequest.Model

/-! # Repositoryのモデル -/

namespace Knowledge.Development

/-- リポジトリ状態。今の成果物も、IssueとPRの状態も持たず、最初の成果物とマージの履歴から求める。
状態を別に持つと、履歴と食い違い得るため。 -/
structure Repository where
  initial : Artifact
  /-- マージの履歴。古い順。 -/
  merged : List PullRequest.Approved
  /-- 作られたすべてのIssue -/
  issues : List Issue
  /-- 作られたすべてのPR -/
  pullRequests : List PullRequest

/-- 成果物 `a` に、PRを順にマージした後の成果物。 -/
def Artifact.mergeAll (a : Artifact) : List PullRequest.Approved → Artifact
  | [] => a
  | p :: ps => p.1.result.mergeAll ps

/-- 履歴が一貫している。どのPRも、その時点の成果物に適用可能である。
正しさは求めない。逸脱の理由はPRが必ず示し、受け入れるかは承認で判断する。 -/
def Artifact.Mergeable (a : Artifact) : List PullRequest.Approved → Prop
  | [] => True
  | p :: ps => p.1.Applicable a ∧ p.1.result.Mergeable ps

/-- 今の成果物 -/
def Repository.artifact (s : Repository) : Artifact :=
  s.initial.mergeAll s.merged

/-- 一貫している -/
def Repository.Consistent (s : Repository) : Prop :=
  s.initial.Mergeable s.merged

/-- マージされた。マージの履歴に含まれる。 -/
def Repository.Merged (s : Repository) (p : PullRequest) : Prop :=
  p ∈ s.merged.map (·.1)

/-- 成果物 `a` からPRを順にマージする間に、Issue `i` に応えて範囲を届けたPRがある。 -/
def Artifact.ResolvesAlong (a : Artifact) (i : Issue) : List PullRequest.Approved → Prop
  | [] => False
  | p :: ps => (p.1.issue = i ∧ p.1.Applicable a ∧ p.1.Delivers) ∨ p.1.result.ResolvesAlong i ps

/-- 解決された。マージの履歴の中に、その時点の成果物でIssueに応えて範囲を届けたPRがある。
PRは承認されてマージされ、承認は範囲の変更を認めることでもあるので、範囲を変えていても解決とみなす。 -/
def Repository.Resolved (s : Repository) (i : Issue) : Prop :=
  s.initial.ResolvesAlong i s.merged

/-- 開いているPR -/
def Repository.OpenPullRequest (s : Repository) (p : PullRequest) : Prop :=
  p ∈ s.pullRequests ∧ ¬s.Merged p

/-- 開いているIssue -/
def Repository.OpenIssue (s : Repository) (i : Issue) : Prop :=
  i ∈ s.issues ∧ ¬s.Resolved i

end Knowledge.Development
