---
type: concept
title: 文書
description: 内容にレイアウトと文体を当てたもの。内容は何を伝えるか、レイアウトは事柄を節に割り当てて並べること、文体は各節をどう書くか。
tags: [documentation, document, content, layout]
sources:
  - resource: ./Model.lean
  - resource: ./Content.lean
  - resource: ./Layout.lean
generated: { by: "claude/claude-opus-5-5", at: "2026-11-23T00:00:00Z" }
---

# 文書

文書（`Document`）は、内容にレイアウトと文体を当てたもの。内容と、文書の種類と、節の並びを持つ。

## 内容

内容（`Content`）は、何を伝えるか。伝えたい事柄（`Point`）と、事柄どうしの前提関係（ある事柄の理解に、別の事柄が必要）を持つ。どう並べるか、どう書くかとは独立に決まる。

## 節とレイアウト

節（`Section`）は、役割と、伝える事柄と、文体を持つ。レイアウト（`Document.layout`）は節の役割の並びで、どんなレイアウトを取るべきかは文書の種類が決める（[文書の種類](./Genre/genre.md)）。

レイアウトの条件には、次のようなものがある。

- 役割ごとにまとまっている（`Document.GroupedByRole`）：同じ役割の節が連続している。
- 前提に沿っている（`Document.OrderedByPrerequisite`）：どの節の事柄も、後ろの節の事柄を前提にしない。

## 意味を保つ

意味を保つ（`Document.Faithful`）とは、内容のどの事柄も、どこかの節で文体によって伝わり、内容にない事柄を伝える節がないこと。必要な事柄の省略や、内容にないことの断定を防ぐ。

## 種類に従う

種類に従う（`Document.Conforms`）とは、レイアウトと各節の文体と、節をまたいだ文体が、その種類の取るべきものを満たすこと。満たさない箇所の数を逸脱の数（`Document.deviationCount`）として数え、種類に従う文書では零になる。読者はこの逸脱の分だけ読みにくく感じる（[読者](../Reader/reader.md)）。
