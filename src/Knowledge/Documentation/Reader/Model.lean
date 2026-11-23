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

/-! ## 読者 -/

/-- 読者。目的、読む前の頭の中、閲覧条件のもとでの読み進め方と、その費用を持つ。
費用は、時間・語を調べる・誤解を補う・情報を探す・同時に保持するなどの負担を、一つの物差しで測ったもの。 -/
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
  /-- 操作一回の費用 -/
  stepCost : Mind → Operation → Mind → Nat
  /-- 知っている文書の種類。知っている種類には、そのレイアウトと文体を期待して読む。 -/
  expects : Genre → Prop
  /-- 期待からの逸脱一つあたりの費用 -/
  surprise : Nat
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

/-- 頭の中が `K` のときからの過程の費用。操作ごとの費用の和。 -/
def cost : Mind → Process → Nat
  | _, [] => 0
  | K, (o, K') :: ps => R.stepCost K o K' + cost K' ps

open Classical in
/-- 期待からの逸脱の費用。知っている種類の文書を読むとき、逸脱の数だけかかる。知らない種類なら期待がないのでかからない。 -/
noncomputable def genreCost (e : Document) : Nat :=
  if R.expects e.genre then R.surprise * e.deviationCount else 0

/-- 読む費用。読む過程の費用に、期待からの逸脱の費用を加えたもの。 -/
noncomputable def totalCost (e : Document) (p : Process) : Nat :=
  R.cost R.initial p + R.genreCost e

/-- 成功する。読む前の頭の中から読み進め方として成り立ち、最後に理解している。 -/
def Successful (e : Document) (p : Process) : Prop :=
  R.Valid e R.initial p ∧ R.Understands (last R.initial p)

/-! ## 理解までの距離 -/

/-- 理解までの距離が `n` 以下。成功する過程のうち、読む費用が `n` 以下のものがある。
距離は成功過程の費用の下限で、読者が実際に最小の過程を選ぶとは限らない。
成功過程がなければどの `n` でも成り立たず、距離は無限になる。 -/
def Within (e : Document) (n : Nat) : Prop :=
  ∃ p, R.Successful e p ∧ R.totalCost e p ≤ n

/-- 理解できる経路がある。距離が有限である。 -/
def Reachable (e : Document) : Prop :=
  ∃ n, R.Within e n

/-- 距離が大きくない。`e₁` の距離は `e₂` の距離以下である。 -/
def DistanceLe (e₁ e₂ : Document) : Prop :=
  ∀ n, R.Within e₂ n → R.Within e₁ n

/-- 距離が小さい。`e₁` の距離は `e₂` の距離より小さい。 -/
def DistanceLt (e₁ e₂ : Document) : Prop :=
  ∃ n, R.Within e₁ n ∧ ¬R.Within e₂ n

/-- 優先する。内容が同じで、どちらも意味を保ち、読者 `R` にとって `d₁` の方が理解までの距離が小さい。 -/
def Prefers (d₁ d₂ : Document) : Prop :=
  d₁.content = d₂.content ∧ d₁.Faithful ∧ d₂.Faithful ∧ R.DistanceLt d₁ d₂

end Reader

end Knowledge.Documentation
