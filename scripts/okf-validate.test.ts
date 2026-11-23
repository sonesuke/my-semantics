import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const validator = fileURLToPath(new URL("./okf-validate.ts", import.meta.url));
const concept = (body: string) => `---\ntype: concept\n---\n\n${body}\n`;

function validate(files: Record<string, string>, args: string[] = []) {
  const root = mkdtempSync(path.join(tmpdir(), "okf-validate-"));
  try {
    for (const [name, content] of Object.entries(files)) {
      const file = path.join(root, name);
      mkdirSync(path.dirname(file), { recursive: true });
      writeFileSync(file, content);
    }
    const bundle = args.length ? path.join(root, "knowledge") : root;
    const extra = args.map((a) => (a === "<root>" ? root : a));
    const result = spawnSync(process.execPath, [validator, bundle, ...extra], {
      encoding: "utf8",
    });
    assert.ifError(result.error);
    return { status: result.status, output: result.stdout + result.stderr };
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
}

test("accepts nested relative links, references, fragments, queries and cycles", () => {
  const result = validate({
    "index.md":
      '[Topic](./topic/index.md "Topic")\n[External](https://example.com)\n[Email](mailto:reader@example.com)',
    "topic/index.md":
      "[Concept][concept]\n\n[concept]: <./a%20b.md?view=1#section>",
    "topic/a b.md": concept(
      "[Home](../index.md)\n[Section](#section)\n[View](?view=1)",
    ),
  });
  assert.equal(result.status, 0, result.output);
});

test("rejects bundle-root paths even when their targets exist", () => {
  const result = validate({
    "index.md": "[Concept](/concept.md)",
    "concept.md": concept("Text"),
  });
  assert.equal(result.status, 1, result.output);
  assert.match(
    result.output,
    /internal link must be file-relative: \/concept.md/,
  );
});

test("rejects missing targets including reference-style links", () => {
  const result = validate({
    "index.md": "[Missing][target]\n\n[target]: ./missing.md",
  });
  assert.equal(result.status, 1, result.output);
  assert.match(
    result.output,
    /internal link target is not a file: .\/missing.md/,
  );
});

test("rejects a directory as a link target", () => {
  const result = validate({
    "index.md": "[Topic](./topic)",
    "topic/index.md": "Topic",
  });
  assert.equal(result.status, 1, result.output);
  assert.match(result.output, /internal link target is not a file: .\/topic/);
});

test("rejects documents in a disconnected cycle", () => {
  const result = validate({
    "index.md": "Home",
    "a.md": concept("[B](./b.md)"),
    "b.md": concept("[A](./a.md)"),
  });
  assert.equal(result.status, 1, result.output);
  assert.match(result.output, /a\.md: unreachable from bundle index.md/);
  assert.match(result.output, /b\.md: unreachable from bundle index.md/);
});

test("ignores code examples and unused link definitions", () => {
  const result = validate({
    "index.md":
      "`[Example](/missing.md)`\n\n```md\n[Example](./missing.md)\n```\n\n[unused]: /missing.md",
  });
  assert.equal(result.status, 0, result.output);
});

test("uses the first definition when reference labels are repeated", () => {
  const result = validate({
    "index.md":
      "[Concept][target]\n\n[target]: ./concept.md\n[target]: /missing.md",
    "concept.md": concept("Text"),
  });
  assert.equal(result.status, 0, result.output);
});

test("rejects links outside the bundle, including encoded traversal", () => {
  const result = validate({ "index.md": "[Outside](./%2e%2e/outside.md)" });
  assert.equal(result.status, 1, result.output);
  assert.match(result.output, /internal link leaves project/);
});

test("reports invalid link encoding", () => {
  const result = validate({ "index.md": "[Invalid](./bad%ZZ.md)" });
  assert.equal(result.status, 1, result.output);
  assert.match(result.output, /invalid internal link encoding/);
});

test("requires a root index.md", () => {
  const result = validate({ "concept.md": concept("Text") });
  assert.equal(result.status, 1, result.output);
  assert.match(result.output, /missing bundle entry point/);
});

test("checks image targets without counting images as navigation", () => {
  const missing = validate({ "index.md": "![Image](./missing.png)" });
  assert.equal(missing.status, 1, missing.output);
  assert.match(missing.output, /internal link target is not a file/);

  const embedded = validate({
    "index.md": "![Concept](./concept.md)",
    "concept.md": concept("Text"),
  });
  assert.equal(embedded.status, 1, embedded.output);
  assert.match(
    embedded.output,
    /concept\.md: unreachable from bundle index.md/,
  );
});

const lean = `namespace Knowledge.Development

/-- 差分 -/
structure Artifact.Diff where
  before : Nat
  after : Nat

namespace PullRequest

def Fulfills : Prop := True

end PullRequest

end Knowledge.Development
`;

test("accepts links to project files outside the bundle with --project", () => {
  const result = validate(
    {
      "knowledge/index.md":
        "[Model](../src/Model.lean) [Notes](../NOTES.md) [`Artifact.Diff`](../src/Model.lean) [`Fulfills`](../src/Model.lean) [`Diff.before`](../src/Model.lean)",
      "src/Model.lean": lean,
      "NOTES.md": "Not part of the bundle",
    },
    ["--project", "<root>"],
  );
  assert.equal(result.status, 0, result.output);
});

test("rejects Lean names that the linked file does not declare", () => {
  const result = validate(
    {
      "knowledge/index.md":
        "[`Missing`](../src/Model.lean) [`Diff.middle`](../src/Model.lean)",
      "src/Model.lean": lean,
    },
    ["--project", "<root>"],
  );
  assert.equal(result.status, 1, result.output);
  assert.match(
    result.output,
    /Lean name not found in \.\.\/src\/Model\.lean: Missing/,
  );
  assert.match(
    result.output,
    /Lean name not found in \.\.\/src\/Model\.lean: Diff\.middle/,
  );
});

test("rejects links leaving the project", () => {
  const result = validate(
    { "knowledge/index.md": "[Outside](../../outside.md)" },
    ["--project", "<root>"],
  );
  assert.equal(result.status, 1, result.output);
  assert.match(result.output, /internal link leaves project/);
});
