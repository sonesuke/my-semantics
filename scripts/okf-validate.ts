// Validate an OKF v0.2 bundle against the conformance rules (SPEC §7):
//   1. Every non-reserved .md file has parseable YAML frontmatter.
//   2. Every frontmatter block has a non-empty `type`.
//   3. index.md has no frontmatter, except `okf_version` at the bundle root.
//   4. log.md has no frontmatter and its date headings are newest-first.
// Repository rules (in addition to OKF conformance):
//   5. Internal links are file-relative and point to existing files inside the
//      project root (--project, default: the bundle root).
//   6. A link whose text is inline code and whose target is a .lean file names
//      a declaration or structure field of that file.
//   7. Every Markdown document is reachable from the root index.md.

import { readFile, readdir, stat } from "node:fs/promises";
import path from "node:path";
import { fromMarkdown } from "mdast-util-from-markdown";
import { parse } from "yaml";

const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/;
const DATE_HEADING = /^#+\s+(\d{4}-\d{2}-\d{2})\s*$/gm;

async function* walk(dir: string): AsyncGenerator<string> {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(p);
    else if (entry.name.endsWith(".md")) yield p;
  }
}

function frontmatter(text: string): string | null {
  return FRONTMATTER.exec(text)?.[1] ?? null;
}

function isMapping(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function checkConcept(text: string): string[] {
  const raw = frontmatter(text);
  if (raw === null) return ["missing YAML frontmatter"];
  let data: unknown;
  try {
    data = parse(raw);
  } catch (e) {
    return [`unparseable frontmatter: ${(e as Error).message}`];
  }
  if (!isMapping(data)) return ["frontmatter is not a mapping"];
  if (typeof data.type !== "string" || data.type.trim() === "") {
    return ["`type` is missing or empty"];
  }
  return [];
}

function checkIndex(text: string, isRoot: boolean): string[] {
  const raw = frontmatter(text);
  if (raw === null) return [];
  if (!isRoot) return ["non-root index.md must not have frontmatter"];
  const data: unknown = parse(raw) ?? {};
  if (!isMapping(data)) return ["frontmatter is not a mapping"];
  const extra = Object.keys(data).filter((k) => k !== "okf_version");
  return extra.length
    ? [`root index.md has disallowed keys: ${extra.join(", ")}`]
    : [];
}

function checkLog(text: string): string[] {
  const errors: string[] = [];
  if (frontmatter(text) !== null) {
    errors.push("log.md must not have frontmatter");
  }
  const dates = [...text.matchAll(DATE_HEADING)].map((m) => m[1]);
  if (dates.join() !== [...dates].sort().reverse().join()) {
    errors.push("date headings are not newest-first");
  }
  return errors;
}

function check(file: string, text: string, root: string): string[] {
  switch (path.basename(file)) {
    case "index.md":
      return checkIndex(text, path.dirname(file) === path.normalize(root));
    case "log.md":
      return checkLog(text);
    default:
      return checkConcept(text);
  }
}

type MarkdownNode = {
  type: string;
  url?: string;
  value?: string;
  identifier?: string;
  children?: MarkdownNode[];
};

// Fully qualified names of the declarations and structure fields of a Lean file.
function leanNames(source: string): string[] {
  const names: string[] = [];
  const namespaces: string[] = [];
  let structure: string | null = null;
  const code = source.replace(/\/-[\s\S]*?-\//g, "").replace(/--.*$/gm, "");
  for (const line of code.split("\n")) {
    const ns = /^namespace\s+(\S+)/.exec(line);
    const decl =
      /^(?:@\[[^\]]*\]\s*)?(?:(?:private|protected|noncomputable)\s+)*(structure|inductive|class|def|abbrev|theorem|axiom|opaque)\s+([^\s({:[]+)/.exec(
        line,
      );
    const field = /^\s+([\w']+)\s*:/.exec(line);
    if (ns) {
      namespaces.push(ns[1]);
    } else if (/^end(\s|$)/.test(line)) {
      namespaces.pop();
      structure = null;
    } else if (decl) {
      const name = [...namespaces, decl[2]].join(".");
      names.push(name);
      structure = decl[1] === "structure" || decl[1] === "class" ? name : null;
    } else if (field && structure) {
      names.push(`${structure}.${field[1]}`);
    } else if (/^\S/.test(line)) {
      structure = null;
    }
  }
  return names;
}

function* nodes(node: MarkdownNode): Generator<MarkdownNode> {
  yield node;
  for (const child of node.children ?? []) yield* nodes(child);
}

async function checkLinks(
  file: string,
  text: string,
  root: string,
  project: string,
): Promise<{ errors: string[]; targets: string[] }> {
  const errors: string[] = [];
  const targets: string[] = [];
  const tree = [...nodes(fromMarkdown(text.replace(FRONTMATTER, "")))];
  const definitions = new Map<string | undefined, string | undefined>();
  for (const node of tree) {
    if (node.type === "definition" && !definitions.has(node.identifier)) {
      definitions.set(node.identifier, node.url);
    }
  }
  for (const node of tree) {
    if (
      !["link", "image", "linkReference", "imageReference"].includes(node.type)
    ) {
      continue;
    }
    const url = node.url ?? definitions.get(node.identifier);
    if (!url || /^(?:[a-z][a-z\d+.-]*:|\/\/|#)/i.test(url)) continue;
    if (url.startsWith("/")) {
      errors.push(`internal link must be file-relative: ${url}`);
      continue;
    }
    let target: string;
    try {
      target = path.resolve(
        path.dirname(file),
        decodeURIComponent(url.split(/[?#]/)[0]) || path.basename(file),
      );
    } catch {
      errors.push(`invalid internal link encoding: ${url}`);
      continue;
    }
    const relative = path.relative(project, target);
    if (relative === ".." || relative.startsWith(`..${path.sep}`)) {
      errors.push(`internal link leaves project: ${url}`);
      continue;
    }
    const exists = await stat(target).then(
      (info) => info.isFile(),
      () => false,
    );
    const code = node.children?.length === 1 ? node.children[0] : undefined;
    if (!exists) {
      errors.push(`internal link target is not a file: ${url}`);
    } else if (target.endsWith(".lean") && code?.type === "inlineCode") {
      const name = code.value ?? "";
      const found = leanNames(await readFile(target, "utf8")).some(
        (n) => n === name || n.endsWith(`.${name}`),
      );
      if (!found) errors.push(`Lean name not found in ${url}: ${name}`);
    } else if (
      (node.type === "link" || node.type === "linkReference") &&
      target.endsWith(".md") &&
      !path.relative(root, target).startsWith("..")
    ) {
      targets.push(target);
    }
  }
  return { errors, targets };
}

const args = process.argv.slice(2);
const projectFlag = args.indexOf("--project");
const projectArg =
  projectFlag === -1 ? undefined : args.splice(projectFlag, 2)[1];
const roots = args;
if (roots.length === 0) roots.push("knowledge");

let failures = 0;
for (const root of roots) {
  const bundleRoot = path.resolve(root);
  const project = path.resolve(projectArg ?? root);
  const graph = new Map<string, string[]>();
  for await (const file of walk(bundleRoot)) {
    const text = await readFile(file, "utf8");
    const links = await checkLinks(file, text, bundleRoot, project);
    graph.set(file, links.targets);
    const errors = [...check(file, text, bundleRoot), ...links.errors];
    for (const err of errors) console.error(`${file}: ${err}`);
    failures += errors.length;
  }
  const entry = path.join(bundleRoot, "index.md");
  if (!graph.has(entry)) {
    console.error(`${entry}: missing bundle entry point`);
    failures++;
  }
  const reachable = new Set<string>();
  const pending = [entry];
  while (pending.length) {
    const file = pending.pop()!;
    if (reachable.has(file)) continue;
    reachable.add(file);
    pending.push(...(graph.get(file) ?? []));
  }
  for (const file of graph.keys()) {
    if (!reachable.has(file)) {
      console.error(`${file}: unreachable from bundle index.md`);
      failures++;
    }
  }
}

if (failures) {
  console.error(`OKF validation failed: ${failures} error(s)`);
  process.exit(1);
}
console.log("OKF validation passed");
