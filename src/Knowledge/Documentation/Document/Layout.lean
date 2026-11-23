import Knowledge.Documentation.Document.Model

/-! # レイアウトの条件

節の並びについての条件。どれも文書が持つ性質で、読者にどう効くかは読みやすさの側で扱う。 -/

namespace Knowledge.Documentation

/-- まとまっている。同じ鍵を持つ要素が連続している。後ろに同じ鍵があれば、すぐ次の要素も同じ鍵を持つ。 -/
def Grouped {α β : Type} (key : α → β) : List α → Prop
  | [] => True
  | [_] => True
  | a :: b :: l => (key a ∈ (b :: l).map key → key b = key a) ∧ Grouped key (b :: l)

/-- 検算。`[1, 1, 2]` はまとまっている。 -/
example : Grouped id [1, 1, 2] := by simp [Grouped]

/-- 検算。`[1, 2, 1]` はまとまっていない。 -/
example : ¬Grouped id [1, 2, 1] := by simp [Grouped]

/-- 問いごとにまとまっている。各節が答える主な問い `question` ごとに、節が連続している。 -/
def Document.GroupedByQuestion {Question : Type} (d : Document)
    (question : d.genre.Role × Style → Question) : Prop :=
  Grouped question d.sections

/-- 前提に沿っている。どの節も、後ろの節が導入する前提に依存しない。
`needs a b` は「節 `a` の理解に、節 `b` が導入する前提が必要」。 -/
def Document.OrderedByPrerequisite (d : Document)
    (needs : d.genre.Role × Style → d.genre.Role × Style → Prop) : Prop :=
  d.sections.Pairwise fun a b => ¬needs a b

end Knowledge.Documentation
