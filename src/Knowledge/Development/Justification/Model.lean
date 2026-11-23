/-! # 理由のモデル -/

namespace Knowledge.Development

/-- 理由。承認で受け入れられるかが判断される。
Issueでは、なぜその変更を求めるか（要求の価値）を述べ、PRの既定路線を定める。
PRでは、既定路線との差がなぜ妥当かを述べる。 -/
opaque Justification : Type

end Knowledge.Development
