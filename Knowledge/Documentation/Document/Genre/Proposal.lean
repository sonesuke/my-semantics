import Knowledge.Documentation.Document.Genre.Model

/-! # 提案書 -/

namespace Knowledge.Documentation

/-- 背景。読む人に、課題を理解する前提を与える。事実と数値で具体的に書く。 -/
def Proposal.Role.background : Role := ⟨"背景", fun s => s.diction.Concrete⟩

/-- 課題。何が問題かを示す。事実と数値で具体的に書く。 -/
def Proposal.Role.problem : Role := ⟨"課題", fun s => s.diction.Concrete⟩

/-- 提案。受け入れたら何をするか（範囲・条件・何をしないか）を示す。具体的に言い切る。 -/
def Proposal.Role.proposal : Role := ⟨"提案", fun s => s.sentences.Assertive ∧ s.diction.Concrete⟩

/-- 効果。受け入れた場合と受け入れない場合の差を示す。事実と数値で具体的に書く。 -/
def Proposal.Role.effect : Role := ⟨"効果", fun s => s.diction.Concrete⟩

/-- 費用。受け入れた場合と受け入れない場合の差を示す。事実と数値で具体的に書く。 -/
def Proposal.Role.cost : Role := ⟨"費用", fun s => s.diction.Concrete⟩

/-- 判断してほしいこと。受け入れるかと、その期限について、何に答えればよいかを示す。
新しい語を導入せず、はい／いいえで答えられる形で依頼する。 -/
def Proposal.Role.decision : Role := ⟨"判断してほしいこと", fun s => s.sentences.Requesting ∧ s.sentences.YesNo ∧ s.diction.NoNewWords⟩

/-- 提案書。読者に、提案を受け入れるかを判断してもらう文書。判断は受け入れるか受け入れないかの二値なので、
受け入れたら何が起きるかを提案の中で過不足なく書く。読者が「はい」と答えたとき何に同意したかは、提案の記述で決まる。
判断は提案を前提にするので、最後に置く。提案で使った語は、判断してほしいことでも言い直さない。
何に「はい」と答えるかが曖昧になるため。 -/
def proposal : Genre where
  layout := Genre.fixed
    [Proposal.Role.background, Proposal.Role.problem, Proposal.Role.proposal, Proposal.Role.effect,
      Proposal.Role.cost, Proposal.Role.decision]
  style ss := Diction.NoRephrasing (ss.map (·.diction))
  place := Genre.sameName

end Knowledge.Documentation
