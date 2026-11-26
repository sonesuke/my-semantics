import Knowledge.Documentation.Document.Style.Model

/-! # 役割 -/

namespace Knowledge.Documentation

/-- 役割。節が、読む人の目的（理解する、判断する）に対して果たす働き。結論を述べる、根拠を示す、判断を求めるなど。
何についての節かは、節の事柄が持つ。役割は文書の種類とは独立に存在し、種類は役割を選んで並べる。
働きが決まれば、それにふさわしい書き方も決まるので、役割が文体を持つ。役割どうしは名前で区別する。 -/
structure Role where
  name : String          -- 名前
  style : Style → Prop   -- この働きにふさわしい文体

end Knowledge.Documentation
