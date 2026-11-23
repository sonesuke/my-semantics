# my-semantics

ソフトウェア開発の知識を、Lean 4 の定義と定理として記述するリポジトリ。

## 構成

- `Knowledge/` — 知識の正本。定義・設計の理由・定理を Lean 4 で記述する (入口は [`Knowledge.lean`](Knowledge.lean))
  - `Development/` — 開発の知識 (理由・成果物・検証・Issue・PR・Repository・費用)
  - `Documentation/` — 文章の知識 (文書・読者)
- `lakefile.toml`・`lean-toolchain` — Lake のプロジェクト設定

## 開発環境

[Nix](https://nixos.org/) (flakes 有効) が必要。

```sh
nix develop      # Node.js・elan (Lean 4) と Nix 用ツール (nixfmt・statix・deadnix) が入った開発シェルに入る
npm ci           # prettier / markdownlint-cli2 を入れる
lake build       # Lean のビルドと証明の検査 (CI と同じ)
npm run format   # 整形
npm run check    # 整形チェック・lint (Markdown・Nix) (CI と同じ)
```

[direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv) を使うと、初回に `direnv allow` するだけで、以降は `cd` 時に開発シェルが有効になり npm 依存も自動で入る。

## 知識の書き方

- 概念ごとに、型・構造体・定義を置き、docstring に何を表すかと、そう定めた理由を書く。
- 構造体のフィールドの意味は、行末の `--` コメントで書く。設計の理由は構造体の docstring に書く。
- モデルの意図は、定理として示す。
