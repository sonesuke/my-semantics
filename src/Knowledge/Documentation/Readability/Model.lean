import Knowledge.Documentation.Reader.Theorems

/-! # 読みやすさのモデル

読みやすい文書は、内容の意味を保ったまま、読者が目的に必要な理解へ少ない負担で進める文書である。
内容を固定して、レイアウトと文体の当て方を比べる。 -/

namespace Knowledge.Documentation

/-- 優先する。内容が同じで、どちらも意味を保ち、読者 `R` にとって `d₁` の方が理解までの距離が小さい。 -/
def Reader.Prefers (R : Reader) (w : Weights) (d₁ d₂ : Document) : Prop :=
  d₁.content = d₂.content ∧ d₁.Faithful ∧ d₂.Faithful ∧ R.DistanceLt w d₁ d₂

namespace Reader

variable (R : Reader) (w : Weights)

/-- 正味の費用が一様に減り、`ε > 0` で、`e` に理解できる経路があれば、内容が同じで意味を保つ限り `e'` を優先する。 -/
theorem prefers_of_cost_sub (e e' : Document) (ε : Nat) (hε : 0 < ε)
    (hc : e'.content = e.content) (hfe : e.Faithful) (hfe' : e'.Faithful) (hr : R.Reachable w e)
    (h : ∀ p, R.Successful e p →
      ∃ q, R.Successful e' q ∧
        (R.cost R.initial q).weighted w + ε ≤ (R.cost R.initial p).weighted w) :
    R.Prefers w e' e := by
  refine ⟨hc, hfe', hfe, ?_⟩
  obtain ⟨n, ⟨p, hp, hn⟩, hmin⟩ := Nat.exists_least (R.Within w e) hr
  obtain ⟨q, hq, hle⟩ := h p hp
  refine ⟨n - ε, ⟨q, hq, by omega⟩, hmin (n - ε) (by omega)⟩

end Reader

end Knowledge.Documentation
