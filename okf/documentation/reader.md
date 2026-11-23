---
type: concept
title: 読者
description: 文書を読んで目的に必要な理解に至る主体。理解までの距離は読者と文書の関係で決まり、知っている文書の種類からの逸脱の分だけ読みにくくなる。
tags: [documentation, reader, distance]
---

# 読者

読者（[`Reader`](../../Knowledge/Documentation/Reader/Model.lean)）は、目的と、読む前の頭の中と、閲覧条件のもとでの読み進め方と、その費用を持つ。平易さは読者と文書の関係で決まり、専門家には専門用語が近く、初心者には身近な例が近いことがある。

## 頭の中と理解

頭の中（[`Mind`](../../Knowledge/Documentation/Reader/Model.lean)）は、語と概念の対応、覚えている命題や事例、説明・判断・実行の能力からなり、読み進めるにつれて変わる。誤解している状態も含む。すべての目的について十分に応答できれば、理解している（[`Reader.Understands`](../../Knowledge/Documentation/Reader/Model.lean)）。

## 理解までの距離

読者は、操作（読む、調べる、戻る、推論する）を重ねて頭の中を変えていく。最後に理解している過程を成功する過程といい、その読む費用の下限を理解までの距離とする（[`Reader.Within`](../../Knowledge/Documentation/Reader/Model.lean)）。成功する過程がなければ、距離は無限になる。

## 種類への期待

読者は知っている文書の種類（`expects`）に、そのレイアウトと文体を期待して読む。知っている種類の文書を読むときは、逸脱の数に応じた費用がかかる（[`Reader.genreCost`](../../Knowledge/Documentation/Reader/Model.lean)）。知らない種類なら期待がないので、かからない。

- 種類に従う文書は、同じ読み方ができる逸脱した文書より、距離が大きくない（[`Reader.distanceLe_of_conforms`](../../Knowledge/Documentation/Reader/Theorems.lean)）。
- 種類を期待する読者にとっては、距離が小さい（[`Reader.distanceLt_of_conforms`](../../Knowledge/Documentation/Reader/Theorems.lean)）。

## 読者による違い

専門用語で短く書いた文書は熟練者に、平易に書いた文書は初心者に近い（[`Reader.distance_reverses`](../../Knowledge/Documentation/Reader/Theorems.lean)）。文書の短さだけから、読者を問わない優劣は決まらない。
