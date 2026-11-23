import Knowledge.Development.Artifact.Model

/-! # Issueのモデル -/

namespace Knowledge.Development

/-- Issue -/
structure Issue where
  changeRequest : Artifact.ChangeRequest  -- 変更要件

end Knowledge.Development
