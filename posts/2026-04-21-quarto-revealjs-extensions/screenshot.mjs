import { launch } from '/opt/homebrew/lib/node_modules/decktape/node_modules/puppeteer/lib/esm/puppeteer/puppeteer.js';

const CHROME = '/Users/mcanouil/.cache/puppeteer/chrome/mac_arm-147.0.7727.56/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing';
const HTML   = new URL('./featured.html', import.meta.url).pathname;
const OUT    = new URL('./featured.png',  import.meta.url).pathname;

const browser = await launch({
  executablePath: CHROME,
  headless: true,
  args: ['--no-sandbox', '--disable-gpu'],
});
const page = await browser.newPage();
await page.setViewport({ width: 1200, height: 630, deviceScaleFactor: 2 });
await page.goto(`file://${HTML}`, { waitUntil: 'networkidle0' });
await page.screenshot({ path: OUT, clip: { x: 0, y: 0, width: 1200, height: 630 } });
await browser.close();
console.log('written:', OUT);
