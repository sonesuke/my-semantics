import Knowledge.Documentation.Document.Model

/-! # レイアウトの条件

節の並びについての条件。どれも文書が持つ性質で、文書の種類が取るべきレイアウトとして使う。 -/

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

/-- 役割ごとにまとまっている。同じ役割の節が連続している。役割を問いにすれば、問いごとのまとまりになる。
離れた指示を拾う負担と保持する負担が減り得る一方、見出しや補足、複数のまとまりの往復が増え得る。
節を移しても条件・参照先・実行順序を保てる文書に向く。 -/
def Document.GroupedByRole (d : Document) : Prop :=
  Grouped (·.role) d.sections

/-- 前提に沿っている。どの節の事柄も、後ろの節の事柄を前提にしない。
未説明の前提を補う負担と、前に戻る負担が減り得る一方、結論を探す時間や既知の説明を読む時間が増え得る。
途中から読む読者には、その開始位置の頭の中で評価し直す。 -/
def Document.OrderedByPrerequisite (d : Document) : Prop :=
  d.sections.Pairwise fun a b => ∀ p ∈ a.points, ∀ q ∈ b.points, ¬d.content.needs p q

/-- 文体だけが違う。内容と種類が同じで、節の役割と事柄の割り当ても同じ。 -/
def Document.SameLayout (d d' : Document) : Prop :=
  d.content = d'.content ∧ d.genre = d'.genre ∧
    HEq (d.sections.map fun s => (s.role, s.points)) (d'.sections.map fun s => (s.role, s.points))

end Knowledge.Documentation
