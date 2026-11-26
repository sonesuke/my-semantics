import Knowledge.Documentation.Document.Genre.Model

/-! # PREP法 -/

namespace Knowledge.Documentation

/-- 結論。言いたいことを述べる。新しい語を導入せずに言い切る。 -/
def Prep.Role.conclusion : Role := ⟨"結論", fun s => s.sentences.Assertive ∧ s.diction.NoNewWords⟩

/-- 理由。結論を支える。結論とのつながりを示す。 -/
def Prep.Role.reason : Role := ⟨"理由", fun s => s.sentences.Connective⟩

/-- 具体例。結論を具体的な事例で示す。具体的に書く。 -/
def Prep.Role.example : Role := ⟨"具体例", fun s => s.diction.Concrete⟩

/-- PREP法。結論を先に示してから、理由と具体例で支持し、結論を繰り返す。
結論を探す負担と、目的がわからないまま保持する負担が減り得る一方、反復の分だけ読む時間が増える。
読者が冒頭の結論を理解できる文書に向く。型に沿うこと自体を改善とはしない。繰り返す結論も含めて、言い直さない。 -/
def prep : Genre where
  layout := Genre.fixed [Prep.Role.conclusion, Prep.Role.reason, Prep.Role.example, Prep.Role.conclusion]
  style ss := Diction.NoRephrasing (ss.map (·.diction))
  place := Genre.sameName

end Knowledge.Documentation
