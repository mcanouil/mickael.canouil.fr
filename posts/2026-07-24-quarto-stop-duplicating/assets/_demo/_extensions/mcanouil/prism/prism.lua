--- Prism - Filter
--- @module "prism"
--- @license MIT License
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @brief Promote attributes whose key prefix matches the active Quarto target format.
--- @description
---   Reads attributes whose key follows the `format:name` pattern on `Div`,
---   `Span`, `CodeBlock`, and `Header` elements.
---
---   The `format` prefix is matched against the Quarto target format,
---   resolved from `quarto.format.format_identifier()["target-format"]`
---   (falling back to the Pandoc `FORMAT` global). The target format is the
---   user-declared format name and includes Quarto custom formats, so a
---   custom format such as `mcanouil-typst` is distinct from its base writer
---   `typst`. Matching is exact for individual format names, so `html:`
---   targets HTML output without also affecting revealjs.
---
---   In addition to exact format names, the `slide` alias matches every HTML
---   slide format (revealjs, slidy, s5, dzslides, slideous), so `slide:` can
---   target the whole group at once.
---
---   A `default:name` prefix provides a fallback value, applied only when no
---   format-specific variant of the same `name` matched the active format.
---
---   When the prefix matches, the attribute is re-emitted as `name="value"`
---   and the prefixed key is removed.
---   When the prefix does not match, the attribute is dropped.
---   Attributes whose key contains no colon are passed through unchanged.
---
---   Precedence for a given `name`: exact format match > alias match >
---   default fallback > unprefixed pass-through.
---
---   Promoted attributes override static ones with the same name. When two
---   format-scoped attributes share the same target name on the same element
---   (e.g. two `html:style` keys), the last one in source order wins.
---
---   Unknown prefixes (neither an exact format name, a known group alias,
---   nor `default`) are treated as non-matching and the attribute is dropped.
---   Enable `extensions.prism.warn-on-drop` to emit a `quarto.log.warning`
---   each time a format-scoped attribute is dropped, which surfaces typos in
---   prefixes that would otherwise vanish silently.
---
---   The filter only inspects key-value attributes; classes and ids are left
---   untouched.
---
---   Usage:
---     ::: {html:style="font-size: 1.2rem;" revealjs:style="font-size: 2em;"}
---     Conditional content.
---     :::
---
---     ::: {slide:style="font-size: 2em;" default:style="font-size: 1rem;"}
---     Larger on every slide format, smaller everywhere else.
---     :::
---
---     ```{.r mcanouil-typst:width="50%"}
---     1 + 1
---     ```

--- Extension name constant, used to namespace log messages and metadata.
local EXTENSION_NAME = 'prism'

local slide_formats = require(quarto.utils.resolve_path('_modules/slide-formats.lua'):gsub('%.lua$', ''))
local log = require(quarto.utils.resolve_path('_modules/logging.lua'):gsub('%.lua$', ''))

--- Resolve the active Quarto target format name once per render.
--- Strips Pandoc format variants (e.g. `html+raw_attribute` -> `html`) so
--- prefixes can be written without flag suffixes.
--- @return string
local function resolve_target_format()
  local ok, identifier = pcall(function()
    return quarto.format.format_identifier()
  end)
  local target = ok and identifier and identifier["target-format"] or nil
  if target == nil or target == "" then
    target = FORMAT
  end
  return target:match("^[^+]+") or target
end

local TARGET_FORMAT = resolve_target_format()

--- The `default` prefix names a fallback value, applied only when no
--- format-specific variant of the same attribute name matched.
local DEFAULT_PREFIX = "default"

--- Aliases that match a group of formats rather than an exact format name.
--- Each value is the set of target formats the alias resolves to.
--- The `slide` set is sourced from the shared `_modules/slide-formats` module
--- so prism and portable-links agree on what counts as an HTML slide format.
--- @type table<string, table<string, boolean>>
local FORMAT_ALIASES = {
  slide = slide_formats.formats,
}

