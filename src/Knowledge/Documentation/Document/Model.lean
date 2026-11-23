import Knowledge.Documentation.Document.Style

/-! # 文書のモデル

文書は、どう並べるか（レイアウト）と、どう書くか（文体）を持ち、何かを伝える（内容）。
レイアウトは文書の種類ごとに決まる。 -/

namespace Knowledge.Documentation

/-- 文書の種類。提案書、報告書、Issue、PRなど。種類ごとに、節の役割と取るべき並びを定める。 -/
structure Genre where
  /-- 節の役割 -/
  Role : Type
  /-- 取るべきレイアウト。節の役割の並び。 -/
  layout : List Role

/-- 文書。種類と節の並びを持ち、各節は役割と文体を持つ。 -/
structure Document where
  genre : Genre
  sections : List (genre.Role × Style)

/-- レイアウト。節の役割の並び。 -/
def Document.layout (d : Document) : List d.genre.Role :=
  d.sections.map (·.1)

/-- 文体。節の言葉の並び。 -/
def Document.style (d : Document) : List Style :=
  d.sections.map (·.2)

/-- 文書が使っている語。各節の文体が使っている語を並べたもの。 -/
def Document.words (d : Document) : List Word :=
  d.style.flatMap Style.words

/-- 従う。レイアウトが、その種類の取るべきレイアウトと一致する。
読者が種類のレイアウトを知っていれば、どこに何があるかを探す負担が減る。 -/
def Document.Conforms (d : Document) : Prop :=
  d.layout = d.genre.layout

/-- 文体だけが違う。種類とレイアウトが同じで、節の言葉だけが違い得る。 -/
def Document.SameLayout (d d' : Document) : Prop :=
  d.genre = d'.genre ∧ HEq d.layout d'.layout

end Knowledge.Documentation
