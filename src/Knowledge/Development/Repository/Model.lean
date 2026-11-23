import Knowledge.Development.Artifact.Model
import Knowledge.Development.Issue.Model
import Knowledge.Development.PullRequest.Model

/-! # Repositoryのモデル -/

namespace Knowledge.Development

/-- 設計ルール。実装に成り立たせること。要求でも振る舞いでもなく、同じ振る舞いを持つ実装の
ばらつき（リポジトリのエントロピー）を減らすためにリポジトリが定める。 -/
abbrev Rule := Implementation → Prop

/-- 認知負荷。覚えるべき設計ルールの負担 `cost` の合計。
ルールの数で測らないのは、一つのルールにすべてを詰め込めるため。 -/
def Rule.cognitiveLoad (cost : Rule → Nat) (rules : List Rule) : Nat :=
  (rules.map cost).sum

/-- リポジトリ状態。PRはこの要素なので、PRが変えるのはリポジトリ状態ではなく成果物である。 -/
structure Repository where
  artifact : Artifact
  rules : List Rule
  issues : List Issue
  pullRequests : List PullRequest

/-- 適合する。成果物の実装がすべての設計ルールを満たす。 -/
def Repository.Conforms (s : Repository) : Prop :=
  ∀ r ∈ s.rules, r s.artifact.implementation

/-- 適用可能。リポジトリ状態を参照するので、循環を避けてPRではなくここに置く。 -/
def PullRequest.Applicable (s : Repository) (p : PullRequest) : Prop :=
  p.diff.before = s.artifact

end Knowledge.Development
