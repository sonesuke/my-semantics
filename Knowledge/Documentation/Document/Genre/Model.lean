import Knowledge.Documentation.Document.Section

/-! # 文書の種類のモデル -/

namespace Knowledge.Documentation

/-- 文書の種類。提案書、PREP法、PRなど。節ごとの文体は役割が持つので、種類は節をまたいだ文体だけを持つ。 -/
structure Genre where
  layout : List Section → Prop  -- レイアウト（節の並び）が満たすべき決まり
  style : List Style → Prop     -- 節をまたいだ文体が満たすべき決まり
  place : Topic → Role → Prop   -- 内容を節にする方針：その話題の事柄を、その役割の節に置いてよい

/-- 話題と同じ名前の役割の節に置く方針。話題と役割が一対一に対応する種類で使う。 -/
def Genre.sameName (t : Topic) (r : Role) : Prop :=
  t.name = r.name

/-- 決まった並び。節の役割の並びが `roles` と一致する。役割は名前で比べる。 -/
def Genre.fixed (roles : List Role) : List Section → Prop :=
  fun ss => ss.map (·.role.name) = roles.map (·.name)

/-- 順序を守る並び。節の役割は `roles` の順序に沿って並び、`required` の役割は必ず含む。それ以外は省いてよい。
役割は名前で比べる。 -/
def Genre.ordered (roles required : List Role) : List Section → Prop :=
  fun ss => (ss.map (·.role.name)).Sublist (roles.map (·.name)) ∧
    ∀ r ∈ required, r.name ∈ ss.map (·.role.name)

end Knowledge.Documentation
