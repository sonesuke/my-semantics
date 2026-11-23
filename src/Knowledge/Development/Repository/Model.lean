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

end Knowledge.Development
