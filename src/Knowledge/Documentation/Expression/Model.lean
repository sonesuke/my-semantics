import Knowledge.Documentation.Layout.Model

/-! # 文章の読みやすさのモデル

読みやすい表現は、読者の知識・語彙を足場に、目的に必要な理解へ少ない負担で進める表現である。
平易さは読者と表現の関係で決まる。 -/

namespace Knowledge.Documentation

/-- 状況。説明対象について考えられる状況。 -/
opaque Situation : Type

/-- 表現。文書の種類と、その種類の文書。レイアウト（節の並び）と文体（各節の言葉）からなる。 -/
structure Expression where
  genre : Genre
  document : Document genre

/-- 読者の状態。語と概念の対応、保持する命題や事例、説明・判断・実行の能力。誤解を含む状態も扱う。 -/
opaque ReaderState : Type

/-- 目的。読後にできるようになってほしいこと。説明の再生に加え、新しい事例の判断や反例の識別を含む。 -/
opaque Purpose : Type

/-- 操作。読む、調べる、前に戻る、推論するなど。 -/
opaque Operation : Type

/-- 目的に必要な情報。必要な条件・結果・理由の組み合わせ。 -/
opaque Need : Type

/-! ## 費用 -/

/-- 費用。各成分は異なる負担で、普遍的な順位を定めない。 -/
structure Cost where
  /-- 操作時間 -/
  time : Nat
  /-- 未知の語を調べること -/
  lookup : Nat
  /-- 省略や誤解を補うこと -/
  repair : Nat
  /-- 情報を探すこと・往復すること -/
  search : Nat
  /-- 同時に保持する必要がある情報 -/
  memory : Nat

/-- 成分ごとに大きくない -/
def Cost.Le (c d : Cost) : Prop :=
  c.time ≤ d.time ∧ c.lookup ≤ d.lookup ∧ c.repair ≤ d.repair ∧ c.search ≤ d.search ∧
    c.memory ≤ d.memory

/-- 優位。重みを置かずに比べるとき、全成分で大きくなく、一つ以上で小さい。成分が競合すれば優劣を決めない。 -/
def Cost.Dominates (c d : Cost) : Prop :=
  c.Le d ∧ c ≠ d

/-- 重み。単位と測定方法を固定して、成分を一つの費用にまとめる。 -/
structure Weights where
  time : Nat
  lookup : Nat
  repair : Nat
  search : Nat
  memory : Nat
  positive : 0 < time ∧ 0 < lookup ∧ 0 < repair ∧ 0 < search ∧ 0 < memory

/-- 重み付きの費用 -/
def Cost.weighted (w : Weights) (c : Cost) : Nat :=
  w.time * c.time + w.lookup * c.lookup + w.repair * c.repair + w.search * c.search +
    w.memory * c.memory

/-- 成分ごとに大きくなければ、重み付きの費用も大きくない。 -/
theorem Cost.weighted_le (w : Weights) {c d : Cost} (h : c.Le d) : c.weighted w ≤ d.weighted w := by
  obtain ⟨ht, hl, hr, hs, hm⟩ := h
  simp only [Cost.weighted]
  have := Nat.mul_le_mul_left w.time ht
  have := Nat.mul_le_mul_left w.lookup hl
  have := Nat.mul_le_mul_left w.repair hr
  have := Nat.mul_le_mul_left w.search hs
  have := Nat.mul_le_mul_left w.memory hm
  omega

/-! ## 評価の前提 -/

/-- 評価の前提。普遍的な意味・課題・費用は定めず、評価ごとに与える。 -/
structure Premise where
  /-- 共有する前提に適合する状況 -/
  shared : Situation → Prop
  /-- 伝える内容に適合する状況 -/
  content : Situation → Prop
  content_shared : ∀ ω, content ω → shared ω
  content_nonempty : ∃ ω, content ω
  /-- 表現の意味。表現と両立する状況。評価者が定める意味で、読者の解釈とは区別する。 -/
  meaning : Expression → Situation → Prop
  meaning_shared : ∀ e ω, meaning e ω → shared ω
  /-- 目的に必要な情報を取り出す。すべての意味を保つなら、状況をそのまま返す。 -/
  need : Situation → Need
  /-- 読者の目的。有限で空でない。 -/
  purposes : List Purpose
  purposes_nonempty : purposes ≠ []
  /-- `sufficient K g` は「状態 `K` の読者が目的 `g` について十分に応答できる」。
  情報不足なら「判断できない」も十分な応答になり得る。 -/
  sufficient : ReaderState → Purpose → Prop
  /-- 読む前の読者の状態 -/
  initial : ReaderState
  /-- `step e K o K'` は「表現 `e` を閲覧条件のもとで読み、操作 `o` で状態 `K` から `K'` へ進める」。
  同じ表現から理解にも誤解にも進み得るので、関係にする。 -/
  step : Expression → ReaderState → Operation → ReaderState → Prop
  /-- 操作一回の費用。同時に保持する情報は `memory` で状態ごとに測るので、ここでは使わない。 -/
  stepCost : ReaderState → Operation → ReaderState → Cost
  /-- 状態で同時に保持する必要がある情報 -/
  memory : ReaderState → Nat
  /-- 成功確率。制限時間内の過程に、誤解や途中離脱も含めた分布を与えたとき、理解に至る確率。
  距離による比較とは分けて評価する。 -/
  successProbability : Expression → Rat

