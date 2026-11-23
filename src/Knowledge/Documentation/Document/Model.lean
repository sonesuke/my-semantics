import Knowledge.Documentation.Document.Content

/-! # 文書のモデル

文書は、内容にレイアウトと文体を当てたもの。レイアウトは事柄を節に割り当てて並べ、文体は各節をどう書くかを決める。 -/

namespace Knowledge.Documentation

/-- 文書の種類。提案書、報告書、Issue、PRなど。節の役割と、取るべきレイアウトを定める。
よいレイアウトは種類によって違うので、種類が持つ。 -/
structure Genre where
  /-- 節の役割 -/
  Role : Type
  /-- 取るべきレイアウト。節の役割の並びが満たすべき条件。 -/
  layout : List Role → Prop

/-- 決まった並びのレイアウト。節の役割の並びが `roles` と一致する。 -/
def Genre.fixed {Role : Type} (roles : List Role) : List Role → Prop :=
  (· = roles)

/-- 節。役割と、伝える事柄と、文体を持つ。 -/
structure Section (g : Genre) where
  role : g.Role
  points : List Point
  style : Style

/-- 文書。内容と種類と、節の並び。 -/
structure Document where
  content : Content
  genre : Genre
  sections : List (Section genre)

/-- レイアウト。節の役割の並び。 -/
def Document.layout (d : Document) : List d.genre.Role :=
  d.sections.map (·.role)

/-- 文体。節の文体の並び。 -/
def Document.style (d : Document) : List Style :=
  d.sections.map (·.style)

/-- 文書が使っている語。各節の文体が使っている語を並べたもの。 -/
def Document.words (d : Document) : List Word :=
  d.style.flatMap Style.words

/-- 従う。レイアウトが、その種類の取るべきレイアウトを満たす。
読者が種類のレイアウトを知っていれば、どこに何があるかを探す負担が減る。 -/
def Document.Conforms (d : Document) : Prop :=
  d.genre.layout d.layout

/-- 意味を保つ。内容のどの事柄も、どこかの節で文体によって伝わり、内容にない事柄を伝える節がない。
必要な事柄の省略や、内容にないことの断定を防ぐ。 -/
def Document.Faithful (d : Document) : Prop :=
  (∀ p ∈ d.content.points, ∃ s ∈ d.sections, p ∈ s.points ∧ s.style.Conveys p) ∧
    ∀ s ∈ d.sections, ∀ p ∈ s.points, p ∈ d.content.points

end Knowledge.Documentation
