import Knowledge.Development.Justification.Deviation

/-! # 承認の費用のモデル -/

namespace Knowledge.Development

/-- 承認の費用。PR自体を読む費用と、逸脱の理由を読む費用の和。 -/
noncomputable def PullRequest.approvalCost (c : CognitiveCost) (s : Repository) (p : PullRequest) : Nat :=
  c.reading s p + ((p.deviations c).map c.justification).sum

/-- 逸脱の理由は、それを読む費用が承認の費用に加わる。 -/
theorem PullRequest.approvalCost_of_deviation (c : CognitiveCost) (s : Repository) (p : PullRequest)
    (j : Justification) (h : j ∈ p.deviations c) :
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

/-- 範囲を変えたPRは、承認の費用に範囲を変えた理由を読む費用が加わる。 -/
theorem PullRequest.approvalCost_of_rescoped (c : CognitiveCost) (s : Repository) (p : PullRequest)
    (cr : Artifact.ChangeRequest) (j : Justification) (h : p.body.scope = .rescoped cr j) :
    c.reading s p + c.justification j ≤ p.approvalCost c s :=
  p.approvalCost_of_deviation c s _
    (by simp [PullRequest.deviations, PullRequest.Scope.justifications, h])

/-- 確かめない部分があるPRは、承認の費用にその理由を読む費用が加わる。 -/
theorem PullRequest.approvalCost_of_uncovered (c : CognitiveCost) (s : Repository) (p : PullRequest)
    (j : Justification) (h : j ∈ p.body.verification.uncovered) :
    c.reading s p + c.justification j ≤ p.approvalCost c s :=
  p.approvalCost_of_deviation c s _ (by simp [PullRequest.deviations, h])

/-- 見積もりを超えるPRは、承認の費用に実装の理由を読む費用が加わる。 -/
theorem PullRequest.approvalCost_of_overEstimate (c : CognitiveCost) (s : Repository)
    (p : PullRequest) (h : p.OverEstimate c) :
    c.reading s p + c.justification p.body.implementationJustification ≤ p.approvalCost c s :=
  p.approvalCost_of_deviation c s _ (by simp [PullRequest.deviations, h])

/-- ROI。分子は、PRの価値 1 と、見積もりより減った費用の `reads` 回分の和。分母は承認の費用。
価値を 1 に固定するのは、動かせると差の項を好きなだけ希薄にできるため。 -/
noncomputable def PullRequest.roi (c : CognitiveCost) (reads : Nat) (s : Repository) (p : PullRequest) : Rat :=
  let resultCost := p.result.ruleImplementationCost c
  ((1 : Int) + reads * ((p.body.estimate : Int) - resultCost) : Int) / (p.approvalCost c s : Rat)

/-- 承認の費用は正である。 -/
theorem PullRequest.approvalCost_pos (c : CognitiveCost) (s : Repository) (p : PullRequest) :
    0 < p.approvalCost c s :=
  Nat.lt_of_lt_of_le (c.reading_positive s p) (Nat.le_add_right _ _)

/-- 見積もりを超えないPRは、ROIが正になる。 -/
theorem PullRequest.roi_pos (c : CognitiveCost) (reads : Nat) (s : Repository) (p : PullRequest)
    (h : ¬p.OverEstimate c) : 0 < p.roi c reads s := by
  have hle : p.result.ruleImplementationCost c ≤ p.body.estimate := Nat.not_lt.mp h
  have hnum : (0 : Int) < 1 + reads * ((p.body.estimate : Int) - p.result.ruleImplementationCost c) := by
    have : (0 : Int) ≤ (p.body.estimate : Int) - p.result.ruleImplementationCost c := by omega
    have := Int.mul_nonneg (Int.natCast_nonneg reads) this
    omega
  have hden : (0 : Rat) < (p.approvalCost c s : Rat) := by
    exact_mod_cast p.approvalCost_pos c s
  simp only [PullRequest.roi]
  rw [Rat.lt_div_iff hden, Rat.zero_mul]
  exact_mod_cast hnum

end Knowledge.Development
