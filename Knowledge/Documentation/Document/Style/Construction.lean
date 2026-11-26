/-! # 文の組み立て

一つの文をどう作るか。文を頭に保持する負担（文の長さなど）につなぐために、言葉遣いと分けて持つ
（まだ読者の費用にはつないでいない）。 -/

namespace Knowledge.Documentation

/-- 文の組み立て。一つの文の長さ、構文、語順など。 -/
opaque Construction : Type

/-- 言い切る組み立て。留保を含めずに断定する。 -/
opaque Construction.Assertive : Construction → Prop

/-- つながりを示す組み立て。理由・帰結などの接続を明示する。 -/
opaque Construction.Connective : Construction → Prop

/-- 依頼する組み立て。読者にしてほしい判断や行動を求める形にする。 -/
opaque Construction.Requesting : Construction → Prop

/-- はい／いいえで答えられる組み立て -/
opaque Construction.YesNo : Construction → Prop

/-! ## 文の並び

節には文がいくつもあるので、節の性質は、文の並びについて「どの文も」か「ある文が」で書く。 -/

/-- 文の並び。節の中の文の組み立てを、文の順に並べたもの。 -/
abbrev Sentences := List Construction

/-- 言い切る。どの文も、留保なしに断定する。一文でも留保があれば、結論がぼやけるため。 -/
def Sentences.Assertive (ss : Sentences) : Prop :=
  ∀ c ∈ ss, c.Assertive

/-- つながりを示す。前の節とどう関係するか（理由・帰結など）を明示する文がある。 -/
def Sentences.Connective (ss : Sentences) : Prop :=
  ∃ c ∈ ss, c.Connective

/-- 依頼する。読者にしてほしい判断や行動を、はっきり求める文がある。 -/
def Sentences.Requesting (ss : Sentences) : Prop :=
  ∃ c ∈ ss, c.Requesting

/-- はい／いいえで答えられる。依頼する文はどれも、はい／いいえで答えられる。
何を答えればよいか分からない依頼（「ご検討ください」など）を防ぐ。 -/
def Sentences.YesNo (ss : Sentences) : Prop :=
  ∀ c ∈ ss, c.Requesting → c.YesNo

end Knowledge.Documentation
