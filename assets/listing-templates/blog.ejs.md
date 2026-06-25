<%
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

function renderThumb(item, klass) {
  const inner = item.image
    ? `<img src="${item.image}" alt="" loading="lazy">`
    : `<span class="blog-thumb-fallback" aria-hidden="true">M</span>`;
  return `<a class="${klass}" href="${item.path}" aria-hidden="true" tabindex="-1">${inner}</a>`;
}

function renderCategories(item) {
  if (!item.categories || !item.categories.length) return "";
  const chips = item.categories
    .map((c) => `<span class="blog-category" onclick="window.quartoListingCategory('${utils.b64encode(c)}'); return false;">${c}</span>`)
    .join("");
  return `<div class="blog-categories">${chips}</div>`;
}
%>

```{=html}
<div class="list blog-list">
<% items.forEach((item, i) => { %>
<% if (i === 0) { %>
  <article class="blog-hero" <%= metadataAttrs(item) %>>
    <%= renderThumb(item, "blog-hero-thumb") %>
    <div class="blog-hero-meta">
      <div class="blog-hero-eyebrow">
        <span class="blog-hero-badge">Latest</span>
        <time class="blog-date" datetime="<%= item.date %>"><%= item.date %></time>
      </div>
      <a class="blog-title-link" href="<%- item.path %>">
        <h2 class="blog-hero-title no-anchor">
```

<%= item.title %>

```{=html}
        </h2>
      </a>
<% if (item.description) { %>
      <div class="blog-hero-lead">
```

<%= item.description %>

```{=html}
      </div>
<% } %>
      <%= renderCategories(item) %>
    </div>
  </article>
<% } else { %>
  <article class="blog-row blog-row--compact" <%= metadataAttrs(item) %>>
    <%= renderThumb(item, "blog-thumb") %>
    <div class="blog-meta">
      <time class="blog-date" datetime="<%= item.date %>"><%= item.date %></time>
      <a class="blog-title-link" href="<%- item.path %>">
        <h3 class="blog-title no-anchor">
```

<%= item.title %>

```{=html}
        </h3>
      </a>
<% if (item.description) { %>
      <div class="blog-lead">
```

<%= item.description %>

```{=html}
      </div>
<% } %>
      <%= renderCategories(item) %>
    </div>
  </article>
<% } %>
<% }) %>
</div>
```
