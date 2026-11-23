import Knowledge.Documentation.Document.Model
import Knowledge.Documentation.Document.Style.Diction
import Knowledge.Documentation.Document.Style.Construction

/-! # PREP法 -/

namespace Knowledge.Documentation

/-- PREP法の節の役割 -/
inductive PrepRole where
  | point    -- 結論
  | reason   -- 理由
  | example  -- 具体例

/-- PREP法。結論を先に示してから、理由と具体例で支持し、結論を繰り返す。
結論を探す負担と、目的がわからないまま保持する負担が減り得る一方、反復の分だけ読む時間が増える。
読者が冒頭の結論を理解できる文書に向く。型に沿うこと自体を改善とはしない。結論は新しい語を導入せずに言い切り、理由は結論とのつながりを示し、具体例は具体的に書く。繰り返す結論も含めて、言い直さない。 -/
def prep : Genre where
  Role := PrepRole
  layout := Genre.fixed [.point, .reason, .example, .point]
  style
    | .point => fun s => s.Assertive ∧ s.NoNewWords
    | .reason => Style.Connective
    | .example => Style.Concrete
  styleAcross := Style.NoRephrasing

end Knowledge.Documentation
