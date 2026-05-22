-- Replace the contents of the `[]{#current-year}` placeholder with the
-- current four-digit year. Used by the page footer to keep the copyright
-- line up to date without client-side JS.
--
-- Previously this was done client-side with:
--   document.getElementById('current-year').textContent = new Date().getFullYear();
-- Replaced with this filter to drop the JS dependency and avoid the brief
-- empty span before DOMContentLoaded; the year is now baked in at render time.

local YEAR = os.date("%Y")

function Span(el)
  if el.identifier == "current-year" then
    el.content = { pandoc.Str(YEAR) }
    return el
  end
end
