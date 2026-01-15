--[[
# MIT License
#
# Copyright (c) 2026 Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

--- Default mapping of language classes to their real comment symbols.
--- Users write annotations with the real syntax; filter converts to Quarto's `#`.
--- @type table<string, string>
local DEFAULT_MAPPINGS = {
  typst = "//",
}

--- Configured mappings from document metadata.
--- @type table<string, string>
local configured_mappings = {}

--- Escape special Lua pattern characters in a string.
--- @param str string The string to escape.
--- @return string The escaped string safe for use in gsub patterns.
local function escape_pattern(str)
  local escaped = str:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  return escaped
end

--- Merge default and user-configured mappings.
--- @param meta pandoc.Meta Document metadata.
--- @return pandoc.Meta The unmodified metadata.
function Meta(meta)
  for lang, symbol in pairs(DEFAULT_MAPPINGS) do
    configured_mappings[lang] = symbol
  end
  if meta["code-annotations-mappings"] then
    for lang, symbol in pairs(meta["code-annotations-mappings"]) do
      configured_mappings[pandoc.utils.stringify(lang)] = pandoc.utils.stringify(symbol)
    end
  end
  return meta
end

--- Convert annotation markers in code blocks.
--- Replaces real comment syntax with `# <N>` so Quarto recognises annotations.
--- @param el pandoc.CodeBlock The code block element to process.
--- @return pandoc.CodeBlock The modified code block element.
function CodeBlock(el)
  for lang, symbol in pairs(configured_mappings) do
    if el.classes:includes(lang) then
      local pattern = escape_pattern(symbol)
      el.text = el.text:gsub(pattern .. " (<[0-9]+>)%s*$", "# %1")
      el.text = el.text:gsub(pattern .. " (<[0-9]+>)%s*\n", "# %1\n")
      break
    end
  end
  return el
end

return {
  { Meta = Meta },
  { CodeBlock = CodeBlock },
}
