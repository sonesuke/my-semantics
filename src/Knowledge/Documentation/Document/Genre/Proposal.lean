import Knowledge.Documentation.Document.Model
import Knowledge.Documentation.Document.Style.Diction
import Knowledge.Documentation.Document.Style.Construction

/-! # 提案書 -/

namespace Knowledge.Documentation

/-- 提案書の節の役割 -/
inductive ProposalRole where
  | background  -- 背景
  | problem     -- 課題
  | proposal    -- 提案：受け入れたら何をするか（範囲・条件・何をしないか）
  | effect      -- 効果：受け入れた場合と受け入れない場合の差
  | cost        -- 費用：受け入れた場合と受け入れない場合の差
  | decision    -- 判断してほしいこと：受け入れるかと、その期限

/-- 提案書。読者に、提案を受け入れるかを判断してもらう文書。判断は受け入れるか受け入れないかの二値なので、
受け入れたら何が起きるかを提案の中で過不足なく書く。読者が「はい」と答えたとき何に同意したかは、提案の記述で決まる。
判断は提案を前提にするので、最後に置く。
背景・課題・効果・費用は事実と数値で具体的に書き、提案は具体的に言い切る。
判断してほしいことは、新しい語を導入せず、はい／いいえで答えられる形で依頼する。提案で使った語は、判断してほしいことでも言い直さない。何に「はい」と答えるかが曖昧になるため。 -/
def proposal : Genre where
  Role := ProposalRole
  layout := Genre.fixed [.background, .problem, .proposal, .effect, .cost, .decision]
  style
    | .background => Style.Concrete
    | .problem => Style.Concrete
    | .proposal => fun s => s.Assertive ∧ s.Concrete
    | .effect => Style.Concrete
    | .cost => Style.Concrete
    | .decision => fun s => s.Requesting ∧ s.YesNo ∧ s.NoNewWords
  styleAcross := Style.NoRephrasing

end Knowledge.Documentation
