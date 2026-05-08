-- Add stable class hooks used by the editorial-luxury rules in _rules.scss.
-- Currently:
--   - Wrap the first paragraph inside a `.about-body` div in a Div with class
--     `.lead-drop`, so the drop-cap rule has a deterministic target (avoiding
--     browser quirks with ::first-letter on adjacent block siblings).

local function has_class(classes, target)
  if not classes then return false end
  for _, c in ipairs(classes) do
    if c == target then return true end
  end
  return false
end

local function wrap_first_para(blocks)
  for i, block in ipairs(blocks) do
    if block.t == "Para" then
      blocks[i] = pandoc.Div({ block }, pandoc.Attr("", { "lead-drop" }, {}))
      return blocks
    end
  end
  return blocks
end

function Div(el)
  if has_class(el.classes, "about-body") then
    el.content = wrap_first_para(el.content)
    return el
  end
end
