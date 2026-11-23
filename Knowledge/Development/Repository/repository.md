---
type: concept
title: リポジトリ
description: 最初の成果物と、承認された PR の履歴。今の成果物も、Issue と PR の状態も、履歴から求める。
tags: [development, repository]
sources:
  - resource: ./Model.lean
  - resource: ../Justification/Deviation.lean
generated: { by: "claude/claude-opus-5-5", at: "2026-11-23T00:00:00Z" }
---

# リポジトリ

リポジトリ（`Repository`）は、最初の成果物と、承認された PR の履歴（古い順）を持つ。作られたすべての Issue と PR も、記録として持つ。

今の成果物も、Issue と PR の状態も、フィールドとしては持たず、履歴から求める。状態を別に持つと、履歴と食い違い得るためである。

| 求めるもの | 求め方 |
| --- | --- |
| 今の成果物（`Repository.artifact`） | 最初の成果物に、履歴の PR を順に当てる |
| 一貫している（`Repository.Consistent`） | 履歴のどの PR も、その時点の成果物に適用できる |
| PR がマージされた（`Repository.Merged`） | 履歴に含まれる |
| Issue が解決された（`Repository.Resolved`） | その Issue に応えて範囲を届けた PR が、履歴にある |

マージの条件に正しさは求めない。逸脱があれば PR が理由を示し、受け入れるかは承認で判断する。

見積もりを超えない PR だけを積み重ねれば、どの時点でもリポジトリの費用は、直前の PR の既定路線を超えない（`Repository.cost_le_default`、[費用](../Cost/cost.md)）。
