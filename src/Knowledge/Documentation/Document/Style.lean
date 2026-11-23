/-! # 文体のモデル

文体は、文書がどう書かれているか。どう並べるか（レイアウト）とは別に、各節が持つ。 -/

namespace Knowledge.Documentation

/-- 語 -/
opaque Word : Type

/-- 言葉遣い。語の選び方。 -/
opaque Diction : Type

/-- 使っている語。読者の語彙と照らして、未知の語を見つけるために取り出す。 -/
opaque Diction.words : Diction → List Word

/-- 文の組み立て。文の長さ、構文、語順など。 -/
opaque Construction : Type

/-- 文体。言葉遣いと文の組み立て。 -/
structure Style where
  diction : Diction
  construction : Construction

/-- 文体が使っている語 -/
def Style.words (s : Style) : List Word :=
  s.diction.words

end Knowledge.Documentation
