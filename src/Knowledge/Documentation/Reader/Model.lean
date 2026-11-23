import Knowledge.Documentation.Document.Model

/-! # 読者のモデル

平易さは読者と文書の関係で決まる。専門家には専門用語が近く、初心者には具体的な動作や身近な例が近いことがある。 -/

namespace Knowledge.Documentation

/-- 語彙。語と概念の対応。 -/
opaque Vocabulary : Type

/-- 保持する命題や事例 -/
opaque Beliefs : Type

/-- 説明・判断・実行の能力 -/
opaque Abilities : Type

/-- 読者の頭の中。読み進めるにつれて変わる。誤解を含む状態も扱う。 -/
structure Mind where
  vocabulary : Vocabulary
  beliefs : Beliefs
  abilities : Abilities

/-- 目的。読後にできるようになってほしいこと。説明の再生に加え、新しい事例の判断や反例の識別を含む。 -/
opaque Purpose : Type

/-- 操作。読む、調べる、前に戻る、推論するなど。 -/
opaque Operation : Type

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

/-! ## 読者 -/

/-- 読者。目的、読む前の頭の中、閲覧条件のもとでの読み進め方と、その費用を持つ。 -/
structure Reader where
  /-- 目的。有限で空でない。 -/
  purposes : List Purpose
  purposes_nonempty : purposes ≠ []
  /-- `sufficient K g` は「頭の中が `K` のとき、目的 `g` について十分に応答できる」。
  情報不足なら「判断できない」も十分な応答になり得る。 -/
  sufficient : Mind → Purpose → Prop
  /-- 読む前の頭の中 -/
  initial : Mind
  /-- `step e K o K'` は「文書 `e` を閲覧条件のもとで読み、操作 `o` で頭の中が `K` から `K'` に変わる」。
  同じ文書から理解にも誤解にも進み得るので、関係にする。 -/
  step : Document → Mind → Operation → Mind → Prop
  /-- 操作一回の費用。同時に保持する情報は `memory` で頭の中ごとに測るので、ここでは使わない。 -/
  stepCost : Mind → Operation → Mind → Cost
  /-- 頭の中で同時に保持する必要がある情報 -/
  memory : Mind → Nat
  /-- 成功確率。制限時間内の過程に、誤解や途中離脱も含めた分布を与えたとき、理解に至る確率。
  距離による比較とは分けて評価する。 -/
  successProbability : Document → Rat

namespace Reader

variable (R : Reader)

/-- 理解している。すべての目的について十分に応答できる。判定は目的の範囲に限る。 -/
def Understands (K : Mind) : Prop :=
  ∀ g ∈ R.purposes, R.sufficient K g

/-! ## 過程 -/

/-- 過程。読む前の頭の中から、操作と変わった後の頭の中を順に並べたもの。 -/
abbrev Process := List (Operation × Mind)

/-- 頭の中が `K` のときから、過程が文書 `e` のもとで読み進め方として成り立つ。 -/
def Valid (e : Document) : Mind → Process → Prop
  | _, [] => True
  | K, (o, K') :: ps => R.step e K o K' ∧ Valid e K' ps

/-- 最後の頭の中 -/
def last : Mind → Process → Mind
  | K, [] => K
  | _, (_, K') :: ps => last K' ps

/-- 頭の中が `K` のときからの過程の費用。操作ごとの費用は足し、同時に保持する情報は最大を取る。 -/
def cost : Mind → Process → Cost
  | K, [] => ⟨0, 0, 0, 0, R.memory K⟩
  | K, (o, K') :: ps =>
    let c := R.stepCost K o K'
    let r := cost K' ps
    ⟨c.time + r.time, c.lookup + r.lookup, c.repair + r.repair, c.search + r.search,
      max (R.memory K) r.memory⟩

/-- 成功する。読む前の頭の中から読み進め方として成り立ち、最後に理解している。 -/
def Successful (e : Document) (p : Process) : Prop :=
  R.Valid e R.initial p ∧ R.Understands (last R.initial p)

/-! ## 理解までの距離 -/

/-- 理解までの距離が `n` 以下。成功する過程のうち、重み付きの費用が `n` 以下のものがある。
距離は成功過程の費用の下限で、読者が実際に最小の過程を選ぶとは限らない。
成功過程がなければどの `n` でも成り立たず、距離は無限になる。 -/
def Within (w : Weights) (e : Document) (n : Nat) : Prop :=
  ∃ p, R.Successful e p ∧ (R.cost R.initial p).weighted w ≤ n

/-- 理解できる経路がある。距離が有限である。 -/
def Reachable (w : Weights) (e : Document) : Prop :=
  ∃ n, R.Within w e n

/-- 距離が大きくない。`e₁` の距離は `e₂` の距離以下である。 -/
def DistanceLe (w : Weights) (e₁ e₂ : Document) : Prop :=
  ∀ n, R.Within w e₂ n → R.Within w e₁ n

/-- 距離が小さい。`e₁` の距離は `e₂` の距離より小さい。 -/
def DistanceLt (w : Weights) (e₁ e₂ : Document) : Prop :=
  ∃ n, R.Within w e₁ n ∧ ¬R.Within w e₂ n

end Reader

end Knowledge.Documentation
