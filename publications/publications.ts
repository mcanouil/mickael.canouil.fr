// @ts-nocheck
// Pre-render: convert publications/publications.bib to a CSL YAML feed
// (publications/publications.yml) and a Quarto listing page
// (publications/index.qmd) wired to assets/listing-templates/publications.ejs.
// Executed by Quarto's bundled Deno runtime; paths are relative to project root.
export {};

const AUTHOR_FAMILY = "Canouil";
const BIB_FILE = "publications/publications.bib";
const YML_FILE = "publications/publications.yml";
const QMD_FILE = "publications/index.qmd";

const BIB_TYPE_MAP: Record<string, string> = {
  article: "article",
  inproceedings: "conf",
  conference: "conf",
  proceedings: "conf",
  incollection: "chapter",
  inbook: "chapter",
  book: "chapter",
  misc: "preprint",
  unpublished: "preprint",
  techreport: "preprint",
  phdthesis: "chapter",
  mastersthesis: "chapter",
};

const MONTH_NAMES = [
  "",
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

interface RawFields {
  bibType: string;
  bibKey: string;
  raw: string;
  pdf?: string;
  code?: string;
  slides?: string;
}

interface CslAuthor {
  family?: string;
  given?: string;
  "dropping-particle"?: string;
  "non-dropping-particle"?: string;
  literal?: string;
}

function utf8Base64(s: string): string {
  const bytes = new TextEncoder().encode(s);
  let bin = "";
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin);
}

function shouldSkip(): boolean {
  const renderAll = Deno.env.get("QUARTO_PROJECT_RENDER_ALL") ?? "";
  const inputFiles = Deno.env.get("QUARTO_PROJECT_INPUT_FILES") ?? "";
  return renderAll === "" && inputFiles.includes("publications/index.qmd");
}

function splitRawEntries(bib: string): string[] {
  const parts = bib.split("\n@");
  return parts
    .map((p, i) => (i === 0 ? p : `@${p}`))
    .map((p) => p.trim())
    .filter((p) => p.startsWith("@"));
}

