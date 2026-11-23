import Knowledge.Development.Artifact.Model

/-! # Issueのモデル -/

namespace Knowledge.Development

/-- 変更要件。要求の書き換えではなく差分の条件にするのは、充足を差分についての命題にするため。 -/
structure Issue.Modification where
  /-- 受け入れる -/
  admits : Artifact.Diff → Prop

/-- Issue -/
structure Issue where
  modification : Issue.Modification

end Knowledge.Development
