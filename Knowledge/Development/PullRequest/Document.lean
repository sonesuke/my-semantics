import Knowledge.Development.Justification.Deviation
import Knowledge.Documentation.Document.Model

/-! # PRの文書

PRを、レビュアーが読む文書として書くときの種類。文書の知識（Documentation）を、開発のPRに当てはめる。 -/

namespace Knowledge.Development

open Knowledge.Documentation

/-! ## 役割 -/

/-- 要約。このPRが何をするかを示す（タイトル）。新しい語を導入せずに言い切る。 -/
def PullRequest.Role.summary : Role := ⟨"要約", fun s => s.sentences.Assertive ∧ s.diction.NoNewWords⟩

/-- 判断してほしいこと。承認するか（逸脱の理由を受け入れるかも含む）について、何に答えればよいかを示す。
新しい語を導入せず、はい／いいえで答えられる形で依頼する。 -/
def PullRequest.Role.decision : Role := ⟨"判断してほしいこと", fun s => s.sentences.Requesting ∧ s.sentences.YesNo ∧ s.diction.NoNewWords⟩

/-- 範囲。承認したら何を受け入れるかの境界を示す（応えるIssueと、Issueから変えた点）。具体的に書く。 -/
def PullRequest.Role.scope : Role := ⟨"範囲", fun s => s.diction.Concrete⟩

/-- 変更。実装の変更の要点を示す。具体的に書く。 -/
def PullRequest.Role.change : Role := ⟨"変更", fun s => s.diction.Concrete⟩

/-- 検証。正しいと信じてよい根拠を示す（CIの結果は書き写さない）。具体的に書き、証拠から確かめたことへのつながりを示す。 -/
def PullRequest.Role.verification : Role := ⟨"検証", fun s => s.diction.Concrete ∧ s.sentences.Connective⟩

/-- 逸脱の理由。既定路線から外れてよい理由を示す（範囲・確かめない部分・見積もりの超過）。つながりを示す。 -/
def PullRequest.Role.deviation : Role := ⟨"逸脱の理由", fun s => s.sentences.Connective⟩

/-! ## 話題

承認する人が答えを知りたい問い。PRのフィールドから立てる。 -/

/-- 要約。このPRは何をするのか（`title`） -/
def PullRequest.Topic.summary : Topic := ⟨"要約"⟩

/-- 承認するか（PRそのもの） -/
def PullRequest.Topic.approval : Topic := ⟨"承認するか"⟩

/-- 何を変えるのか（`scope` の変更要件） -/
def PullRequest.Topic.scope : Topic := ⟨"何を変えるのか"⟩

/-- 実装をどう変えたか（`base` から `implementations` への差） -/
def PullRequest.Topic.change : Topic := ⟨"実装をどう変えたか"⟩

/-- 費用の見積もり（`estimate`）。実装の理由が要るかどうかの基準。水増しを確かめられるよう、いつも伝える。 -/
def PullRequest.Topic.estimate : Topic := ⟨"費用の見積もり"⟩

/-- 振る舞いとルールを確かめたか（`verification` の確かめた部分） -/
def PullRequest.Topic.verification : Topic := ⟨"確かめたこと"⟩

/-- 外れてよい理由（範囲を変えた理由、確かめない理由、見積もりを超えたときの実装の理由） -/
def PullRequest.Topic.deviation : Topic := ⟨"外れてよい理由"⟩

/-- PRの内容を節にする方針。見積もりは実装の費用の基準なので、変更の節に置く。 -/
def PullRequest.place (t : Topic) (r : Role) : Prop :=
  (t.name, r.name) ∈
    [(PullRequest.Topic.summary.name, PullRequest.Role.summary.name),
      (PullRequest.Topic.approval.name, PullRequest.Role.decision.name),
      (PullRequest.Topic.scope.name, PullRequest.Role.scope.name),
      (PullRequest.Topic.change.name, PullRequest.Role.change.name),
      (PullRequest.Topic.estimate.name, PullRequest.Role.change.name),
      (PullRequest.Topic.verification.name, PullRequest.Role.verification.name),
      (PullRequest.Topic.deviation.name, PullRequest.Role.deviation.name)]

/-! ## 種類 -/

/-- PRの役割の並び。要約・判断してほしいこと・範囲・変更・検証は必ず置き、逸脱の理由は省いてよい。 -/
def PullRequest.order : List Section → Prop :=
  Genre.ordered
    [PullRequest.Role.summary, PullRequest.Role.decision, PullRequest.Role.scope, PullRequest.Role.change,
      PullRequest.Role.verification, PullRequest.Role.deviation]
    [PullRequest.Role.summary, PullRequest.Role.decision, PullRequest.Role.scope, PullRequest.Role.change,
      PullRequest.Role.verification]

/-- PRの文書の種類。レビュアーに、承認するかを判断してもらう文書。判断は承認するかしないかの二値なので、
承認したら何を受け入れたことになるかを、範囲・変更・検証で過不足なく書く。
判断してほしいことは要約の直後に置き、レビュアーが何を判断するために読むのかを先に知らせる。
逸脱の理由は逸脱があるときだけ、最後に置く。Issueと同じ語を使い、言い直さない。 -/
def PullRequest.genre : Genre where
  layout := PullRequest.order
  style ss := Diction.NoRephrasing (ss.map (·.diction))
  place := PullRequest.place

