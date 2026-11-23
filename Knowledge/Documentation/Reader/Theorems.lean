import Knowledge.Documentation.Reader.Model

/-! # 理解までの距離についての定理

文書を書き換えたとき、読者にとっての理解までの距離がどう変わるか。
仮定からの帰結であり、具体的な文書が仮定を満たすかは別に確かめる。 -/

namespace Knowledge.Documentation

/-- 条件を満たす自然数があれば、最小のものがある。 -/
theorem Nat.exists_least (Q : Nat → Prop) (h : ∃ n, Q n) : ∃ n, Q n ∧ ∀ m, m < n → ¬Q m := by
  obtain ⟨n, hn⟩ := h
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases hm : ∃ m, m < n ∧ Q m
    · obtain ⟨m, hmn, hqm⟩ := hm
      exact ih m hmn hqm
    · exact ⟨n, hn, fun m hmn hqm => hm ⟨m, hmn, hqm⟩⟩

namespace Reader

variable (R : Reader)

/-! ## 書き換えと距離 -/

/-- 費用を増やさない書き換え。`e₁` のどの成功過程にも、費用が大きくない `e₂` の成功過程が対応すれば、
`e₂` の距離は `e₁` より大きくない。距離についての定理であり、成功確率が上がることまでは言えない。 -/
theorem distanceLe_of_cost_le (e₁ e₂ : Document)
    (h : ∀ p, R.Successful e₁ p →
      ∃ q, R.Successful e₂ q ∧ R.totalCost e₂ q ≤ R.totalCost e₁ p) :
    R.DistanceLe e₂ e₁ := by
  intro n ⟨p, hp, hn⟩
  obtain ⟨q, hq, hle⟩ := h p hp
  exact ⟨q, hq, Nat.le_trans hle hn⟩

/-- 費用を一様に減らす書き換え。`e` のどの成功過程にも、費用が `ε` 以上小さい `e'` の成功過程が対応すれば、
`e'` の距離は `e` の距離より `ε` 以上小さい。`ε` は、減る費用から増える費用を引いた正味の削減である。 -/
theorem within_sub_of_cost_sub (e e' : Document) (ε : Nat)
    (h : ∀ p, R.Successful e p →
      ∃ q, R.Successful e' q ∧ R.totalCost e' q + ε ≤ R.totalCost e p) :
    ∀ n, R.Within e n → R.Within e' (n - ε) := by
  intro n ⟨p, hp, hn⟩
  obtain ⟨q, hq, hle⟩ := h p hp
  exact ⟨q, hq, by omega⟩

/-- 費用を一様に減らす書き換えで、`ε > 0`、`e` に理解できる経路があり、内容が同じで意味を保つなら、
書き換えた `e'` を優先する。 -/
theorem prefers_of_cost_sub (e e' : Document) (ε : Nat) (hε : 0 < ε)
    (hc : e'.content = e.content) (hfe : e.Faithful) (hfe' : e'.Faithful) (hr : R.Reachable e)
    (h : ∀ p, R.Successful e p →
      ∃ q, R.Successful e' q ∧ R.totalCost e' q + ε ≤ R.totalCost e p) :
    R.Prefers e' e := by
  refine ⟨hc, hfe', hfe, ?_⟩
  obtain ⟨n, hn, hmin⟩ := Nat.exists_least (R.Within e) hr
  have hε' : ε ≤ n := by
    obtain ⟨p, hp, hpn⟩ := hn
    obtain ⟨_, _, hle⟩ := h p hp
    omega
  exact ⟨n - ε, R.within_sub_of_cost_sub e e' ε h n hn, hmin (n - ε) (by omega)⟩

/-! ## 種類への期待 -/

/-- 種類に従う文書は、期待からの逸脱の費用がかからない。 -/
theorem genreCost_eq_zero_of_conforms (e : Document) (h : e.Conforms) : R.genreCost e = 0 := by
  simp [Reader.genreCost, Document.deviationCount_eq_zero_of_conforms e h]

/-- 種類に従う文書は、同じ読み方ができる逸脱した文書より、距離が大きくない。 -/
theorem distanceLe_of_conforms (e e' : Document) (h : e.Conforms)
    (hp : ∀ p, R.Successful e' p → R.Successful e p) : R.DistanceLe e e' := by
  intro n ⟨p, hs, hn⟩
  refine ⟨p, hp p hs, ?_⟩
  simp only [Reader.totalCost, R.genreCost_eq_zero_of_conforms e h] at hn ⊢
  omega

/-- 種類を期待する読者にとって、種類に従う文書は、同じ読み方ができる逸脱した文書より距離が小さい。
逸脱一つあたりの費用が正で、逸脱が一つでもあれば、その分だけ遠くなる。 -/
theorem distanceLt_of_conforms (e e' : Document) (h : e.Conforms)
    (hp : ∀ p, R.Successful e' p ↔ R.Successful e p) (hr : R.Reachable e)
    (hexp : R.expects e'.genre) (hsur : 0 < R.surprise) (hdev : 0 < e'.deviationCount) :
    R.DistanceLt e e' := by
  obtain ⟨n, ⟨p, hs, hn⟩, hmin⟩ := Nat.exists_least (R.Within e) hr
  refine ⟨n, ⟨p, hs, hn⟩, ?_⟩
  intro ⟨q, hq, hqn⟩
  have hg : 0 < R.genreCost e' := by
    simp only [Reader.genreCost, hexp, ite_true]
    exact Nat.mul_pos hsur hdev
  have h0 := R.genreCost_eq_zero_of_conforms e h
  have hw : R.Within e (R.cost R.initial q) :=
    ⟨q, (hp q).mp hq, by simp only [Reader.totalCost, h0]; omega⟩
  simp only [Reader.totalCost] at hqn
  exact hmin _ (by omega) hw

/-! ## 読者による違い -/

/-- 読者による優劣の逆転。短い専門用語の文書 `eₛ` と、既知の言葉による具体的な説明 `eₗ` について、
熟練者が読む費用を `rₛ < rₗ`、初心者が専門用語を調べる追加費用を `ℓ` とし、`rₗ < rₛ + ℓ` とする。
このとき、熟練者には `eₛ` が、初心者には `eₗ` が近い。文書の短さだけから、読者を問わない優劣は決まらない。 -/
theorem distance_reverses (expert novice : Reader) (eₛ eₗ : Document) (rₛ rₗ ℓ : Nat)
    (hes : ∀ n, expert.Within eₛ n ↔ rₛ ≤ n) (hel : ∀ n, expert.Within eₗ n ↔ rₗ ≤ n)
    (hns : ∀ n, novice.Within eₛ n ↔ rₛ + ℓ ≤ n) (hnl : ∀ n, novice.Within eₗ n ↔ rₗ ≤ n)
    (h₁ : rₛ < rₗ) (h₂ : rₗ < rₛ + ℓ) :
    expert.DistanceLt eₛ eₗ ∧ novice.DistanceLt eₗ eₛ :=
  ⟨⟨rₛ, (hes rₛ).mpr (Nat.le_refl _), fun h => absurd ((hel rₛ).mp h) (by omega)⟩,
    ⟨rₗ, (hnl rₗ).mpr (Nat.le_refl _), fun h => absurd ((hns rₗ).mp h) (by omega)⟩⟩

end Reader

end Knowledge.Documentation
