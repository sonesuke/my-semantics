import Knowledge.Documentation.Document.Content

/-! # 文書のモデル

文書は、内容にレイアウトと文体を当てたもの。レイアウトは事柄を節に割り当てて並べ、文体は各節をどう書くかを決める。 -/

namespace Knowledge.Documentation

/-- 文書の種類。提案書、報告書、Issue、PRなど。節の役割と、取るべきレイアウトと文体を定める。
よいレイアウトと文体は種類によって違うので、種類が持つ。文書を種類に従わせることが、読みやすくする戦略になる。 -/
structure Genre where
  Role : Type                      -- 節の役割
  layout : List Role → Prop        -- 取るべきレイアウト（役割の並びの条件）
  style : Role → Style → Prop      -- 取るべき文体（役割ごと）
  styleAcross : List Style → Prop  -- 節をまたいだ文体の条件（言い直さない、など）

/-- 決まった並びのレイアウト。節の役割の並びが `roles` と一致する。 -/
def Genre.fixed {Role : Type} (roles : List Role) : List Role → Prop :=
  (· = roles)

/-- 順序を守るレイアウト。節の役割は `roles` の順序に沿って並び、`required` の役割は必ず含む。それ以外は省いてよい。 -/
def Genre.ordered {Role : Type} (roles required : List Role) : List Role → Prop :=
  fun l => l.Sublist roles ∧ ∀ r ∈ required, r ∈ l

/-- 節。役割と、伝える事柄と、文体を持つ。 -/
structure Section (g : Genre) where
  role : g.Role        -- 役割
  points : List Point  -- 伝える事柄
  style : Style        -- 文体

/-- 文書。内容と種類と、節の並び。 -/
structure Document where
  content : Content                -- 内容
  genre : Genre                    -- 種類
  sections : List (Section genre)  -- 節の並び

/-- レイアウト。節の役割の並び。 -/
def Document.layout (d : Document) : List d.genre.Role :=
  d.sections.map (·.role)

/-- 文体。節の文体の並び。 -/
def Document.style (d : Document) : List Style :=
  d.sections.map (·.style)

/-- 文書が使っている語。各節の文体が使っている語を並べたもの。 -/
def Document.words (d : Document) : List Word :=
  d.style.flatMap Style.words

/-- 従う。レイアウトと各節の文体と、節をまたいだ文体が、その種類の取るべきものを満たす。
読者が種類のレイアウトを知っていれば、どこに何があるかを探す負担が減る。 -/
def Document.Conforms (d : Document) : Prop :=
  d.genre.layout d.layout ∧ (∀ s ∈ d.sections, d.genre.style s.role s.style) ∧
    d.genre.styleAcross d.style

open Classical in
/-- 逸脱の数。種類のレイアウトに従わなければ一つ、役割の文体を満たさない節が一つにつき一つ、
節をまたいだ文体を満たさなければ一つ。種類に従う文書では零になる。 -/
noncomputable def Document.deviationCount (d : Document) : Nat :=
  (if d.genre.layout d.layout then 0 else 1) +
    (d.sections.filter fun s => ¬d.genre.style s.role s.style).length +
    (if d.genre.styleAcross d.style then 0 else 1)

open Classical in
/-- 種類に従う文書は、逸脱がない。 -/
theorem Document.deviationCount_eq_zero_of_conforms (d : Document) (h : d.Conforms) :
    d.deviationCount = 0 := by
  obtain ⟨hl, hs, ha⟩ := h
  have hf : (d.sections.filter fun s => ¬d.genre.style s.role s.style) = [] :=
    List.filter_eq_nil_iff.mpr fun s hs' => by simpa using hs s hs'
  simp only [Document.deviationCount, hl, ha, hf, ite_true, List.length_nil]

/-- 意味を保つ。内容のどの事柄も、どこかの節で文体によって伝わり、内容にない事柄を伝える節がない。
必要な事柄の省略や、内容にないことの断定を防ぐ。 -/
def Document.Faithful (d : Document) : Prop :=
  (∀ p ∈ d.content.points, ∃ s ∈ d.sections, p ∈ s.points ∧ s.style.Conveys p) ∧
    ∀ s ∈ d.sections, ∀ p ∈ s.points, p ∈ d.content.points

end Knowledge.Documentation
