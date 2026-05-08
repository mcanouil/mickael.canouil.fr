-- Wrap ordinal English suffixes (st, nd, rd, th) in a small superscript span.
-- Targets text inside paragraphs/divs typically used for dates: `<p class="date">`,
-- `<p class="date-modified">`, `.listing-date`, `.listing-file-modified`.

local DATE_CLASSES = {
  ["date"] = true,
  ["date-modified"] = true,
  ["listing-date"] = true,
  ["listing-file-modified"] = true,
}

local function has_date_class(el)
  if not el.classes then
    return false
  end
  for _, c in ipairs(el.classes) do
    if DATE_CLASSES[c] then
      return true
    end
  end
  return false
end

-- Walk a list of inlines, splitting any Str that contains "<digits><st|nd|rd|th>"
-- into a Str with the digits and a Span (class="ordinal-suffix") with the suffix.
local function decorate_inlines(inlines)
  local out = pandoc.List({})
  for _, item in ipairs(inlines) do
    if item.t == "Str" then
      local pos, last = 1, 1
      local s = item.text
      while true do
        local a, b, num, suf = s:find("(%d+)(st|nd|rd|th)", last)
        if not a then
          break
        end
        if a > pos then
          out:insert(pandoc.Str(s:sub(pos, a - 1)))
        end
        out:insert(pandoc.Str(num))
        out:insert(pandoc.Span(
          { pandoc.Str(suf) },
          pandoc.Attr("", { "ordinal-suffix" }, {})
        ))
        pos = b + 1
        last = b + 1
      end
      if pos <= #s then
        out:insert(pandoc.Str(s:sub(pos)))
      end
    else
      out:insert(item)
    end
  end
  return out
end

function Para(el)
  if has_date_class(el) then
    el.content = decorate_inlines(el.content)
    return el
  end
end

function Div(el)
  if has_date_class(el) then
    -- Visit any inline containers inside the div (Para/Plain) recursively.
    el.content = el.content:walk({
      Para = Para,
      Plain = function(p)
        p.content = decorate_inlines(p.content)
        return p
      end,
    })
    return el
  end
end
