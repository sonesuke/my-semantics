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

表現の中身は明かさないので、変換そのものではなく、適用対象と費用の変化を述べる。
費用の変化は「減り得る」「増え得る」成分であり、改善は定理の条件で別に示す。 -/

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

/-- 語彙の展開。未知の語を、読者が知っている言葉による説明に置き換える。
適用対象は、語が読者の語彙にないか、意図と異なる意味で理解されている表現。説明はその文脈で語の意味と条件を保つ。
語を知っている読者には、優劣が逆転することがある（`distance_reverses`）。 -/
def lexicalExpansion : CostEffect :=
  { reduces := [.lookup, .repair], increases := [.time] }

/-- PREP法。内容を結論・理由・具体例に分け、結論を先に示してから支持する構成にする。
適用対象は、そう分けられ、読者が冒頭の結論を理解できる表現。順序の変更が理由や具体例の適用範囲を変えない。
型に沿うこと自体を改善とはしない。 -/
def prep : CostEffect :=
  { reduces := [.search, .memory], increases := [.time] }

/-- 問いによるグループ化。表現をブロックに分け、同じ問いに答えるブロックを連続させて、問いを示す見出しを付ける。
適用対象は、目的を問いに分けられ、ブロックを移しても条件・参照先・実行順序を保てる表現。 -/
def groupByQuestion : CostEffect :=
  { reduces := [.search, .memory], increases := [.time, .search] }

/-- 前提に沿った順序付け。ブロックを、前提を導入するものが先に来る順に並べる。
適用対象は、依存関係が非巡回で、並べ替えても手順や指示語の意味が変わらない表現。
途中から読む読者には、その開始位置の状態で評価し直す。 -/
def orderByPrerequisite : CostEffect :=
  { reduces := [.repair, .search], increases := [.search, .time] }

end Knowledge.Documentation
