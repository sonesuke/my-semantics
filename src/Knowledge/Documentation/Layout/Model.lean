/-! # レイアウトのモデル

文書には、どう並べるか（レイアウト）と、どう書くか（文体）がある。レイアウトは文書の種類ごとに決まる。 -/

namespace Knowledge.Documentation

/-- 文体。節の中の言葉遣いと文の組み立て。 -/
opaque Wording : Type

/-- 文書の種類。提案書、報告書、Issue、PRなど。種類ごとに、節の役割と取るべき並びを定める。 -/
structure Genre where
  /-- 節の役割 -/
  Role : Type
  /-- 取るべきレイアウト。節の役割の並び。 -/
  layout : List Role

/-- 文書。節の並びで、各節は役割と文体を持つ。 -/
structure Document (g : Genre) where
  sections : List (g.Role × Wording)

/-- 文書のレイアウト。節の役割の並び。 -/
def Document.layout {g : Genre} (d : Document g) : List g.Role :=
  d.sections.map (·.1)

/-- 従う。文書のレイアウトが、その種類の取るべきレイアウトと一致する。
読者が種類のレイアウトを知っていれば、どこに何があるかを探す負担が減る。 -/
def Document.Conforms {g : Genre} (d : Document g) : Prop :=
  d.layout = g.layout

end Knowledge.Documentation
