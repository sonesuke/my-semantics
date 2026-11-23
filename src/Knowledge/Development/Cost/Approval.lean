import Knowledge.Development.Justification.Deviation

/-! # 承認の費用のモデル -/

namespace Knowledge.Development

/-- 承認の費用。PR自体を読む費用と、逸脱の理由を読む費用の和。 -/
noncomputable def PullRequest.approvalCost (c : CognitiveCost) (s : Repository) (p : PullRequest) : Nat :=
  c.reading s p + ((p.deviations c s.artifact).map c.justification).sum

/-- 逸脱の理由は、それを読む費用が承認の費用に加わる。 -/
theorem PullRequest.approvalCost_of_deviation (c : CognitiveCost) (s : Repository) (p : PullRequest)
    (j : Justification) (h : j ∈ p.deviations c s.artifact) :
    c.reading s p + c.justification j ≤ p.approvalCost c s := by
  have key : ∀ l : List Justification, j ∈ l → c.justification j ≤ (l.map c.justification).sum := by
    intro l hl
    induction l with
    | nil => cases hl
    | cons x xs ih =>
      simp only [List.map_cons, List.sum_cons]
      rcases List.mem_cons.mp hl with rfl | hx
      · exact Nat.le_add_right _ _
      · exact Nat.le_trans (ih hx) (Nat.le_add_left _ _)
  exact Nat.add_le_add_left (key _ h) _

/-- 範囲を変えたPRは、承認の費用に範囲の理由を読む費用が加わる。 -/
theorem PullRequest.approvalCost_of_rescoped (c : CognitiveCost) (s : Repository) (p : PullRequest)
    (h : p.Rescoped) :
    c.reading s p + c.justification p.body.scope.justification ≤ p.approvalCost c s :=
  p.approvalCost_of_deviation c s _ (by simp [PullRequest.deviations, h])

/-- 検証を通っていないPRは、承認の費用に検証の理由を読む費用が加わる。 -/
theorem PullRequest.approvalCost_of_unverified (c : CognitiveCost) (s : Repository) (p : PullRequest)
    (h : ¬p.Verified s.artifact) :
    c.reading s p + c.justification p.body.verification.justification ≤ p.approvalCost c s :=
  p.approvalCost_of_deviation c s _ (by simp [PullRequest.deviations, h])

/-- 見積もりを超えるPRは、承認の費用に実装の理由を読む費用が加わる。 -/
theorem PullRequest.approvalCost_of_overEstimate (c : CognitiveCost) (s : Repository)
    (p : PullRequest) (h : p.OverEstimate c s.artifact) :
    c.reading s p + c.justification p.body.implementationJustification ≤ p.approvalCost c s :=
  p.approvalCost_of_deviation c s _ (by simp [PullRequest.deviations, h])

/-- ROI。分子は、PRの価値 1 と、見積もりより減った費用の `reads` 回分の和。分母は承認の費用。
価値を 1 に固定するのは、動かせると差の項を好きなだけ希薄にできるため。 -/
noncomputable def PullRequest.roi (c : CognitiveCost) (reads : Nat) (s : Repository) (p : PullRequest) : Rat :=
  let resultCost := (p.result s.artifact).ruleImplementationCost c
  ((1 : Int) + reads * ((p.body.estimate : Int) - resultCost) : Int) / (p.approvalCost c s : Rat)

end Knowledge.Development
