import Knowledge.Development.Artifact.Model

/-! # Issueのモデル -/

namespace Knowledge.Development

/-- Issue -/
structure Issue where
  changeRequest : Artifact.ChangeRequest

end Knowledge.Development
