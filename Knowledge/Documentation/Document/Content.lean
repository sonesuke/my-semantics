/-! # 内容のモデル

内容は、何を伝えるか。どう並べるか（レイアウト）やどう書くか（文体）とは独立に決まる。 -/

namespace Knowledge.Documentation

/-- 事柄。結論、理由、条件、具体例など、伝えたい一つのこと。 -/
opaque Point : Type

/-- 話題。事柄が何についての話か。読む人が答えを知りたい問いにあたる。話題どうしは名前で区別する。 -/
structure Topic where
  name : String  -- 名前

/-- 内容。伝えたい事柄と、それぞれが何についての話か。 -/
structure Content where
  points : List Point     -- 伝えたい事柄
  topic : Point → Topic   -- 事柄ごとの話題

end Knowledge.Documentation
