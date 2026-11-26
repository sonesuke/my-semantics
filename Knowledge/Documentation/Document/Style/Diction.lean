/-! # 言葉遣い

節全体の語の選び方。読者の語彙と照らして、知らない語を調べる負担につなぐために、文の組み立てと分けて持つ
（まだ読者の費用にはつないでいない）。 -/

namespace Knowledge.Documentation

/-- 語 -/
opaque Word : Type

/-- 同じ概念を指す。`w.Synonym w'` は「語 `w` と `w'` が同じものを指す」。 -/
opaque Word.Synonym : Word → Word → Prop

/-- 言葉遣い。節全体の語の選び方。 -/
opaque Diction : Type

/-- 使っている語。言い直しを見つけるのに使う。読者の語彙と照らして未知の語を見つけるのにも使う予定（未接続）。 -/
opaque Diction.words : Diction → List Word

/-- 新しく導入する語。その節で初めて持ち込み、意味を示す語。 -/
opaque Diction.introduces : Diction → List Word

/-- 具体的な言葉遣い。例・数値・固有の事柄を選ぶ。 -/
opaque Diction.Concrete : Diction → Prop

/-- 新しい語を導入しない。それまでに出てきた言葉だけで書く。結論や判断を求める節で、
読者がいちばん大事なところで立ち止まらないようにする。語は背景や説明の節で導入しておく。 -/
def Diction.NoNewWords (d : Diction) : Prop :=
  d.introduces = []

/-- 言い直さない。使っている語のうち、同じ概念を指す語は同じ語である。
言い直しは節をまたいで起こるので、言葉遣いの並びについての条件にする。
同じものを別の言葉で書くと、読者は別のものかと迷い、実質的に新しい語を持ち込むことになる。 -/
def Diction.NoRephrasing (ds : List Diction) : Prop :=
  ∀ w ∈ ds.flatMap Diction.words, ∀ w' ∈ ds.flatMap Diction.words, w.Synonym w' → w = w'

/-! ## 語彙の展開

未知の語を、読者が知っている言葉による説明に置き換えた言葉遣い。語を調べる負担と誤解を補う負担が減り得る一方、
読む時間が増える。説明はその文脈で語の意味と条件を保つ必要がある。語を知っている読者には、かえって遠くなる
ことがある（`Reader.distance_reverses`）。どちらがよいかは読者で決まる。読者の語彙とつないでいないので、まだ性質としては置いていない。 -/

end Knowledge.Documentation
