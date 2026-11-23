# my-semantics

ソフトウェア開発の知識を、Lean 4 の定義と定理として記述するリポジトリ。

## 構成

- `Knowledge/` — 知識の正本。定義・設計の理由・定理を Lean 4 で記述する (入口は [`Knowledge.lean`](Knowledge.lean))。各フォルダに、その概念の説明を [Open Knowledge Format (OKF) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog) で並べて置く (入口は [`Knowledge/index.md`](Knowledge/index.md))
  - `Development/` — 開発の知識 (理由・成果物・検証・Issue・PR・Repository・費用)
  - `Documentation/` — 文章の知識 (文書・読者)
- `scripts/okf-validate.ts` — OKF 適合性と、内部リンク・参照先の存在・入口からの到達性、説明が参照する Lean の名前の実在をチェック
- `lakefile.toml`・`lean-toolchain` — Lake のプロジェクト設定

## 開発環境

[Nix](https://nixos.org/) (flakes 有効) が必要。

```sh
nix develop      # Node.js・elan (Lean 4) と Nix 用ツール (nixfmt・statix・deadnix) が入った開発シェルに入る
npm ci           # prettier / markdownlint-cli2 / TypeScript / OKF 検証の依存を入れる
lake build       # Lean のビルドと証明の検査 (CI と同じ)
npm run format   # 整形
npm run check    # 整形チェック・lint (Markdown・Nix)・型チェック・テスト・OKF 検証 (CI と同じ)
```

[direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv) を使うと、初回に `direnv allow` するだけで、以降は `cd` 時に開発シェルが有効になり npm 依存も自動で入る。

## 知識の書き方

- 概念ごとに、型・構造体・定義を置き、docstring に何を表すかと、そう定めた理由を書く。
- 構造体のフィールドの意味は、行末の `--` コメントで書く。設計の理由は構造体の docstring に書く。
- モデルの意図は、定理として示す。
- 概念の説明は、`Knowledge/` の各フォルダに、フォルダ名を小文字にしたファイル名 (例：`Artifact/artifact.md`) で書く。frontmatter に `type` (必須)、`title`、`description`、`tags` を書く。
- 説明から Lean の名前を参照するときは、``[`Artifact.Correct`](./Model.lean)`` のように、名前をインラインコードにして定義のファイルへリンクする。名前が実在しなければ検証で失敗する。
