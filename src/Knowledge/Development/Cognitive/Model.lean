import Knowledge.Development.Artifact.Model

/-! # 認知負荷のモデル -/

namespace Knowledge.Development

/-- ルールの認知負荷。覚えるべき設計ルールの負担 `cost` の合計。
ルールの数で測らないのは、一つのルールにすべてを詰め込めるため。 -/
def Rule.cognitiveLoad (cost : Rule → Nat) (rules : List Rule) : Nat :=
  (rules.map cost).sum

/-- 実装の認知負荷。`load rules i` は「設計ルール `rules` を知った上で実装 `i` を読む負担」。
ルールに依存させるのは、ルールが実装を読みやすくする効果をこの負担の減少として表すため。 -/
abbrev ImplementationLoad := List Rule → Implementation → Nat

/-- 認知負荷。ルールを覚える負担と、ルールを前提に実装を読む負担の和。
ルールを増やすと前者が増え後者が減るので、この和でルールの釣り合いを測る。 -/
def Artifact.cognitiveLoad (cost : Rule → Nat) (load : ImplementationLoad) (a : Artifact) : Nat :=
  Rule.cognitiveLoad cost a.rules + load a.rules a.implementation

/-- よい。正しく、ルールに適合し、要求と振る舞いが同じものの中で認知負荷が最小である。
振る舞いまで揃えるのは、ルールと実装の選び方だけを比べるため。 -/
def Artifact.Good (cost : Rule → Nat) (load : ImplementationLoad) (a : Artifact) : Prop :=
  a.Correct ∧ a.Conforms ∧
    ∀ b : Artifact, b.requirements = a.requirements → b.behavior = a.behavior →
      b.Correct → b.Conforms → a.cognitiveLoad cost load ≤ b.cognitiveLoad cost load

end Knowledge.Development
