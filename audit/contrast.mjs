import { hex, score } from 'wcag-contrast';

function hexToRgb(h) {
  const s = h.replace('#', '');
  const n = parseInt(s.length === 3 ? s.split('').map((c) => c + c).join('') : s, 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

function rgbToHex(rgb) {
  return '#' + rgb.map((v) => Math.round(v).toString(16).padStart(2, '0')).join('');
}

function alphaOver(fgHex, bgHex, alpha) {
  const fg = hexToRgb(fgHex);
  const bg = hexToRgb(bgHex);
  return rgbToHex(fg.map((c, i) => alpha * c + (1 - alpha) * bg[i]));
}

function darken(h, pct) {
  const rgb = hexToRgb(h);
  const f = 1 - pct / 100;
  return rgbToHex(rgb.map((c) => c * f));
}

function mix(aHex, bHex, ratio) {
  const a = hexToRgb(aHex);
  const b = hexToRgb(bHex);
  return rgbToHex(a.map((c, i) => (ratio / 100) * c + (1 - ratio / 100) * b[i]));
}

const MC_INK = '#111827';
const MC_ACCENT = '#b5830a';
const MC_ACCENT_LINK = '#876208';
const MC_MUTED = '#6b7280';
const MC_PAPER = '#fafafa';
const MC_PAPER_WARM = '#f7f4ec';

const DARK_TEXT = '#f5f5f4';
const DARK_BG = '#161616';

const LIGHT_LINK_HOVER = darken(MC_ACCENT_LINK, 10);
const NAV_LINK_HOVER_LIGHTEN = '#cd9b22';

const pairs = [
  ['Body text (light)', MC_INK, MC_PAPER, 'normal'],
  ['Muted text (light)', MC_MUTED, MC_PAPER, 'normal'],
  ['Link on paper (light, $mc-accent-link)', MC_ACCENT_LINK, MC_PAPER, 'normal'],
  ['Link hover on paper (light, darken 10%)', LIGHT_LINK_HOVER, MC_PAPER, 'normal'],
  ['Navbar/footer accent on ink', MC_ACCENT, MC_INK, 'normal'],
  ['Navbar nav-link hover (lighten 12%)', NAV_LINK_HOVER_LIGHTEN, MC_INK, 'normal'],
  ['Body text (dark)', DARK_TEXT, DARK_BG, 'normal'],
  ['Link on dark bg ($mc-accent-link = $mc-accent)', MC_ACCENT, DARK_BG, 'normal'],

  ['Callout: note (light)', '#0066cc', mix('#0066cc', MC_PAPER, 15), 'normal'],
  ['Callout: tip (light)', '#009955', mix('#009955', MC_PAPER, 15), 'normal'],
  ['Callout: warning (light)', '#cc6600', mix('#cc6600', MC_PAPER, 15), 'normal'],
  ['Callout: important (light)', '#cc0000', mix('#cc0000', MC_PAPER, 15), 'normal'],
  ['Callout: caution (light)', '#b38f00', mix('#b38f00', MC_PAPER, 15), 'normal'],

  ['Callout: note (dark)', '#66aaff', mix('#66aaff', DARK_BG, 15), 'normal'],
  ['Callout: tip (dark)', '#66cc99', mix('#66cc99', DARK_BG, 15), 'normal'],
  ['Callout: warning (dark)', '#ffaa44', mix('#ffaa44', DARK_BG, 15), 'normal'],
  ['Callout: important (dark)', '#ff6666', mix('#ff6666', DARK_BG, 15), 'normal'],
  ['Callout: caution (dark)', '#ddcc66', mix('#ddcc66', DARK_BG, 15), 'normal'],

  ['Pub badge: article (light, $semantic-text-info)', '#0055b3', alphaOver('#0066cc', MC_PAPER, 0.08), 'normal'],
  ['Pub badge: preprint (light, $semantic-text-warning)', '#964c00', alphaOver('#cc6600', MC_PAPER, 0.08), 'normal'],
  ['Pub badge: chapter (light, $semantic-text-success)', '#00723f', alphaOver('#009955', MC_PAPER, 0.08), 'normal'],
  ['Pub badge: conf (light, $semantic-text-caution)', '#7a6300', alphaOver('#b38f00', MC_PAPER, 0.10), 'normal'],
  ['Pub badge: article (dark, $semantic-text-info)', '#66aaff', alphaOver('#0066cc', DARK_BG, 0.08), 'normal'],
  ['Pub badge: preprint (dark, $semantic-text-warning)', '#ffaa44', alphaOver('#cc6600', DARK_BG, 0.08), 'normal'],
  ['Pub badge: chapter (dark, $semantic-text-success)', '#66cc99', alphaOver('#009955', DARK_BG, 0.08), 'normal'],
  ['Pub badge: conf (dark, $semantic-text-caution)', '#ddcc66', alphaOver('#b38f00', DARK_BG, 0.10), 'normal'],

  ['.pub-chip resting (light, alpha 0.78)', alphaOver(MC_INK, MC_PAPER, 0.78), alphaOver(MC_INK, MC_PAPER, 0.06), 'normal'],
  ['.pub-chip resting (dark, alpha 0.78)', alphaOver(DARK_TEXT, DARK_BG, 0.78), alphaOver(DARK_TEXT, DARK_BG, 0.06), 'normal'],
  ['.pub-chip focus (light, $mc-accent-link)', MC_ACCENT_LINK, alphaOver(MC_ACCENT_LINK, MC_PAPER, 0.12), 'normal'],
  ['.pub-chip focus (dark, $mc-accent)', MC_ACCENT, alphaOver(MC_ACCENT, DARK_BG, 0.12), 'normal'],

  ['Featured hero text on accent', '#ffffff', MC_ACCENT, 'large'],
];

const TARGETS = { normal: 4.5, large: 3.0 };

console.log(['name', 'fg', 'bg', 'ratio', 'target', 'AA pass', 'WCAG score'].join('\t'));
for (const [name, fg, bg, kind] of pairs) {
  const ratio = hex(fg, bg);
  const target = TARGETS[kind];
  const pass = ratio >= target ? 'PASS' : 'FAIL';
  console.log([name, fg, bg, ratio.toFixed(2), target, pass, score(ratio)].join('\t'));
}