namespace Premise

variable (P : Premise)

/-! ## 意味の保持と理解 -/

/-- 意味を保つ。目的に必要な違いを、増やしも減らしもしない。必要な条件の省略や、未説明のことの断定を防ぐ。 -/
def Faithful (e : Expression) : Prop :=
  (∃ ω, P.meaning e ω) ∧
    ∀ z, (∃ ω, P.meaning e ω ∧ P.need ω = z) ↔ (∃ ω, P.content ω ∧ P.need ω = z)

/-- 理解している。すべての目的について十分に応答できる。判定は目的の範囲に限る。 -/
def Understands (K : ReaderState) : Prop :=
  ∀ g ∈ P.purposes, P.sufficient K g

/-! ## 過程 -/

/-- 過程。読む前の状態から、操作と遷移先の状態を順に並べたもの。 -/
abbrev Process := List (Operation × ReaderState)

/-- 状態 `K` から、過程が表現 `e` のもとで遷移として成り立つ。 -/
def Valid (e : Expression) : ReaderState → Process → Prop
  | _, [] => True
  | K, (o, K') :: ps => P.step e K o K' ∧ Valid e K' ps

/-- 最終状態 -/
def last : ReaderState → Process → ReaderState
  | K, [] => K
  | _, (_, K') :: ps => last K' ps

/-- 状態 `K` からの過程の費用。操作ごとの費用は足し、同時に保持する情報は最大を取る。 -/
def cost : ReaderState → Process → Cost
  | K, [] => ⟨0, 0, 0, 0, P.memory K⟩
  | K, (o, K') :: ps =>
    let c := P.stepCost K o K'
    let r := cost K' ps
    ⟨c.time + r.time, c.lookup + r.lookup, c.repair + r.repair, c.search + r.search,
      max (P.memory K) r.memory⟩

/-- 成功する。読む前の状態から遷移として成り立ち、最終状態で理解している。 -/
def Successful (e : Expression) (p : Process) : Prop :=
  P.Valid e P.initial p ∧ P.Understands (last P.initial p)

/-! ## 理解までの距離 -/

/-- 理解までの距離が `n` 以下。成功する過程のうち、重み付きの費用が `n` 以下のものがある。
距離は成功過程の費用の下限で、読者が実際に最小の過程を選ぶとは限らない。
成功過程がなければどの `n` でも成り立たず、距離は無限になる。 -/
def Within (w : Weights) (e : Expression) (n : Nat) : Prop :=
  ∃ p, P.Successful e p ∧ (P.cost P.initial p).weighted w ≤ n

/-- 理解できる経路がある。距離が有限である。 -/
def Reachable (w : Weights) (e : Expression) : Prop :=
  ∃ n, P.Within w e n

/-- 距離が大きくない。`e₁` の距離は `e₂` の距離以下である。 -/
def DistanceLe (w : Weights) (e₁ e₂ : Expression) : Prop :=
  ∀ n, P.Within w e₂ n → P.Within w e₁ n

/-- 距離が小さい。`e₁` の距離は `e₂` の距離より小さい。 -/
def DistanceLt (w : Weights) (e₁ e₂ : Expression) : Prop :=
  ∃ n, P.Within w e₁ n ∧ ¬P.Within w e₂ n

/-- 優先する。同じ前提と重みのもとで、どちらも意味を保ち、`e₁` の方が理解までの距離が小さい。 -/
def Prefers (w : Weights) (e₁ e₂ : Expression) : Prop :=
  P.Faithful e₁ ∧ P.Faithful e₂ ∧ P.DistanceLt w e₁ e₂

end Premise

end Knowledge.Documentation
