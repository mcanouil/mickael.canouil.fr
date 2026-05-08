<%
// =============================================================================
// Talks listing — year-grouped list. Most recent year first.
// =============================================================================
function getYear(item) {
  const d = item.date ? new Date(item.date) : null;
  return d && !isNaN(d) ? String(d.getFullYear()) : "Undated";
}

const grouped = {};
for (const it of items) {
  const y = getYear(it);
  if (!grouped[y]) grouped[y] = [];
  grouped[y].push(it);
}
const years = Object.keys(grouped).sort((a, b) => b.localeCompare(a));
%>

<% years.forEach(year => {
  const list = grouped[year];
%>

```{=html}
<section id="talks-<%= year %>" class="talks-section">
  <h2 class="talks-year-header">
    <span class="talks-year"><%= year %></span>
    <span class="talks-year-count"><%= list.length %></span>
  </h2>
  <ul class="talks-list">
<% list.forEach(item => { %>
    <li class="talks-row" <%= metadataAttrs(item) %>>
      <a class="talks-link" href="<%- item.path %>">
        <span class="talks-title"><%= item.title %></span>
<% if (item.description) { %>
        <span class="talks-description"><%= item.description %></span>
<% } %>
      </a>
      <time class="talks-date" datetime="<%= item.date %>"><%= item.date %></time>
<% if (item.categories && item.categories.length) { %>
      <div class="talks-categories">
<% for (const category of item.categories) { %>
        <span class="talks-category" onclick="window.quartoListingCategory('<%= utils.b64encode(category) %>'); return false;"><%= category %></span>
<% } %>
      </div>
<% } %>
    </li>
<% }); %>
  </ul>
</section>
```

<% }); %>