/-- 検算。逸脱がなければ、逸脱の理由の節を省いてよい。 -/
example (ss : List Section) (h : ss.map (·.role.name) = ["要約", "判断してほしいこと", "範囲", "変更", "検証"]) :
    PullRequest.order ss := by
  simp only [PullRequest.order, Genre.ordered, h]; decide

/-- 検算。検証の節は省けない。 -/
example (ss : List Section) (h : ss.map (·.role.name) = ["要約", "判断してほしいこと", "範囲", "変更"]) :
    ¬PullRequest.order ss := by
  simp only [PullRequest.order, Genre.ordered, h]; decide

/-- 検算。判断は範囲より前に置く。 -/
example (ss : List Section) (h : ss.map (·.role.name) = ["要約", "範囲", "判断してほしいこと", "変更", "検証"]) :
    ¬PullRequest.order ss := by
  simp only [PullRequest.order, Genre.ordered, h]; decide

/-! ## 文書がPRを表す -/

/-- PRの部分。文書で伝える事柄のもとになる。逸脱の理由は一つずつ伝えるので、理由ごとに分ける。 -/
inductive PullRequest.Part where
  | title                         -- タイトル
  | approval                      -- 承認を求めること
  | scope                         -- 範囲の変更要件
  | change                        -- 実装の変更（作った時点の成果物から変更後の実装への差）
  | estimate                      -- 見積もり
  | verification                  -- 検証の確かめた部分
  | deviation (j : Justification)  -- 逸脱の理由一つ

/-- `p.States x q` は「事柄 `q` が、PR `p` の部分 `x` を述べる」。どう書くかとは独立に決まる。
一つの部分を複数の事柄で述べてもよい。 -/
opaque PullRequest.States : PullRequest → PullRequest.Part → Point → Prop

/-- 部分の話題 -/
def PullRequest.Part.topic : PullRequest.Part → Topic
  | .title => PullRequest.Topic.summary
  | .approval => PullRequest.Topic.approval
  | .scope => PullRequest.Topic.scope
  | .change => PullRequest.Topic.change
  | .estimate => PullRequest.Topic.estimate
  | .verification => PullRequest.Topic.verification
  | .deviation _ => PullRequest.Topic.deviation

/-- 伝えるべき部分。逸脱は、承認で理由を読まなければならないものをすべて含む。 -/
noncomputable def PullRequest.parts (c : CognitiveCost) (p : PullRequest) : List PullRequest.Part :=
  [.title, .approval, .scope, .change, .estimate, .verification] ++ (p.deviations c).map .deviation

/-- PRの文書。種類をPRの文書の種類に固定し、内容と節の並びだけを決める。 -/
def PullRequest.document (content : Content) (sections : List Section) : Document :=
  ⟨content, PullRequest.genre, sections⟩

/-- 内容がPRを表す。伝えるべき部分のそれぞれを述べる事柄を含み、どの部分も述べない事柄を含まない。
事柄の話題は、それが述べる部分の話題である。内容を書き手が選ぶのでなく、PRから決まるようにし、
逸脱の理由を書かずに済ませられないようにする。内容を節にするのは文書（意味を保つ、種類に従う）の仕事。 -/
structure PullRequest.Describes (c : CognitiveCost) (p : PullRequest) (content : Content) : Prop where
  complete : ∀ x ∈ p.parts c, ∃ q ∈ content.points,
    p.States x q ∧ content.topic q = x.topic                     -- 部分ごとに、述べる事柄がある
  sound : ∀ q ∈ content.points, ∃ x ∈ p.parts c,
    p.States x q ∧ content.topic q = x.topic                     -- どの事柄も、どれかの部分を述べる

/-- 逸脱があるPRを表す内容を、意味を保ち種類に従って節にした文書には、逸脱の理由の節がある。
種類の並びでは省いてよい節が、PRを表すことで必須になる。 -/
theorem PullRequest.Describes.deviation_mem {c : CognitiveCost} {p : PullRequest} {content : Content}
    {sections : List Section} (h : p.Describes c content)
    (hf : (PullRequest.document content sections).Faithful)
    (hc : (PullRequest.document content sections).Conforms)
    (hd : p.deviations c ≠ []) :
    PullRequest.Role.deviation.name ∈ sections.map (·.role.name) := by
  obtain ⟨j, hj⟩ := List.exists_mem_of_ne_nil _ hd
  have hx : PullRequest.Part.deviation j ∈ p.parts c := by simp [PullRequest.parts, hj]
  obtain ⟨q, hq, _, htop⟩ := h.complete _ hx
  obtain ⟨s, hs, hqs, _⟩ := hf.1 q hq
  have hp := hc.2.2.2 s hs q hqs
  simp only [PullRequest.document, PullRequest.genre, htop, PullRequest.Part.topic] at hp
  refine List.mem_map.mpr ⟨s, hs, ?_⟩
  simp [PullRequest.place, PullRequest.Topic.summary, PullRequest.Topic.approval, PullRequest.Topic.scope,
    PullRequest.Topic.change, PullRequest.Topic.estimate, PullRequest.Topic.verification,
    PullRequest.Topic.deviation, PullRequest.Role.summary, PullRequest.Role.decision, PullRequest.Role.scope,
    PullRequest.Role.change, PullRequest.Role.verification, PullRequest.Role.deviation] at hp ⊢
  exact hp

end Knowledge.Development
