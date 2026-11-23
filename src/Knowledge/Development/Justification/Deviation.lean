import Knowledge.Development.Cost.Model

/-! # 逸脱のモデル

PRの理由は、既定路線との差を正当化する。 -/

namespace Knowledge.Development

/-- 既定路線。作った時点の成果物にIssueの変更要件をそのまま当て、実装が最小である成果物 `b`。 -/
def PullRequest.DefaultMinimalImplementation (c : CognitiveCost) (p : PullRequest) (b : Artifact) :
    Prop :=
  b.requirements = p.issue.changeRequest.requirements p.base.requirements ∧
    b.behaviors = p.issue.changeRequest.behaviors p.base.behaviors ∧
    b.rules = p.issue.changeRequest.rules p.base.rules ∧
    b.MinimalImplementation c

/-- 見積もりが正確。既定路線の成果物があり、その費用が見積もりと一致する。承認では、これを判断する。 -/
def PullRequest.EstimateAccurate (c : CognitiveCost) (p : PullRequest) : Prop :=
  ∃ b, p.DefaultMinimalImplementation c b ∧ b.ruleImplementationCost c = p.body.estimate

/-- 見積もりを超える。結果のルールと実装の費用が、既定路線の見積もりより大きい。 -/
def PullRequest.OverEstimate (c : CognitiveCost) (p : PullRequest) : Prop :=
  p.body.estimate < p.result.ruleImplementationCost c

/-- 範囲を変えた理由。変えていなければない。 -/
def PullRequest.Scope.justifications : PullRequest.Scope → List Justification
  | .asIssued => []
  | .rescoped _ j => [j]

/-- 見積もりが正確で見積もりを超えないPRは、既定路線より費用が大きくならない。
範囲を変えていれば、既定路線より小さくなることもある。 -/
theorem PullRequest.cost_le_default (c : CognitiveCost) (p : PullRequest)
    (hacc : p.EstimateAccurate c) (hover : ¬p.OverEstimate c) :
    ∀ b, p.DefaultMinimalImplementation c b →
      p.result.ruleImplementationCost c ≤ b.ruleImplementationCost c := by
  intro b hb
  obtain ⟨b', hb', heq⟩ := hacc
  obtain ⟨hr, hbe, hru, hm⟩ := hb
  obtain ⟨hr', hbe', hru', hm'⟩ := hb'
  have hrules : b'.rules = b.rules := hru'.trans hru.symm
  have himpl : Implementation.cost c b'.rules b'.implementations ≤
      Implementation.cost c b.rules b.implementations :=
    hm'.2.2 b (hr.trans hr'.symm) (hbe.trans hbe'.symm) (hru.trans hru'.symm) hm.1 hm.2.1
  have hle : b'.ruleImplementationCost c ≤ b.ruleImplementationCost c := by
    simp only [Artifact.ruleImplementationCost]
    rw [hrules] at himpl ⊢
    exact Nat.add_le_add_left himpl _
  calc p.result.ruleImplementationCost c ≤ p.body.estimate := Nat.not_lt.mp hover
    _ = b'.ruleImplementationCost c := heq.symm
    _ ≤ b.ruleImplementationCost c := hle

/-- 最後にマージしたPRの結果が、今の成果物である。 -/
theorem Artifact.mergeAll_append_singleton (a : Artifact) (ps : List PullRequest.Approved)
    (p : PullRequest.Approved) : a.mergeAll (ps ++ [p]) = p.1.result := by
  induction ps generalizing a with
  | nil => rfl
  | cons q qs ih => exact ih q.1.result

/-- マージしたどのPRも見積もりが正確で見積もりを超えなければ、どの時点でも、その時点の成果物の費用は、
直前にマージしたPRの既定路線より大きくならない。リポジトリはPRの積み重ねなので、常に保たれる。 -/
theorem Repository.cost_le_default (c : CognitiveCost) (s : Repository)
    (h : ∀ p ∈ s.merged, p.1.EstimateAccurate c ∧ ¬p.1.OverEstimate c) :
    ∀ ps p qs, s.merged = ps ++ p :: qs →
      ∀ b, p.1.DefaultMinimalImplementation c b →
        (s.initial.mergeAll (ps ++ [p])).ruleImplementationCost c ≤ b.ruleImplementationCost c := by
  intro ps p qs hs b hb
  rw [Artifact.mergeAll_append_singleton]
  have hp : p ∈ s.merged := by rw [hs]; simp
  exact p.1.cost_le_default c (h p hp).1 (h p hp).2 b hb

open Classical in
/-- 逸脱。既定路線との差のうち、承認で理由を読まなければならないもの。 -/
noncomputable def PullRequest.deviations (c : CognitiveCost) (p : PullRequest) : List Justification :=
  p.body.scope.justifications ++
    p.body.verification.uncovered ++
    (if p.OverEstimate c then [p.body.implementationJustification] else [])

end Knowledge.Development
