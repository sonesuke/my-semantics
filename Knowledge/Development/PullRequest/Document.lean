import Knowledge.Development.Justification.Deviation
import Knowledge.Documentation.Document.Model
import Knowledge.Documentation.Document.Style.Diction
import Knowledge.Documentation.Document.Style.Construction

/-! # PRの文書

PRを、レビュアーが読む文書として書くときの種類。文書の知識（Documentation）を、開発のPRに当てはめる。 -/

namespace Knowledge.Development

open Knowledge.Documentation

/-- PRの節の役割 -/
inductive PullRequest.Role where
  | summary       -- 要約：このPRが何をするか（タイトル）
  | decision      -- 判断してほしいこと：承認するか（逸脱の理由を受け入れるかも含む）
  | scope         -- 範囲：応えるIssueと、Issueから変えた点
  | change        -- 変更：実装の変更の要点
  | verification  -- 検証：確かめたこと（CIの結果は書き写さない）
  | deviation     -- 逸脱の理由：範囲・確かめない部分・見積もりの超過（逸脱があるときだけ）
  deriving DecidableEq

/-- PRの文書の種類。レビュアーに、承認するかを判断してもらう文書。判断は承認するかしないかの二値なので、
承認したら何を受け入れたことになるかを、範囲・変更・検証で過不足なく書く。
判断してほしいことは要約の直後に置き、レビュアーが何を判断するために読むのかを先に知らせる。
逸脱の理由は逸脱があるときだけ、最後に置く。
要約は新しい語を導入せずに言い切り、範囲と変更は具体的に書き、検証は証拠から確かめたことへのつながりを示す。
逸脱の理由は、なぜ既定路線から外れてよいかのつながりを示す。判断してほしいことは、新しい語を導入せず、
はい／いいえで答えられる形で依頼する。Issueと同じ語を使い、言い直さない。 -/
def PullRequest.genre : Genre where
  Role := PullRequest.Role
  layout := Genre.ordered [.summary, .decision, .scope, .change, .verification, .deviation]
    [.summary, .decision, .scope, .change, .verification]
  style
    | .summary => fun s => s.Assertive ∧ s.NoNewWords
    | .scope => Style.Concrete
    | .change => Style.Concrete
    | .verification => fun s => s.Concrete ∧ s.Connective
    | .deviation => Style.Connective
    | .decision => fun s => s.Requesting ∧ s.YesNo ∧ s.NoNewWords
  styleAcross := Style.NoRephrasing

/-- 検算。逸脱がなければ、逸脱の理由の節を省いてよい。 -/
example : PullRequest.genre.layout [.summary, .decision, .scope, .change, .verification] := by
  simp only [PullRequest.genre, Genre.ordered]; decide

/-- 検算。検証の節は省けない。 -/
example : ¬PullRequest.genre.layout [.summary, .decision, .scope, .change] := by
  simp only [PullRequest.genre, Genre.ordered]; decide

/-- 検算。判断は範囲より前に置く。 -/
example : ¬PullRequest.genre.layout [.summary, .scope, .decision, .change, .verification] := by
  simp only [PullRequest.genre, Genre.ordered]; decide

/-! ## 文書がPRを表す -/

/-- PRの部分。文書で伝える事柄のもとになる。逸脱の理由は一つずつ伝えるので、理由ごとに分ける。 -/
inductive PullRequest.Part where
  | title                         -- タイトル
  | scope                         -- 範囲
  | change                        -- 実装の変更（作った時点の成果物から変更後の実装への差）
  | verification                  -- 検証
  | deviation (j : Justification)  -- 逸脱の理由一つ
  | decision                      -- 承認を求めること

/-- `p.States x q` は「事柄 `q` が、PR `p` の部分 `x` を述べる」。どう書くかとは独立に決まる。
一つの部分を複数の事柄で述べてもよい。 -/
opaque PullRequest.States : PullRequest → PullRequest.Part → Point → Prop

/-- 部分を伝える節の役割 -/
def PullRequest.Part.role : PullRequest.Part → PullRequest.Role
  | .title => .summary
  | .scope => .scope
  | .change => .change
  | .verification => .verification
  | .deviation _ => .deviation
  | .decision => .decision

/-- 伝えるべき部分。逸脱は、承認で理由を読まなければならないものをすべて含む。 -/
noncomputable def PullRequest.parts (c : CognitiveCost) (p : PullRequest) : List PullRequest.Part :=
  [.title, .scope, .change, .verification] ++ (p.deviations c).map .deviation ++ [.decision]

/-- PRの文書。種類をPRの文書の種類に固定し、内容と節の並びだけを決める。
種類を固定するので、節の役割をPRの節の役割として扱える。 -/
def PullRequest.document (content : Content) (sections : List (Section PullRequest.genre)) : Document :=
  ⟨content, PullRequest.genre, sections⟩

/-- 文書がPRを表す。内容は、伝えるべき部分のそれぞれを述べる事柄を含み、どの部分も述べない事柄を含まない。
文書は意味を保ち、どの事柄も、それが述べる部分の役割の節で伝える。
文書が書き手の選んだ内容でなくPRから決まる内容を伝えるようにし、逸脱の理由を書かずに済ませられないようにする。 -/
structure PullRequest.Describes (c : CognitiveCost) (p : PullRequest) (content : Content)
    (sections : List (Section PullRequest.genre)) : Prop where
  complete : ∀ x ∈ p.parts c, ∃ q ∈ content.points, p.States x q  -- 部分ごとに、述べる事柄がある
  sound : ∀ q ∈ content.points, ∃ x ∈ p.parts c, p.States x q     -- どの事柄も、どれかの部分を述べる
  faithful : (PullRequest.document content sections).Faithful     -- 意味を保つ
  placed : ∀ s ∈ sections, ∀ q ∈ s.points, ∀ x ∈ p.parts c,
    p.States x q → s.role = x.role                                -- 述べる部分の役割の節で伝える

/-- 逸脱があるPRを表す文書には、逸脱の理由の節がある。種類だけでは省いてよい節が、PRを表すことで必須になる。 -/
theorem PullRequest.Describes.deviation_mem {c : CognitiveCost} {p : PullRequest} {content : Content}
    {sections : List (Section PullRequest.genre)} (h : p.Describes c content sections)
    (hd : p.deviations c ≠ []) :
    PullRequest.Role.deviation ∈ (PullRequest.document content sections).layout := by
  obtain ⟨j, hj⟩ := List.exists_mem_of_ne_nil _ hd
  have hx : PullRequest.Part.deviation j ∈ p.parts c := by simp [PullRequest.parts, hj]
  obtain ⟨q, hq, hst⟩ := h.complete _ hx
  obtain ⟨s, hs, hqs, _⟩ := h.faithful.1 q hq
  exact List.mem_map.mpr ⟨s, hs, h.placed s hs q hqs _ hx hst⟩

end Knowledge.Development
