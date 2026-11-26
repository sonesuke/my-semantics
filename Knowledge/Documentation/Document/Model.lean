import Knowledge.Documentation.Document.Genre.Model

/-! # 文書のモデル

文書は、内容を、種類に従って、節の並びにしたもの。節は役割と事柄と文体を持ち、種類は節の並べ方と、内容を節にする方針を決める。 -/

namespace Knowledge.Documentation

/-- 文書。内容を、種類に従って、節の並びにしたもの。
そうなっているかは、意味を保つ（`Faithful`）と、従う（`Conforms`）で確かめる。 -/
structure Document where
  content : Content       -- 内容
  genre : Genre           -- 種類
  sections : List Section  -- 節の並び（実際に書いた節）

/-- 文体。節の文体の並び。 -/
def Document.style (d : Document) : List Style :=
  d.sections.map (·.style)

/-- 従う。レイアウトと節をまたいだ文体がその種類の決まりを満たし、どの節も役割にふさわしい文体を取り、
どの事柄も、種類の方針どおり、その話題を置いてよい役割の節にある。
読者が種類のレイアウトを知っていれば、どこに何があるかを探す負担が減る。 -/
def Document.Conforms (d : Document) : Prop :=
  d.genre.layout d.sections ∧ d.genre.style d.style ∧ (∀ s ∈ d.sections, s.Styled) ∧
    ∀ s ∈ d.sections, ∀ p ∈ s.points, d.genre.place (d.content.topic p) s.role

/-- 意味を保つ。内容のどの事柄も、どこかの節で伝わり、内容にない事柄を伝える節がない。
必要な事柄の省略や、内容にないことの断定を防ぐ。 -/
def Document.Faithful (d : Document) : Prop :=
  (∀ p ∈ d.content.points, ∃ s ∈ d.sections, p ∈ s.points ∧ s.Conveys p) ∧
    ∀ s ∈ d.sections, ∀ p ∈ s.points, p ∈ d.content.points

end Knowledge.Documentation
