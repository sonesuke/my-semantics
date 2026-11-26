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
  vocabulary : Vocabulary  -- 語と概念の対応
  beliefs : Beliefs        -- 覚えている命題や事例
  abilities : Abilities    -- 説明・判断・実行の能力

/-- 目的。読後にできるようになってほしいこと。説明の再生に加え、新しい事例の判断や反例の識別を含む。 -/
opaque Purpose : Type

/-- `g.Needs t` は「目的 `g` を果たすには、話題 `t` について答えが要る」。
話題は読む人が答えを知りたい問いなので、どの問いに答えが要るかは目的が決める。 -/
opaque Purpose.Needs : Purpose → Topic → Prop

/-- 操作。読む、調べる、前に戻る、推論するなど。 -/
opaque Operation : Type

/-! ## 読者 -/

/-- 読者。目的、読む前の頭の中、閲覧条件のもとでの読み進め方と、その費用を持つ。
費用は、時間・語を調べる・誤解を補う・情報を探す・同時に保持するなどの負担を、一つの物差しで測ったもの。
十分な応答には、情報不足のときの「判断できない」も含み得る。同じ文書から理解にも誤解にも進み得るので、
読み進め方は関係にする。成功確率は、誤解や途中離脱も含めた分布のもとで理解に至る確率で、距離とは分けて評価する。 -/
structure Reader where
  purposes : List Purpose                           -- 目的
  purposes_nonempty : purposes ≠ []                 -- 目的は空でない
  sufficient : Mind → Purpose → Prop                -- sufficient K g：頭の中が K のとき、目的 g に十分に応答できる
  initial : Mind                                    -- 読む前の頭の中
  step : Document → Mind → Operation → Mind → Prop  -- step e K o K'：文書 e を読み、操作 o で頭の中が K から K' に変わる
  stepCost : Mind → Operation → Mind → Nat          -- 操作一回の費用
  expects : Genre → Prop                            -- 知っている文書の種類
  surprise : Nat                                    -- 知っている種類に従わない文書を読むときの費用
  successProbability : Document → Rat               -- 成功確率

namespace Reader

variable (R : Reader)

/-- 理解している。すべての目的について十分に応答できる。判定は目的の範囲に限る。 -/
def Understands (K : Mind) : Prop :=
  ∀ g ∈ R.purposes, R.sufficient K g

/-- 内容が目的に足りる。読者のどの目的についても、それが求める話題の事柄が内容にある。
求める話題の事柄がなければ、どう並べてどう書いても、その目的は果たせない。 -/
def Serves (c : Content) : Prop :=
  ∀ g ∈ R.purposes, ∀ t, g.Needs t → ∃ p ∈ c.points, c.topic p = t

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
/-- 期待からの逸脱の費用。知っている種類の文書を読むとき、種類に従っていなければかかる。知らない種類なら期待がないのでかからない。 -/
noncomputable def genreCost (e : Document) : Nat :=
  if R.expects e.genre ∧ ¬e.Conforms then R.surprise else 0

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
