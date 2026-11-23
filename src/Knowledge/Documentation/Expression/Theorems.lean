import Knowledge.Documentation.Expression.Model

/-! # 読みやすさのモデルから導く定理

仮定からの帰結であり、具体的な文章が仮定を満たすかは別に確かめる。 -/

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

namespace Premise

variable (P : Premise) (w : Weights)

/-- 成功過程の費用を増やさない変換。`e₁` のどの成功過程にも、成分ごとに費用が大きくない `e₂` の成功過程が
対応すれば、`e₂` の理解までの距離は `e₁` より大きくない。
距離についての定理であり、成功確率が上がることまでは言えない。 -/
theorem distanceLe_of_cost_le (e₁ e₂ : Expression)
    (h : ∀ p, P.Successful e₁ p →
      ∃ q, P.Successful e₂ q ∧ (P.cost P.initial q).Le (P.cost P.initial p)) :
    P.DistanceLe w e₂ e₁ := by
  intro n ⟨p, hp, hn⟩
  obtain ⟨q, hq, hle⟩ := h p hp
  exact ⟨q, hq, Nat.le_trans (Cost.weighted_le w hle) hn⟩

/-- 正味の費用が一様に減る変換。`e` のどの成功過程にも、重み付きの費用が `ε` 以上小さい `e'` の成功過程が
対応すれば、`e'` の距離は `e` の距離より `ε` 以上小さい。
減る費用 `R` と増える費用 `A` について `R - A ≥ ε` が一様に成り立つことを、差 `ε` で表す。 -/
theorem within_sub_of_cost_sub (e e' : Expression) (ε : Nat)
    (h : ∀ p, P.Successful e p →
      ∃ q, P.Successful e' q ∧
        (P.cost P.initial q).weighted w + ε ≤ (P.cost P.initial p).weighted w) :
    ∀ n, P.Within w e n → P.Within w e' (n - ε) := by
  intro n ⟨p, hp, hn⟩
  obtain ⟨q, hq, hle⟩ := h p hp
  exact ⟨q, hq, by omega⟩

/-- 正味の費用が一様に減り、`ε > 0` で、`e` に理解できる経路があれば、意味を保つ限り `e'` を優先する。 -/
theorem prefers_of_cost_sub (e e' : Expression) (ε : Nat) (hε : 0 < ε)
    (hfe : P.Faithful e) (hfe' : P.Faithful e') (hr : P.Reachable w e)
    (h : ∀ p, P.Successful e p →
      ∃ q, P.Successful e' q ∧
        (P.cost P.initial q).weighted w + ε ≤ (P.cost P.initial p).weighted w) :
    P.Prefers w e' e := by
  refine ⟨hfe', hfe, ?_⟩
  obtain ⟨n, ⟨p, hp, hn⟩, hmin⟩ := Nat.exists_least (P.Within w e) hr
  obtain ⟨q, hq, hle⟩ := h p hp
  refine ⟨n - ε, ⟨q, hq, by omega⟩, hmin (n - ε) (by omega)⟩

/-- 読者による優劣の逆転。短い専門用語の表現 `eₛ` と、既知の言葉による具体的な説明 `eₗ` について、
熟練者が読む費用を `rₛ < rₗ`、初心者が専門用語を調べる追加費用を `ℓ` とし、`rₗ < rₛ + ℓ` とする。
このとき、熟練者には `eₛ` が、初心者には `eₗ` が近い。表現の短さだけから、読者を問わない優劣は決まらない。 -/
theorem distance_reverses (expert novice : Premise) (eₛ eₗ : Expression) (rₛ rₗ ℓ : Nat)
    (hes : ∀ n, expert.Within w eₛ n ↔ rₛ ≤ n) (hel : ∀ n, expert.Within w eₗ n ↔ rₗ ≤ n)
    (hns : ∀ n, novice.Within w eₛ n ↔ rₛ + ℓ ≤ n) (hnl : ∀ n, novice.Within w eₗ n ↔ rₗ ≤ n)
    (h₁ : rₛ < rₗ) (h₂ : rₗ < rₛ + ℓ) :
    expert.DistanceLt w eₛ eₗ ∧ novice.DistanceLt w eₗ eₛ :=
  ⟨⟨rₛ, (hes rₛ).mpr (Nat.le_refl _), fun h => absurd ((hel rₛ).mp h) (by omega)⟩,
    ⟨rₗ, (hnl rₗ).mpr (Nat.le_refl _), fun h => absurd ((hns rₗ).mp h) (by omega)⟩⟩

end Premise

end Knowledge.Documentation
