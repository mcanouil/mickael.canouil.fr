<%
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

// =============================================================================
// Home page — featured projects as a static three-card grid. The projects page
// carousel (projects.ejs.md) clones slides for its auto-loop, so it cannot be
// reused here; the landing page wants a calm, complete row instead.
// Items come from projects/projects.yml, already sorted date-descending.
// =============================================================================

const CARD_LIMIT = 3;
const cards = items.filter((item) => item.featured === true).slice(0, CARD_LIMIT);
%>

```{=html}
<div class="list home-cards">
```
<% cards.forEach((item) => { %>
```{=html}
  <a class="home-card" href="<%- item.path %>" target="_blank" rel="noopener noreferrer" <%= metadataAttrs(item) %>>
    <div class="home-card-thumb">
<% if (item.image) { %>      <img src="<%= item.image %>" alt="" loading="lazy">
<% } %>    </div>
    <h3 class="home-card-title no-anchor">
```

<%= item.title %>

```{=html}
    </h3>
    <div class="home-card-description">
```

<%= item.description %>

```{=html}
    </div>
  </a>
```
<% }); %>
```{=html}
</div>
```
