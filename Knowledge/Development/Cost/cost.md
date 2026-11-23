---
type: concept
title: 費用
description: 認知コストを一つの物差しで測り、既定路線からの逸脱に理由を求め、その分だけ承認の費用が上がる。見積もりを超えない PR を積み重ねれば、リポジトリは既定路線より悪くならない。
tags: [development, cost, deviation, approval, roi]
---

# 費用

## 認知コスト

認知コスト（[`CognitiveCost`](./Model.lean)）は、理解に要する費用を測る一つの物差しで、単位は何でもよいが、すべて同じ基準で測る。設計ルールを覚える費用、ルールを知った上で実装を読む費用、PR を読む費用、理由を読む費用からなる。

ルールを増やすと、覚える費用は増え、実装を読む費用は減る。その釣り合いを、和（[`Artifact.ruleImplementationCost`](./Model.lean)）で測る。要求・振る舞い・ルールが同じものの中で実装の費用が最小のものを、実装が最小（[`Artifact.MinimalImplementation`](./Model.lean)）という。

## 既定路線と逸脱

既定路線（[`PullRequest.DefaultMinimalImplementation`](../Justification/Deviation.lean)）は、作った時点の成果物に Issue の変更要件をそのまま当て、実装が最小であるもの。PR の理由は、既定路線との差を正当化する。差（逸脱、[`PullRequest.deviations`](../Justification/Deviation.lean)）は三つある。

| 逸脱                                                                              | 読む理由         |
| --------------------------------------------------------------------------------- | ---------------- |
| 範囲を変えた                                                                      | 範囲を変えた理由 |
| 確かめない部分がある                                                              | 確かめない理由   |
| 見積もりを超えた（[`PullRequest.OverEstimate`](../Justification/Deviation.lean)） | 実装の理由       |

見積もりが正確（[`PullRequest.EstimateAccurate`](../Justification/Deviation.lean)）とは、既定路線の費用が見積もりと一致すること。承認ではこれを判断する。

## 承認の費用と ROI

承認の費用（[`PullRequest.approvalCost`](./Approval.lean)）は、PR を読む費用と、逸脱の理由を読む費用の和。逸脱があれば、その理由を読む費用が加わる（[`PullRequest.approvalCost_of_deviation`](./Approval.lean)）。

ROI（[`PullRequest.roi`](./Approval.lean)）は、PR の価値 1 と、見積もりより減った費用を読まれる回数分だけ足したものを、承認の費用で割ったもの。価値を 1 に固定するのは、動かせると差の項を好きなだけ希薄にできるためである。見積もりを超えない PR は ROI が正になる（[`PullRequest.roi_pos`](./Approval.lean)）。

## 積み重ね

見積もりが正確で見積もりを超えない PR は、既定路線より費用が大きくならない（[`PullRequest.cost_le_default`](../Justification/Deviation.lean)）。範囲を変えて要求・振る舞い・ルールを見直せば、既定路線より小さくなることもある。そうした PR だけを積み重ねれば、どの時点でもリポジトリの費用は直前の PR の既定路線を超えない（[`Repository.cost_le_default`](../Justification/Deviation.lean)）。
