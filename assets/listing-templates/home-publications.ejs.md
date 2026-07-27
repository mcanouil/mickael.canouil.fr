<%
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

// =============================================================================
// Home page — a hand-picked shortlist of publications. Reads
// `publications/publications.yml`, the same file the publications page uses, so
// the citation data lives in one place; only the choice of entries lives here.
// Edit `FEATURED` to change which papers the home page shows, in display order.
// The title helpers mirror `publications.ejs.md`: EJS templates cannot share
// code, so the small ones are repeated rather than the data.
// =============================================================================

const FEATURED = [
  "burrows_framework_2024",
  "canouil_epigenome-wide_2021",
  "canouil_nacho_2020",
  "canouil_jointly_2018",
];

function escapeHtml(s) {
  return String(s == null ? "" : s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function stripStars(s) {
  return String(s == null ? "" : s).replace(/\*/g, "");
}

function titleCase(s) {
  return String(s == null ? "" : s).replace(/(^|[\s\-\(\[\{:;])([a-z])/g, (_, sep, c) => sep + c.toUpperCase());
}

// BibTeX titles carry `[nCounter]{.nocase}` spans that protect casing. Mask
// them before title-casing, then restore them verbatim, so the markup never
// reaches the page and the protected words keep their own capitalisation.
function formatTitle(raw) {
  const protected_ = [];
  const masked = stripStars(raw).replace(/\[([^\]]*)\]\{\.nocase\}/g, (_, inner) => {
    protected_.push(inner);
    return `@@${protected_.length - 1}@@`;
  });
  return titleCase(masked).replace(/@@(\d+)@@/g, (_, i) => protected_[Number(i)]);
}

function getYear(item) {
  if (item.year) return String(item.year);
  if (item.issued) return String(item.issued).split("-")[0];
  return "";
}

// `position` is "rank/total", so it separates a sole first or last author from a
// shared one; `first` and `last` alone only say "first or co-first".
function authorMark(item) {
  const [rank, total] = String(item.position || "").split("/").map(Number);
  const isLast = String(item.last || "").includes("last");
  const isFirst = String(item.first || "").includes("first");
  if (isLast) return rank && total && rank === total ? "Last author" : "Co-last author";
  if (isFirst) return rank === 1 ? "First author" : "Co-first author";
  return "";
}

const byKey = new Map(items.map((item) => [item.bibkey, item]));
const entries = FEATURED.map((key) => byKey.get(key)).filter(Boolean);
%>

```{=html}
<ol class="list home-pubs">
```
<% entries.forEach((item) => {
  const href = item.doi ? `https://doi.org/${item.doi}` : (item.url || item.path || "");
  const journal = stripStars(item["journal-title"] || item["container-title"] || "");
  const mark = authorMark(item);
  const year = getYear(item);
%>
```{=html}
  <li class="home-pub" <%= metadataAttrs(item) %>>
    <div class="home-pub-head">
<% if (mark) { %>      <span class="home-pub-mark"><%= mark %></span>
<% } %>      <time class="home-pub-year"><%= year %></time>
    </div>
<% if (href) { %>    <a class="home-pub-title" href="<%= escapeHtml(href) %>" target="_blank" rel="noopener noreferrer"><%= escapeHtml(formatTitle(item.title)) %></a>
<% } else { %>    <span class="home-pub-title"><%= escapeHtml(formatTitle(item.title)) %></span>
<% } %>
<% if (journal) { %>    <span class="home-pub-venue"><%= escapeHtml(journal) %></span>
<% } %>  </li>
```
<% }); %>
```{=html}
</ol>
```
