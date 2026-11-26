import Knowledge.Documentation.Document.Style.Diction
import Knowledge.Documentation.Document.Style.Construction

/-! # 文体のモデル

文体は、節がどう書かれているか。節全体の言葉遣い（どの語を選ぶか）と、文の並び（文ごとの組み立て）からなる。
文体の性質は、それぞれ言葉遣いと文の組み立ての側に置き、文体はその二つを組にするだけにする。 -/

namespace Knowledge.Documentation

/-- 文体。節全体の言葉遣いと、文の並び。言葉遣いの性質（具体的、新しい語を導入しない）は節全体で見るので
一つにし、組み立ては文ごとに違うので文の数だけ持つ。 -/
structure Style where
  diction : Diction       -- 言葉遣い：節全体の語の選び方
  sentences : Sentences   -- 文の並び：文ごとの組み立て

end Knowledge.Documentation
