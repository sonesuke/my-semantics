import Knowledge.Documentation.Document.Model

/-! # 提案書 -/

namespace Knowledge.Documentation

/-- 提案書の節の役割 -/
inductive ProposalRole where
  /-- 背景 -/
  | background
  /-- 課題 -/
  | problem
  /-- 提案 -/
  | proposal
  /-- 効果 -/
  | effect
  /-- 費用 -/
  | cost
  /-- 判断してほしいこと -/
  | decision

/-- 提案書。背景と課題を示してから提案し、効果と費用を比べたうえで、判断してほしいことを示す。 -/
def proposal : Genre where
  Role := ProposalRole
  layout := [.background, .problem, .proposal, .effect, .cost, .decision]

end Knowledge.Documentation
