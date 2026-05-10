import puppeteer from 'puppeteer';
import { readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const axePath = require.resolve('axe-core/axe.min.js');
const AXE = readFileSync(axePath, 'utf8');

const BRAVE = '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser';
const BASE = 'http://localhost:8080';

const URLS = [
  ['index', '/index.html'],
  ['blog', '/blog.html'],
  ['post-typst-dispatcher', '/posts/2026-01-19-typst-document-dispatcher/index.html'],
  ['post-ggpacman', '/posts/2020-05-06-ggpacman/index.html'],
  ['projects', '/projects/index.html'],
  ['publications', '/publications/index.html'],
  ['talks', '/talks/index.html'],
];

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice'];

const mode = process.argv[2] || 'light';

const browser = await puppeteer.launch({
  executablePath: BRAVE,
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});

const aggregate = { mode, runs: {} };

for (const [name, path] of URLS) {
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900 });

  if (mode === 'dark') {
    await page.emulateMediaFeatures([{ name: 'prefers-color-scheme', value: 'dark' }]);
    await page.evaluateOnNewDocument(() => {
      try {
        localStorage.setItem('quarto-color-scheme', 'dark');
      } catch (e) {}
    });
  }

  const url = BASE + path;
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await page.waitForSelector('body', { timeout: 10000 });
  await new Promise((r) => setTimeout(r, 800));

  if (mode === 'dark') {
    await page.evaluate(() => {
      if (typeof window.toggleColorMode === 'function') {
        window.toggleColorMode(true);
      } else {
        document.documentElement.setAttribute('data-bs-theme', 'dark');
        document.body.classList.add('quarto-dark');
        document.body.classList.remove('quarto-light');
      }
    });
    await new Promise((r) => setTimeout(r, 600));
  }

  await page.evaluate(AXE);
  const results = await page.evaluate(
    async (tags) => {
      const r = await window.axe.run(document, { runOnly: { type: 'tag', values: tags } });
      return r;
    },
    TAGS,
  );

  aggregate.runs[name] = {
    url,
    violations: results.violations.map((v) => ({
      id: v.id,
      impact: v.impact,
      help: v.help,
      helpUrl: v.helpUrl,
      tags: v.tags,
      nodes: v.nodes.map((n) => ({
        target: n.target,
        html: String(n.html || '').slice(0, 240),
        failureSummary: n.failureSummary,
      })),
    })),
    incomplete: results.incomplete.map((v) => ({
      id: v.id,
      impact: v.impact,
      nodeCount: v.nodes.length,
    })),
    passCount: results.passes.length,
  };
  await page.close();
}

await browser.close();
writeFileSync(`audit-${mode}.json`, JSON.stringify(aggregate, null, 2));

let total = 0;
for (const [name, r] of Object.entries(aggregate.runs)) {
  console.log(`[${mode}] ${name}: ${r.violations.length} violations, ${r.incomplete.length} incomplete, ${r.passCount} passes`);
  total += r.violations.length;
}
console.log(`[${mode}] TOTAL: ${total} violations across ${URLS.length} URLs`);