--- Whether to emit a warning when a format-scoped attribute is dropped.
--- Set per document via `extensions.prism.warn-on-drop: true`.
--- @type boolean
local warn_on_drop = false

--- Resolve how a prefix matches the active target format.
--- Exact format names match identically; group aliases match when the active
--- target format is a member of the alias set.
--- @param prefix string The attribute key prefix (the part before the colon).
--- @return "exact"|"alias"|nil The match kind, or nil when the prefix does not match.
local function match_prefix(prefix)
  if prefix == TARGET_FORMAT then
    return "exact"
  end
  local alias = FORMAT_ALIASES[prefix]
  if alias and alias[TARGET_FORMAT] then
    return "alias"
  end
  return nil
end

--- Describe an element for warning messages: prefer the id, then the first
--- class, then the element tag.
--- @param el pandoc.Div|pandoc.Span|pandoc.CodeBlock|pandoc.Header
--- @return string
local function describe_element(el)
  if el.identifier and el.identifier ~= '' then
    return '#' .. el.identifier
  end
  if el.classes and #el.classes > 0 then
    return '.' .. el.classes[1]
  end
  return el.t or 'element'
end

--- Rewrite the `attributes` table of an element by resolving format prefixes.
--- @param el pandoc.Div|pandoc.Span|pandoc.CodeBlock|pandoc.Header The element to process.
--- @return pandoc.Div|pandoc.Span|pandoc.CodeBlock|pandoc.Header|nil
local function process(el)
  if #el.attributes == 0 then
    return nil
  end

  local kept = {}
  local promoted_order = {}
  local promoted_value = {}
  local promoted_kind = {}
  local default_order = {}
  local default_value = {}
  local dropped = {}

  for _, kv in ipairs(el.attributes) do
    local key, value = kv[1], kv[2]
    local prefix, name = key:match("^([^:]+):(.+)$")
    if prefix and name then
      if prefix == DEFAULT_PREFIX then
        if default_value[name] == nil then
          table.insert(default_order, name)
        end
        default_value[name] = value
      else
        local kind = match_prefix(prefix)
        -- An exact match always wins over an alias match for the same name.
        if kind == "exact" or (kind == "alias" and promoted_kind[name] ~= "exact") then
          if promoted_value[name] == nil then
            table.insert(promoted_order, name)
          end
          promoted_value[name] = value
          promoted_kind[name] = kind
        else
          table.insert(dropped, key)
        end
      end
    else
      table.insert(kept, { key, value })
    end
  end

  -- A default fallback applies only when no format-specific variant of the
  -- same name matched the active target format.
  for _, name in ipairs(default_order) do
    if promoted_value[name] == nil then
      table.insert(promoted_order, name)
      promoted_value[name] = default_value[name]
    end
  end

  -- Drop static attributes whose name is also promoted, so the format-scoped
  -- value wins and Pandoc does not see a duplicate-attribute warning.
  -- Among promoted entries, the last source occurrence wins.
  local final = {}
  for _, kv in ipairs(kept) do
    if promoted_value[kv[1]] == nil then
      table.insert(final, kv)
    end
  end
  for _, name in ipairs(promoted_order) do
    table.insert(final, { name, promoted_value[name] })
  end

  if warn_on_drop and #dropped > 0 then
    log.log_warning(
      EXTENSION_NAME,
      "Dropped attribute(s) '" .. table.concat(dropped, "', '") ..
        "' on " .. describe_element(el) ..
        " because no prefix matched target format '" .. TARGET_FORMAT .. "'."
    )
  end

  el.attributes = final
  return el
end

--- Read the `extensions.prism.warn-on-drop` option from document metadata.
--- @param meta table The document metadata table.
--- @return nil
local function read_options(meta)
  local config = meta['extensions'] and meta['extensions'][EXTENSION_NAME]
  if not config then return nil end
  if config['warn-on-drop'] ~= nil then
    warn_on_drop = pandoc.utils.stringify(config['warn-on-drop']) == 'true'
  end
  return nil
end

return {
  { Meta = read_options },
  { Div = process, Span = process, CodeBlock = process, Header = process }
}
