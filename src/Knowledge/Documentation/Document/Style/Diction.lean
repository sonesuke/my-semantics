import Knowledge.Documentation.Document.Style.Model

/-! # 言葉遣いの性質

文書の種類が、取るべき文体を定めるのに使う。 -/

namespace Knowledge.Documentation

/-- 同じ概念を指す。`w.Synonym w'` は「語 `w` と `w'` が同じものを指す」。 -/
opaque Word.Synonym : Word → Word → Prop

/-- 具体的な言葉遣い。例・数値・固有の事柄を選ぶ。 -/
opaque Diction.Concrete : Diction → Prop

/-- 具体的。例・数値・固有の事柄で書く。 -/
def Style.Concrete (s : Style) : Prop :=
  s.diction.Concrete

/-- 新しい語を導入しない。それまでに出てきた言葉だけで書く。結論や判断を求める節で、
読者がいちばん大事なところで立ち止まらないようにする。語は背景や説明の節で導入しておく。 -/
def Style.NoNewWords (s : Style) : Prop :=
  s.introduces = []

/-- 言い直さない。使っている語のうち、同じ概念を指す語は同じ語である。
言い直しは節をまたいで起こるので、文体の並びについての条件にする。
同じものを別の言葉で書くと、読者は別のものかと迷い、実質的に新しい語を持ち込むことになる。 -/
def Style.NoRephrasing (ss : List Style) : Prop :=
  ∀ w ∈ ss.flatMap Style.words, ∀ w' ∈ ss.flatMap Style.words, w.Synonym w' → w = w'

/-! ## 語彙の展開

未知の語を、読者が知っている言葉による説明に置き換えた言葉遣い。語を調べる負担と誤解を補う負担が減り得る一方、
読む時間が増える。説明はその文脈で語の意味と条件を保つ必要がある。語を知っている読者には、かえって遠くなる
ことがある（`Reader.distance_reverses`）。どちらがよいかは読者で決まるので、文書の種類が取るべき文体として選ぶ。 -/

end Knowledge.Documentation
