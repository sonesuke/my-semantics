import Knowledge.Documentation.Document.Content
import Knowledge.Documentation.Document.Role

/-! # 節 -/

namespace Knowledge.Documentation

/-- 節。役割と、伝える事柄と、文体を持つ。 -/
structure Section where
  role : Role          -- 役割
  points : List Point  -- 伝える事柄
  style : Style        -- 文体

/-- 役割にふさわしい文体を取っている -/
def Section.Styled (s : Section) : Prop :=
  s.role.style s.style

/-- `s.Conveys p` は「節 `s` が、その書き方で事柄 `p` を伝える」。言い換えで条件や留保が落ちれば伝わらない。
伝わるかは言葉遣いと文の組み立ての両方で決まるので、文体の部品ではなく節について置く。 -/
opaque Section.Conveys : Section → Point → Prop

end Knowledge.Documentation
