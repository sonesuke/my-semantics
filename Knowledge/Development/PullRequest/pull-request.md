---
type: concept
title: PR
description: Issue に応えて、作った時点の成果物に対する実装の変更と範囲を持ち、承認を求めるもの。足りない部分を書かない PR は作れない。
tags: [development, pull-request]
---

# PR

PR（[`PullRequest`](./Model.lean)）は、Issue に応えて、作った時点の成果物（`base`）に対する実装の変更と、範囲を持つ。CI の結果と本文、本文の要約（タイトル）も持つ。

## 範囲

範囲（[`PullRequest.Scope`](./Model.lean)）は、Issue のとおりか、変えたかのどちらか。変えたなら、変えた変更要件と、変えた理由を持つ。範囲を変えたのに理由を書かない PR は作れない。

## 本文

本文（[`PullRequest.Body`](./Model.lean)）は、範囲・検証・見積もり・実装の理由を持つ。本文は Issue・作った時点の成果物・変更後の実装・CI 結果に依存する型なので、その変更の検証しか持てない（[検証](../Verification/verification.md)）。見積もりは既定路線の費用で、既定路線の実装はないので提案者が見積もる。

## 届けることと解決すること

- 届ける（[`PullRequest.Delivers`](./Model.lean)）：変更後の成果物が正しく、ルールに適合する。
- 解決する（[`PullRequest.Resolves`](./Model.lean)）：Issue の変更要件どおりに実現し、正しく、ルールに適合する。

範囲を変えていなければ、この二つは一致する（[`PullRequest.delivers_iff_resolves`](./Model.lean)）。

## 承認

承認（[`PullRequest.Approval`](./Model.lean)）は、人間が PR を受け入れる判断で、受け入れるかどうかの二値である。正しさ、理由と見積もりの妥当さ、要求の価値はここで判断する。範囲を変えた PR の承認は、その範囲の変更を認めることでもある。承認された PR だけがリポジトリの履歴に入る（[リポジトリ](../Repository/repository.md)）。
