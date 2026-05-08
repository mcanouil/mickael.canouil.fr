-- Add stable class hooks used by the editorial-luxury rules in _rules.scss.
-- Currently:
--   - `.lead-drop` on the first paragraph inside a `.about-body` div, so the
--     drop cap rule has a deterministic target (avoiding browser quirks with
--     ::first-letter on adjacent block siblings).

local function has_class(classes, target)
  for _, c in ipairs(classes) do
    if c == target then
      return true
    end
  end
  return false
end

local function tag_first_para(content)
  for _, block in ipairs(content) do
    if block.t == "Para" then
      block.attributes = block.attributes or {}
      block.classes = block.classes or pandoc.List({})
      if not has_class(block.classes, "lead-drop") then
        block.classes:insert("lead-drop")
      end
      return
    end
  end
end

function Div(el)
  if has_class(el.classes, "about-body") then
    tag_first_para(el.content)
    return el
  end
end
