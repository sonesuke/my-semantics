import Knowledge.Documentation.Document.Model

/-! # 内容のモデル

文書が何を伝えるか。読者は関わらない。意味は評価者が定め、読者の解釈とは区別する。 -/

namespace Knowledge.Documentation

/-- 状況。説明対象について考えられる状況。 -/
opaque Situation : Type

/-- 目的に必要な情報。必要な条件・結果・理由の組み合わせ。 -/
opaque Need : Type

/-- 伝える内容。伝えたいことと、文書の意味を与える。普遍的な意味は定めず、評価ごとに与える。 -/
structure Content where
  /-- 共有する前提に適合する状況 -/
  shared : Situation → Prop
  /-- 伝えたいことに適合する状況 -/
  intended : Situation → Prop
  intended_shared : ∀ ω, intended ω → shared ω
  intended_nonempty : ∃ ω, intended ω
  /-- 文書の意味。文書と両立する状況。 -/
  meaning : Document → Situation → Prop
  meaning_shared : ∀ d ω, meaning d ω → shared ω
  /-- 目的に必要な情報を取り出す。すべての意味を保つなら、状況をそのまま返す。 -/
  need : Situation → Need

/-- 意味を保つ。目的に必要な違いを、増やしも減らしもしない。必要な条件の省略や、未説明のことの断定を防ぐ。 -/
def Content.Faithful (C : Content) (d : Document) : Prop :=
  (∃ ω, C.meaning d ω) ∧
    ∀ z, (∃ ω, C.meaning d ω ∧ C.need ω = z) ↔ (∃ ω, C.intended ω ∧ C.need ω = z)

end Knowledge.Documentation
