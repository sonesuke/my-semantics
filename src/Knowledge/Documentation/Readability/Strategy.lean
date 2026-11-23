import Knowledge.Documentation.Readability.Model
import Knowledge.Documentation.Document.Layout
import Knowledge.Documentation.Document.Genre.Prep

/-! # 文書の最適化戦略

内容を固定したまま、レイアウトか文体を変えて、理解までの費用を減らす文書を探す。 -/

namespace Knowledge.Documentation

/-- 戦略。変換の適用対象と、文書から有限個の変換候補を作る方法。 -/
structure Strategy where
  /-- 適用対象 -/
  domain : Document → Prop
  /-- 変換候補 -/
  candidates : Document → List Document

namespace Strategy

variable (R : Reader) (w : Weights) (S : Strategy)

/-- 採用できる。入力か変換候補のうち、内容が同じで、意味を保ち、理解できる経路があり、成功確率が下がらないもの。
入力そのものも含めるので、改善がなければ入力を残せる。 -/
def Feasible (e x : Document) : Prop :=
  (x = e ∨ x ∈ S.candidates e) ∧ x.content = e.content ∧ x.Faithful ∧ R.Reachable w x ∧
    R.successProbability e ≤ R.successProbability x

/-- 選ぶ。採用できるもののうち、理解までの距離が最小のものを選ぶ。入力も最小なら入力を選ぶ。
候補の生成と改善の成立は別で、距離や確率を評価できなければ、選べるとまでは判定しない。 -/
def Chooses (e x : Document) : Prop :=
  S.Feasible R w e x ∧ (∀ y, S.Feasible R w e y → R.DistanceLe w x y) ∧
    ((∀ y, S.Feasible R w e y → R.DistanceLe w e y) → x = e)

/-- 入力が採用できるなら、選んだ文書は入力より理解までの距離が大きくない。 -/
theorem distanceLe_of_chooses (e x : Document) (he : S.Feasible R w e e) (h : S.Chooses R w e x) :
    R.DistanceLe w x e :=
  h.2.1 e he

end Strategy

/-! ## 具体的な戦略

レイアウトを変える戦略と、文体を変える戦略に分ける。変えた後の文書が持つ性質は文書の側で定め、
ここでは読者にとっての費用の変化を述べる。費用の変化は「減り得る」「増え得る」成分であり、改善は定理の条件で別に示す。 -/

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

/-! ### レイアウトを変える戦略

レイアウトを変える戦略は、文書をその種類のレイアウトに従わせること（`Document.Conforms`）。
どの並びがよいかは種類が決めるので、ここでは種類が取り得るレイアウトごとの費用の変化を述べる。 -/

/-- PREP法（`prep`）に従わせる（`Document.Conforms`）。結論を探す負担と、目的がわからないまま保持する負担が減り、
反復の分だけ読む時間が増える。適用対象は、結論・理由・具体例に分けられ、読者が冒頭の結論を理解できる文書。
型に沿うこと自体を改善とはしない。 -/
def prepEffect : CostEffect :=
  { reduces := [.search, .memory], increases := [.time] }

/-- 問いごとにまとめる（`Document.GroupedByRole`、役割を問いにする）。離れた指示を拾う負担と保持する負担が減り、
見出しや補足、複数のまとまりの往復が増える。適用対象は、目的を問いに分けられ、
節を移しても条件・参照先・実行順序を保てる文書。 -/
def groupByQuestionEffect : CostEffect :=
  { reduces := [.search, .memory], increases := [.time, .search] }

/-- 前提に沿って並べる（`Document.OrderedByPrerequisite`）。未説明の前提を補う負担と、前に戻る負担が減り、
結論を探す時間や既知の説明を読む時間が増え得る。適用対象は、依存関係が非巡回で、
並べ替えても手順や指示語の意味が変わらない文書。途中から読む読者には、その開始位置の頭の中で評価し直す。 -/
def orderByPrerequisiteEffect : CostEffect :=
  { reduces := [.repair, .search], increases := [.search, .time] }

/-! ### 文体を変える戦略 -/

/-- 語彙の展開。レイアウトを保ったまま（`Document.SameLayout`）、未知の語を、読者が知っている言葉による
説明に置き換える。語を調べる負担と誤解を補う負担が減り、読む時間が増える。
適用対象は、語が読者の語彙にないか、意図と異なる意味で理解されている文書。説明はその文脈で語の意味と条件を保つ。
語を知っている読者には、優劣が逆転することがある（`distance_reverses`）。 -/
def lexicalExpansionEffect : CostEffect :=
  { reduces := [.lookup, .repair], increases := [.time] }

end Knowledge.Documentation
