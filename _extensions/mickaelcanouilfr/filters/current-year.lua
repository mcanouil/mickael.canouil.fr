-- Replace the contents of the `[]{#current-year}` placeholder with the
-- current four-digit year. Used by the page footer to keep the copyright
-- line up to date without client-side JS.

local YEAR = os.date("%Y")

function Span(el)
  if el.identifier == "current-year" then
    el.content = { pandoc.Str(YEAR) }
    return el
  end
end
