import Knowledge.Documentation.Document.Style.Model

/-! # 内容のモデル

内容は、何を伝えるか。どう並べるか（レイアウト）やどう書くか（文体）とは独立に決まる。 -/

namespace Knowledge.Documentation

/-- 事柄。結論、理由、条件、具体例など、伝えたい一つのこと。 -/
opaque Point : Type

/-- 内容。伝えたい事柄と、事柄どうしの前提関係。 -/
structure Content where
  /-- 伝えたい事柄 -/
  points : List Point
  /-- `needs p q` は「事柄 `p` の理解に、事柄 `q` が必要」。 -/
  needs : Point → Point → Prop

/-- `s.Conveys p` は「文体 `s` で書いた節が、事柄 `p` を伝える」。言い換えで条件や留保が落ちれば伝わらない。 -/
opaque Style.Conveys : Style → Point → Prop

end Knowledge.Documentation
