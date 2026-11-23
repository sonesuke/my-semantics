import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model
import Knowledge.Development.PullRequest.Model

/-! # Repositoryのモデル -/

namespace Knowledge.Development

/-- リポジトリ状態。PRはこの要素なので、PRが変えるのはリポジトリ状態ではなく成果物である。 -/
structure Repository where
  artifact : Artifact
  issues : List Issue
  pullRequests : List PullRequest

/-- 適用可能。リポジトリ状態を参照するので、循環を避けてPRではなくここに置く。 -/
def PullRequest.Applicable (s : Repository) (p : PullRequest) : Prop :=
  p.diff.before = s.artifact

end Knowledge.Development
