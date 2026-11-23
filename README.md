# my-semantics

ソフトウェア開発の知識を、Lean 4 の定義と定理として記述するリポジトリ。

## 構成

- `Knowledge/` — 知識の正本。定義・設計の理由・定理を Lean 4 で記述する (入口は [`Knowledge.lean`](Knowledge.lean))。各フォルダに、その概念の説明を [Open Knowledge Format (OKF) v0.2](https://github.com/open-knowledge-format/open-knowledge-format) で並べて置く (入口は [`Knowledge/index.md`](Knowledge/index.md))
  - `Development/` — 開発の知識 (理由・成果物・検証・Issue・PR・Repository・費用)
  - `Documentation/` — 文章の知識 (文書・読者)
- `lakefile.toml`・`lean-toolchain` — Lake のプロジェクト設定

## 開発環境

[Nix](https://nixos.org/) (flakes 有効) が必要。`okq` は nixpkgs に無いため、flake の中で crates.io からビルドしている (`packages.okq`)。

```sh
nix develop                                   # okq・elan (Lean 4) と Nix 用ツール (nixfmt・statix・deadnix) が入った開発シェルに入る
lake build                                    # Lean のビルドと証明の検査 (CI と同じ)
okq --bundle Knowledge validate --check       # OKF 適合性の検査 (CI と同じ)
okq --bundle Knowledge deadlinks --check      # バンドル内のリンク切れの検査 (CI と同じ)
nixfmt --check flake.nix                      # Nix ファイルの整形チェック (CI と同じ)
statix check flake.nix && deadnix --fail flake.nix # Nix ファイルの lint (CI と同じ)
```

[direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv) を使うと、初回に `direnv allow` するだけで、以降は `cd` 時に開発シェルが有効になる。

## 知識の書き方

- 概念ごとに、型・構造体・定義を置き、docstring に何を表すかと、そう定めた理由を書く。
- 構造体のフィールドの意味は、行末の `--` コメントで書く。設計の理由は構造体の docstring に書く。
- モデルの意図は、定理として示す。
- 概念の説明は、`Knowledge/` の各フォルダに、フォルダ名を小文字にしたファイル名 (例：`Artifact/artifact.md`) で書く。frontmatter に `type` (必須)、`title`、`description`、`tags`、`sources`、`generated` を書く。
- 説明のもとになる Lean ファイルは frontmatter の `sources` に相対パスで書き、本文では Lean の名前をインラインコード (例：`` `Artifact.Correct` ``) で示す。
