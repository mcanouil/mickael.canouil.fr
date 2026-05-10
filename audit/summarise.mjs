import { readFileSync } from 'node:fs';

for (const mode of ['light', 'dark']) {
  const data = JSON.parse(readFileSync(`audit-${mode}.json`, 'utf8'));
  console.log(`\n## ${mode.toUpperCase()}`);
  for (const [name, run] of Object.entries(data.runs)) {
    console.log(`\n### ${name}  ${run.url}`);
    for (const v of run.violations) {
      console.log(`- [${v.impact}] ${v.id}  (${v.nodes.length} nodes)  ${v.help}`);
      for (const n of v.nodes.slice(0, 3)) {
        console.log(`  · target: ${n.target.join(' >> ')}`);
        console.log(`    html: ${n.html.replace(/\n/g, ' ').slice(0, 180)}`);
        const summary = (n.failureSummary || '').replace(/\n/g, ' ').slice(0, 220);
        console.log(`    why: ${summary}`);
      }
      if (v.nodes.length > 3) console.log(`  · …+${v.nodes.length - 3} more nodes`);
    }
  }
}
