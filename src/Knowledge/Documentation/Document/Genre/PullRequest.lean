import Knowledge.Documentation.Document.Model
import Knowledge.Documentation.Document.Style.Diction
import Knowledge.Documentation.Document.Style.Construction

/-! # PR -/

namespace Knowledge.Documentation

/-- PRの節の役割 -/
inductive PullRequestRole where
  /-- 要約。このPRが何をするか。タイトルにあたる。 -/
  | summary
  /-- 範囲。どのIssueに応えるか。Issueのとおりか、変えたならどう変えたか。 -/
  | scope
  /-- 変更。実装をどう変えたかの要点。 -/
  | change
  /-- 検証。振る舞いとルールごとに確かめたこと。CIの結果は書き写さない。 -/
  | verification
  /-- 逸脱の理由。範囲を変えた理由、確かめない部分の理由、見積もりを超えた理由。逸脱があるときだけ置く。 -/
  | deviation
  /-- 判断してほしいこと。このPRを承認するか。逸脱があれば、その理由を受け入れるかも含む。 -/
  | decision
  deriving DecidableEq

/-- PR。レビュアーに、承認するかを判断してもらう文書。判断は承認するかしないかの二値なので、
承認したら何を受け入れたことになるかを、範囲・変更・検証で過不足なく書く。
逸脱の理由は逸脱があるときだけ置き、判断は他の節を前提にするので最後に置く。
要約は新しい語を導入せずに言い切り、範囲と変更は具体的に書き、検証は証拠から確かめたことへのつながりを示す。
逸脱の理由は、なぜ既定路線から外れてよいかのつながりを示す。判断してほしいことは、新しい語を導入せず、
はい／いいえで答えられる形で依頼する。Issueと同じ語を使い、言い直さない。 -/
def pullRequest : Genre where
  Role := PullRequestRole
  layout := Genre.ordered [.summary, .scope, .change, .verification, .deviation, .decision]
    [.summary, .scope, .change, .verification, .decision]
  style
    | .summary => fun s => s.Assertive ∧ s.NoNewWords
    | .scope => Style.Concrete
    | .change => Style.Concrete
    | .verification => fun s => s.Concrete ∧ s.Connective
    | .deviation => Style.Connective
    | .decision => fun s => s.Requesting ∧ s.YesNo ∧ s.NoNewWords
  styleAcross := Style.NoRephrasing

/-- 検算。逸脱がなければ、逸脱の理由の節を省いてよい。 -/
example : pullRequest.layout [.summary, .scope, .change, .verification, .decision] := by
  simp only [pullRequest, Genre.ordered]; decide

/-- 検算。検証の節は省けない。 -/
example : ¬pullRequest.layout [.summary, .scope, .change, .decision] := by
  simp only [pullRequest, Genre.ordered]; decide

/-- 検算。判断は最後に置く。 -/
example : ¬pullRequest.layout [.summary, .scope, .change, .decision, .verification] := by
  simp only [pullRequest, Genre.ordered]; decide

end Knowledge.Documentation
