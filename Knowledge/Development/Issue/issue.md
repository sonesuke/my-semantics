---
type: concept
title: Issue
description: 変更要件を持つもの。要求・振る舞い・設計ルールの変え方と、その変更を求める理由（要求の価値）を述べる。
tags: [development, issue]
---

# Issue

Issue（[`Issue`](./Model.lean)）は、変更要件を一つ持つ。変更要件は、要求・振る舞い・設計ルールの変え方と、なぜその変更を求めるかの理由からなる（[成果物](../Artifact/artifact.md)）。Issue は実装の変更を持たない。実装の変更は PR が持つ（[PR](../PullRequest/pull-request.md)）。

Issue の理由は要求の価値を述べ、PR の既定路線を定める。既定路線は、作った時点の成果物に Issue の変更要件をそのまま当て、実装が最小であるものである（[費用](../Cost/cost.md)）。
