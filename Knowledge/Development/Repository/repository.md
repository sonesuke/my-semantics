---
type: concept
title: リポジトリ
description: 最初の成果物と、承認された PR の履歴。今の成果物も、Issue と PR の状態も、履歴から求める。
tags: [development, repository]
---

# リポジトリ

リポジトリ（[`Repository`](./Model.lean)）は、最初の成果物と、承認された PR の履歴（古い順）を持つ。作られたすべての Issue と PR も、記録として持つ。

今の成果物も、Issue と PR の状態も、フィールドとしては持たず、履歴から求める。状態を別に持つと、履歴と食い違い得るためである。

| 求めるもの                                                  | 求め方                                            |
| ----------------------------------------------------------- | ------------------------------------------------- |
| 今の成果物（[`Repository.artifact`](./Model.lean)）         | 最初の成果物に、履歴の PR を順に当てる            |
| 一貫している（[`Repository.Consistent`](./Model.lean)）     | 履歴のどの PR も、その時点の成果物に適用できる    |
| PR がマージされた（[`Repository.Merged`](./Model.lean)）    | 履歴に含まれる                                    |
| Issue が解決された（[`Repository.Resolved`](./Model.lean)） | その Issue に応えて範囲を届けた PR が、履歴にある |

マージの条件に正しさは求めない。逸脱があれば PR が理由を示し、受け入れるかは承認で判断する。

見積もりを超えない PR だけを積み重ねれば、どの時点でもリポジトリの費用は、直前の PR の既定路線を超えない（[`Repository.cost_le_default`](../Justification/Deviation.lean)、[費用](../Cost/cost.md)）。
