-- Add target=_blank and rel="noopener noreferrer" to external links.
-- Quarto's link-external-newwindow already sets target on most external links
-- but does not always set rel; this filter ensures both for accessibility/security.

local function is_external(target)
  if not target or target == "" then
    return false
  end
  -- Treat absolute schemes (http, https, mailto, tel) as external; anchors and
  -- relative paths (no scheme) are internal.
  return target:match("^https?://") ~= nil
end

local function set_attr(attrs, name, value)
  for i, kv in ipairs(attrs) do
    if kv[1] == name then
      attrs[i][2] = value
      return
    end
  end
  table.insert(attrs, { name, value })
end

local function ensure_rel(attrs, value)
  for i, kv in ipairs(attrs) do
    if kv[1] == "rel" then
      local existing = {}
      for token in kv[2]:gmatch("%S+") do
        existing[token] = true
      end
      for token in value:gmatch("%S+") do
        existing[token] = true
      end
      local merged = {}
      for token in pairs(existing) do
        table.insert(merged, token)
      end
      table.sort(merged)
      attrs[i][2] = table.concat(merged, " ")
      return
    end
  end
  table.insert(attrs, { "rel", value })
end

function Link(el)
  if not is_external(el.target) then
    return nil
  end
  set_attr(el.attributes, "target", "_blank")
  ensure_rel(el.attributes, "noopener noreferrer")
  return el
end
