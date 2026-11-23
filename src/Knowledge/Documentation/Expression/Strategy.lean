import Knowledge.Documentation.Expression.Theorems

/-! # 表現の最適化戦略

意味と理解の条件を保ちながら、理解までの費用を減らす表現を探す。 -/

namespace Knowledge.Documentation

/-- 戦略。変換の適用対象と、表現から有限個の変換候補を作る方法。 -/
structure Strategy where
  /-- 適用対象 -/
  domain : Expression → Prop
  /-- 変換候補 -/
  candidates : Expression → List Expression

namespace Strategy

variable (P : Premise) (w : Weights) (S : Strategy)

/-- 採用できる。入力か変換候補のうち、意味を保ち、理解できる経路があり、成功確率が下がらないもの。
入力そのものも含めるので、改善がなければ入力を残せる。 -/
def Feasible (e x : Expression) : Prop :=
  (x = e ∨ x ∈ S.candidates e) ∧ P.Faithful x ∧ P.Reachable w x ∧
    P.successProbability e ≤ P.successProbability x

/-- 選ぶ。採用できるもののうち、理解までの距離が最小のものを選ぶ。入力も最小なら入力を選ぶ。
候補の生成と改善の成立は別で、距離や確率を評価できなければ、選べるとまでは判定しない。 -/
def Chooses (e x : Expression) : Prop :=
  S.Feasible P w e x ∧ (∀ y, S.Feasible P w e y → P.DistanceLe w x y) ∧
    ((∀ y, S.Feasible P w e y → P.DistanceLe w e y) → x = e)

/-- 入力が採用できるなら、選んだ表現は入力より理解までの距離が大きくない。 -/
theorem distanceLe_of_chooses (e x : Expression) (he : S.Feasible P w e e) (h : S.Chooses P w e x) :
    P.DistanceLe w x e :=
  h.2.1 e he

end Strategy

/-! ## 具体的な戦略

形式（レイアウト）を変える戦略と、文体を変える戦略に分ける。費用の変化は「減り得る」「増え得る」成分であり、
改善は定理の条件で別に示す。 -/

/-- 費用の成分 -/
inductive CostComponent where
  | time
  | lookup
  | repair
  | search
  | memory

/-- 費用の変化。減り得る成分と、増え得る成分。 -/
structure CostEffect where
  reduces : List CostComponent
  increases : List CostComponent

/-! ### 形式 -/

/-- PREP法の節の役割 -/
inductive PrepRole where
  /-- 結論 -/
  | point
  /-- 理由 -/
  | reason
  /-- 具体例 -/
  | example

/-- PREP法。結論を先に示してから、理由と具体例で支持し、結論を繰り返す。文書の種類の一つとして表す。
適用対象は、結論・理由・具体例に分けられ、読者が冒頭の結論を理解できる表現。型に沿うこと自体を改善とはしない。 -/
def prep : Genre where
  Role := PrepRole
  layout := [.point, .reason, .example, .point]

/-- PREP法の費用の変化。結論を探す負担と、目的がわからないまま保持する負担が減り、反復の分だけ読む時間が増える。 -/
def prepEffect : CostEffect :=
  { reduces := [.search, .memory], increases := [.time] }

/-- まとまっている。同じ鍵を持つ要素が連続している。後ろに同じ鍵があれば、すぐ次の要素も同じ鍵を持つ。 -/
def Grouped {α β : Type} (key : α → β) : List α → Prop
  | [] => True
  | [_] => True
  | a :: b :: l => (key a ∈ (b :: l).map key → key b = key a) ∧ Grouped key (b :: l)

/-- 検算。`[1, 1, 2]` はまとまっている。 -/
example : Grouped id [1, 1, 2] := by simp [Grouped]

/-- 検算。`[1, 2, 1]` はまとまっていない。 -/
example : ¬Grouped id [1, 2, 1] := by simp [Grouped]

/-- 問いによるグループ化。各節が答える主な問い `question` ごとに、節を連続させる。
適用対象は、目的を問いに分けられ、節を移しても条件・参照先・実行順序を保てる表現。 -/
def Document.GroupedByQuestion {g : Genre} {Question : Type} (question : g.Role × Wording → Question)
    (d : Document g) : Prop :=
  Grouped question d.sections

/-- 問いによるグループ化の費用の変化。離れた指示を拾う負担と保持する負担が減り、見出しや補足、
複数のまとまりの往復が増える。 -/
def groupByQuestionEffect : CostEffect :=
  { reduces := [.search, .memory], increases := [.time, .search] }

/-- 前提に沿っている。どの節も、後ろの節が導入する前提に依存しない。
`needs a b` は「節 `a` の理解に、節 `b` が導入する前提が必要」。
適用対象は、依存関係が非巡回で、並べ替えても手順や指示語の意味が変わらない表現。 -/
def Document.OrderedByPrerequisite {g : Genre} (needs : g.Role × Wording → g.Role × Wording → Prop)
    (d : Document g) : Prop :=
  d.sections.Pairwise fun a b => ¬needs a b

/-- 前提に沿った順序付けの費用の変化。未説明の前提を補う負担と、前に戻る負担が減り、
結論を探す時間や既知の説明を読む時間が増え得る。途中から読む読者には、その開始位置の状態で評価し直す。 -/
def orderByPrerequisiteEffect : CostEffect :=
  { reduces := [.repair, .search], increases := [.search, .time] }

/-! ### 文体 -/

/-- 文体だけを変える。レイアウトを保ち、節の言葉だけを変える。 -/
def Document.SameLayout {g : Genre} (d d' : Document g) : Prop :=
  d.layout = d'.layout

/-- 語彙の展開。未知の語を、読者が知っている言葉による説明に置き換える。レイアウトは保つ。
適用対象は、語が読者の語彙にないか、意図と異なる意味で理解されている表現。説明はその文脈で語の意味と条件を保つ。
語を知っている読者には、優劣が逆転することがある（`distance_reverses`）。 -/
def lexicalExpansionEffect : CostEffect :=
  { reduces := [.lookup, .repair], increases := [.time] }

end Knowledge.Documentation