function parseRawFields(entry: string): RawFields {
  const header = /^@(\w+)\s*\{\s*([^,]+),/.exec(entry);
  const bibType = (header?.[1] ?? "misc").toLowerCase();
  const bibKey = (header?.[2] ?? "").trim();

  const fieldValue = (name: string): string | undefined => {
    const re = new RegExp(`^\\s*${name}\\s*=\\s*\\{([\\s\\S]*?)\\}\\s*,?\\s*$`, "im");
    const match = re.exec(entry);
    return match ? match[1].trim().replace(/\s+/g, " ") : undefined;
  };

  const cleanedRaw = entry.replace(
    /^\s*annote\s*=\s*\{[\s\S]*?\}\s*,?\s*\n/gim,
    "",
  );

  return {
    bibType,
    bibKey,
    raw: cleanedRaw,
    pdf: fieldValue("pdf"),
    code: fieldValue("code"),
    slides: fieldValue("slides"),
  };
}

async function pandocAll(bibPath: string): Promise<string> {
  const cmd = new Deno.Command("quarto", {
    args: ["pandoc", bibPath, "--standalone", "--from=bibtex", "--to=markdown"],
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await cmd.output();
  if (code !== 0) {
    const err = new TextDecoder().decode(stderr);
    throw new Error(`quarto pandoc failed (${code}): ${err}`);
  }
  return new TextDecoder().decode(stdout);
}

function splitCslEntries(pandocOut: string): string[][] {
  const lines = pandocOut.split("\n");
  while (lines.length && lines[lines.length - 1] === "") lines.pop();
  const startIdx = lines.findIndex((l) => l === "references:");
  const endIdx = lines.length - 1;
  if (startIdx < 0 || lines[endIdx] !== "---") {
    throw new Error(
      `Unexpected pandoc CSL output structure (got ${lines.length} lines, head: ${JSON.stringify(lines.slice(0, 3))}).`,
    );
  }
  const body = lines.slice(startIdx + 1, endIdx);

  const entries: string[][] = [];
  let current: string[] = [];
  for (const line of body) {
    if (line.startsWith("- ")) {
      if (current.length) entries.push(current);
      current = [`  ${line.slice(2)}`];
    } else {
      current.push(line);
    }
  }
  if (current.length) entries.push(current);
  return entries;
}

function findLine(lines: string[], needle: string): string | undefined {
  return lines.find((l) => l.includes(needle));
}

function parseAuthors(lines: string[]): CslAuthor[] {
  const authors: CslAuthor[] = [];
  let inAuthor = false;
  let cur: CslAuthor | null = null;

  const propRe = /^\s+(family|given|dropping-particle|non-dropping-particle|literal):\s*(.+?)\s*$/;

  for (const line of lines) {
    if (/^\s+author:\s*$/.test(line)) {
      inAuthor = true;
      continue;
    }
    if (!inAuthor) continue;

    if (/^\s+-\s+/.test(line)) {
      if (cur) authors.push(cur);
      cur = {};
      const m = /^\s+-\s+(family|given|dropping-particle|non-dropping-particle|literal):\s*(.+?)\s*$/.exec(line);
      if (m) (cur as Record<string, string>)[m[1]] = m[2];
      continue;
    }

    const pm = propRe.exec(line);
    if (pm && cur) {
      (cur as Record<string, string>)[pm[1]] = pm[2];
      continue;
    }

    if (/^  \w[\w-]*:/.test(line)) {
      if (cur) authors.push(cur);
      cur = null;
      inAuthor = false;
    }
  }
  if (cur) authors.push(cur);
  return authors;
}

function authorPosition(authors: CslAuthor[]): string {
  const total = authors.length;
  const idx = authors.findIndex((a) => (a.family || "").trim() === AUTHOR_FAMILY);
  return `${idx + 1}/${total}`;
}

function annoteFlag(lines: string[], keyword: string): boolean {
  const annote = findLine(lines, "annote:");
  if (!annote) return false;
  const re = new RegExp(`\\b${keyword}\\b`);
  return re.test(annote);
}

function extractYear(lines: string[]): string {
  const issued = lines.find((l) => /^\s*issued:/.test(l));
  const m = issued ? /(\d{4})/.exec(issued) : null;
  return m?.[1] ?? "";
}

function formatIssuedLabel(lines: string[]): string {
  const issued = lines.find((l) => /^\s*issued:/.test(l));
  if (!issued) return "";
  const m = /(\d{4})(?:-(\d{1,2}))?/.exec(issued);
  if (!m) return "";
  const year = m[1];
  const monthIdx = m[2] ? parseInt(m[2], 10) : NaN;
  const month = Number.isFinite(monthIdx) ? MONTH_NAMES[monthIdx] : "";
  return month ? `${month} ${year}` : year;
}

function processEntry(rawCsl: string[], rawFields: RawFields): {
  cslLines: string[];
  hasFlag: boolean;
} {
  const journal = findLine(rawCsl, "  container-title:");
  const issued = findLine(rawCsl, "  issued:");
  const doi = findLine(rawCsl, "  doi:");

  const journalLine = journal
    ? journal.replace(/  container-title: (.*)/, "  journal-title: '*$1*'")
    : undefined;
  const dateLine = issued ? issued.replace("  issued: ", "  date: ") : undefined;
  const pathLine = doi ? doi.replace(/  doi: /, "  path: https://doi.org/") : undefined;

  const authors = parseAuthors(rawCsl);
  const position = authorPosition(authors);
  const isFirst = annoteFlag(rawCsl, "first");
  const isLast = annoteFlag(rawCsl, "last");

  const year = extractYear(rawCsl);
  const dateLabel = formatIssuedLabel(rawCsl);
  const bibtypeLabel = BIB_TYPE_MAP[rawFields.bibType] ?? "article";

  const extras: string[] = [];
  if (journalLine) extras.push(journalLine);
  if (dateLine) extras.push(dateLine);
  if (pathLine) extras.push(pathLine);
  extras.push(`  position: '${position}'`);
  if (isFirst) extras.push("  first: '*As first or co-first*'");
  if (isLast) extras.push("  last: '*As last or co-last*'");
  if (year) extras.push(`  year: '${year}'`);
  if (dateLabel) extras.push(`  pub-date-label: '${dateLabel}'`);
  extras.push(`  bibtype: ${bibtypeLabel}`);
  extras.push(`  bibkey: ${rawFields.bibKey}`);
  extras.push(`  bibtex: ${utf8Base64(rawFields.raw)}`);
  extras.push(`  pub-author: ${utf8Base64(JSON.stringify(authors))}`);
  if (rawFields.pdf) extras.push(`  pdf-url: ${rawFields.pdf}`);
  if (rawFields.code) extras.push(`  code-url: ${rawFields.code}`);
  if (rawFields.slides) extras.push(`  slides-url: ${rawFields.slides}`);

  const out = [...rawCsl];
  out[0] = out[0].replace(/^  /, "- ");

  return {
    cslLines: [...out, ...extras],
    hasFlag: isFirst || isLast,
  };
}

function buildQmd(flagged: number, middle: number): string {
  return [
    "---",
    `title: 'Publications (${flagged} + ${middle})'`,
    "title-block-banner: true",
    "image: /assets/images/social-profile.png",
    "date-format: 'MMMM,<br>YYYY'",
    "body-classes: publications-page",
    "toc: true",
    "listing:",
    "  - id: publications",
    "    contents:",
    "      - publications.yml",
    "    template: ../assets/listing-templates/publications.ejs",
    "    page-size: 1000",
    "    sort: 'issued desc'",
    "    categories: false",
    "    sort-ui: false",
    "    filter-ui: false",
    "---",
    "",
    "::: {#publications}",
    ":::",
    "",
  ].join("\n");
}

async function main(): Promise<void> {
  if (shouldSkip()) return;

  const bib = await Deno.readTextFile(BIB_FILE);
  const rawEntries = splitRawEntries(bib);
  const pandocOut = await pandocAll(BIB_FILE);
  const cslEntries = splitCslEntries(pandocOut);

  if (rawEntries.length !== cslEntries.length) {
    throw new Error(
      `Entry count mismatch: ${rawEntries.length} bib vs ${cslEntries.length} CSL.`,
    );
  }

  const processed = rawEntries.map((raw, i) =>
    processEntry(cslEntries[i], parseRawFields(raw)),
  );

  const yml = processed.flatMap((p) => p.cslLines).join("\n") + "\n";
  await Deno.writeTextFile(YML_FILE, yml);

  const flagged = processed.filter((p) => p.hasFlag).length;
  const middle = processed.length - flagged;
  await Deno.writeTextFile(QMD_FILE, buildQmd(flagged, middle));
}

await main();
