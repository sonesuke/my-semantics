# my-semantics

ソフトウェア開発の知識を [Open Knowledge Format (OKF) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog) で記述するリポジトリ。

## 構成

- `knowledge/` — OKF バンドル本体 (入口は [`knowledge/index.md`](knowledge/index.md))
- `src/` — 開発の知識 (理由・成果物・検証・Issue・PR・Repository・費用) と文章の知識 (読みやすさ・最適化戦略) の定義・設計の理由・定理を Lean 4 で記述した正本 (`npm run lean` でビルド・証明検査。CI では実行しない)
- `scripts/okf-validate.ts` — OKF 適合性と、内部リンクの相対パス・参照先の存在・入口から全 Markdown 文書への到達性をチェック

## 開発環境

[Nix](https://nixos.org/) (flakes 有効) が必要。

```sh
nix develop      # Node.js・elan (Lean 4) と Nix 用ツール (nixfmt・statix・deadnix) が入った開発シェルに入る
npm ci           # prettier / markdownlint-cli2 / TypeScript / yaml を入れる
npm run format   # 整形
npm run check    # 整形チェック・lint (Markdown・Nix)・型チェック・OKF 検証 (CI と同じ)
```

[direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv) を使うと、初回に `direnv allow` するだけで、以降は `cd` 時に開発シェルが有効になり npm 依存も自動で入る。

## 知識の書き方

- 1 ファイル = 1 concept。frontmatter に `type` (必須)、`title`、`description`、`tags` を書く。
- 内部リンクはリンクを書いたファイルを起点とする相対パス (`./other.md`、`../index.md`) で書く。
- 追加・変更したら各ディレクトリの `index.md` を更新する。変更履歴は git で管理する。
