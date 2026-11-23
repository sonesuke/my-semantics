import Knowledge.Documentation.Document.Model

/-! # PREP法 -/

namespace Knowledge.Documentation

/-- PREP法の節の役割 -/
inductive PrepRole where
  /-- 結論 -/
  | point
  /-- 理由 -/
  | reason
  /-- 具体例 -/
  | example

/-- PREP法。結論を先に示してから、理由と具体例で支持し、結論を繰り返す。 -/
def prep : Genre where
  Role := PrepRole
  layout := [.point, .reason, .example, .point]

end Knowledge.Documentation
