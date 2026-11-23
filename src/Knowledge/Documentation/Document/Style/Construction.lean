import Knowledge.Documentation.Document.Style.Model

/-! # 文の組み立ての性質

文書の種類が、取るべき文体を定めるのに使う。 -/

namespace Knowledge.Documentation

/-- 言い切る組み立て。留保を含めずに断定する。 -/
opaque Construction.Assertive : Construction → Prop

/-- つながりを示す組み立て。理由・帰結などの接続を明示する。 -/
opaque Construction.Connective : Construction → Prop

/-- 依頼する組み立て。読者にしてほしい判断や行動を求める形にする。 -/
opaque Construction.Requesting : Construction → Prop

/-- はい／いいえで答えられる組み立て -/
opaque Construction.YesNo : Construction → Prop

/-- 言い切る。結論を、留保なしに断定する。 -/
def Style.Assertive (s : Style) : Prop :=
  s.construction.Assertive

/-- つながりを示す。前の節とどう関係するか（理由・帰結など）を明示する。 -/
def Style.Connective (s : Style) : Prop :=
  s.construction.Connective

/-- 依頼する。読者にしてほしい判断や行動を、はっきり求める。 -/
def Style.Requesting (s : Style) : Prop :=
  s.construction.Requesting

/-- はい／いいえで答えられる。何を答えればよいか分からない依頼（「ご検討ください」など）を防ぐ。 -/
def Style.YesNo (s : Style) : Prop :=
  s.construction.YesNo

end Knowledge.Documentation
