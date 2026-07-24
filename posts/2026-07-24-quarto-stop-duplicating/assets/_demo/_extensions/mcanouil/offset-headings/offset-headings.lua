--- Offset Headings - Filter
--- @module "offset-headings"
--- @license MIT License
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @brief Offset heading levels by a positive or negative amount, format-agnostic.
--- @description
---   Adjusts heading levels anywhere in a document, in any output format.
---
---   Document-level options (front matter, _quarto.yml, or _metadata.yml):
---
---     extensions:
---       offset-headings:
---         by: 1
---         recursive: true
---         max-level: 6
---         depth: 0
---
---     - `by` (integer, default 0): offset applied to every heading in the
---       document.
---
---     - `recursive` (boolean, default true): default cascade behaviour for
---       per-heading offsets, used when a heading omits the
---       `offset-headings-recursive` attribute.
---
---     - `max-level` (integer, default 6): deepest level a heading may be
---       pushed to by a positive offset, used when a heading omits the
---       `offset-headings-max-level` attribute. Values outside [1, 6] are
---       clamped and a warning is emitted. The cap applies to the combined
---       level (document offset + per-heading offset), not to the per-heading
---       offset alone.
---
---     - `depth` (integer, default 0): default limit on how many descendant
---       heading levels inherit a cascading offset, used when a heading omits
---       the `offset-headings-depth` attribute. A value of 0 means unlimited
---       depth.
---
---     - `quarto-shift-warning` (boolean, default true): whether to warn when
---       Quarto's automatic heading shift can apply to the output. Set it to
---       false once `shift-heading-level-by: 0` is in place, since an explicit
---       `shift-heading-level-by` is invisible to Lua filters.
---
---   Interaction with Quarto's automatic heading shift:
---
---     Quarto sets `shift-heading-level-by: -1` for Typst, and for PDF/LaTeX
---     when `number-sections` is on, whenever the document has no level-1
---     heading and `shift-heading-level-by` is not set explicitly. Pandoc
---     applies that shift after every Lua filter has run, so this filter can
---     neither read nor cancel it, and the levels it produces are shifted a
---     second time. When the filter predicts that Quarto will shift the
---     output, it warns once and recommends setting
---     `shift-heading-level-by: 0` explicitly, which disables Quarto's
---     automatic shift at the source. Once that is in place, silence the
---     warning with `quarto-shift-warning: false`.
---
---   Per-heading attributes (override or supplement the document-level offset):
---
---     - `offset-headings-by` (integer, required on the heading): amount added
---       to the heading level. Positive values push the heading deeper;
---       negative values pull it up. The result is clamped to [1, 6].
---
---     - `offset-headings-recursive` (boolean, optional, defaults to the
---       document-level `recursive` option): when true, every following
---       descendant heading (deeper than this heading's original level)
---       receives the same offset. Cascading stops as soon as a heading at or
---       above the base level is encountered. When false, only the heading
---       carrying the attribute is offset.
---
---     - `offset-headings-max-level` (integer, optional, defaults to the
---       document-level `max-level` option): caps the combined heading level
---       (document offset + this heading's offset). The result never goes
---       below this level, and the global range [1, 6] still applies. Values
---       outside [1, 6] are clamped and a warning is emitted.
---
---     - `offset-headings-depth` (integer, optional, defaults to the
---       document-level `depth` option): bounds how many descendant heading
---       levels (relative to the attributed heading's original level) inherit
---       the cascade. A value of 0 means unlimited depth.
---
---   All attributes are stripped from the output.
---
---   Usage:
---     ## Section {offset-headings-by="1"}
---       Produces a level-3 heading; descendant headings cascade by default.
---
---     ## Section {offset-headings-by="1" offset-headings-recursive="false"}
---       Produces a level-3 heading; descendant headings are unaffected.
---
---     ## Section {offset-headings-by="3" offset-headings-max-level="4"}
---       A large offset is capped so the heading never goes below level 4.
---
---     ## Section {offset-headings-by="1" offset-headings-depth="1"}
---       Cascades the offset to descendants within one level of the original.

--- Extension name constant
local EXTENSION_NAME = 'offset-headings'

local log = require(quarto.utils.resolve_path('_modules/logging.lua'):gsub('%.lua$', ''))
local meta_utils = require(quarto.utils.resolve_path('_modules/metadata.lua'):gsub('%.lua$', ''))

--- Document-level metadata keys (under extensions.offset-headings).
local OFFSET_OPTION = 'by'
local RECURSIVE_OPTION = 'recursive'
local MAX_LEVEL_OPTION = 'max-level'
local DEPTH_OPTION = 'depth'
local QUARTO_SHIFT_WARNING_OPTION = 'quarto-shift-warning'

--- Per-heading attribute keys (shared flat attribute namespace, kept prefixed).
local OFFSET_ATTRIBUTE = 'offset-headings-by'
local RECURSIVE_ATTRIBUTE = 'offset-headings-recursive'
local MAX_LEVEL_ATTRIBUTE = 'offset-headings-max-level'
local DEPTH_ATTRIBUTE = 'offset-headings-depth'

local MIN_LEVEL = 1
local MAX_LEVEL = 6

--- A cascade depth of 0 means unlimited descendant levels inherit the offset.
local UNLIMITED_CASCADE_DEPTH = 0

--- Document-level offset applied to every heading.
local document_offset = 0

--- Document-level default for per-heading cascading.
local document_recursive = true

--- Document-level default for the deepest level a positive offset may reach.
local document_max_level = MAX_LEVEL

--- Document-level default for the cascade depth limit.
local document_cascade_depth = UNLIMITED_CASCADE_DEPTH

--- Whether to warn when Quarto's automatic heading shift can apply.
local document_quarto_shift_warning = true

--- Clamp a heading level to the valid Pandoc range [1, 6].
--- @param level number The desired heading level.
--- @return number The level clamped to [MIN_LEVEL, MAX_LEVEL].
local function clamp_level(level)
  return math.max(MIN_LEVEL, math.min(MAX_LEVEL, level))
end

--- Clamp a heading level to the range [1, max], honouring the per-heading or
--- document-level maximum target level before the global Pandoc range applies.
--- @param level number The desired heading level.
--- @param max number The deepest level the heading may be pushed to.
--- @return number The level clamped to [MIN_LEVEL, min(max, MAX_LEVEL)].
local function clamp_level_to_max(level, max)
  return math.max(MIN_LEVEL, math.min(MAX_LEVEL, math.min(max, level)))
end

--- Parse a string into an integer offset.
--- @param raw string|nil The raw attribute value.
--- @return number|nil The integer offset, or nil when not a number.
local function parse_offset(raw)
  if raw == nil then
    return nil
  end
  local value = tonumber(raw)
  if value == nil then
    return nil
  end
  return math.floor(value)
end

--- Clamp a max-level value to [MIN_LEVEL, MAX_LEVEL] and warn when out of range.
--- @param value number The desired max-level.
--- @param source string Human-readable source label (option or attribute name).
--- @return number The value clamped to the global heading range.
local function clamp_max_level_with_warning(value, source)
  if value < MIN_LEVEL or value > MAX_LEVEL then
    local clamped = clamp_level(value)
    log.log_warning(
      EXTENSION_NAME,
      'Clamping "' .. source .. '" value ' .. tostring(value)
        .. ' to ' .. tostring(clamped)
        .. ' (must be in the range [' .. MIN_LEVEL .. ', ' .. MAX_LEVEL .. ']).'
    )
    return clamped
  end
  return value
end

--- Parse a string into a boolean (default false).
--- @param raw string|nil The raw attribute value.
--- @return boolean True when the value is a truthy token.
local function parse_boolean(raw)
  if raw == nil then
    return false
  end
  local value = tostring(raw):lower()
  return value == 'true' or value == 'yes' or value == '1'
end

--- Read a boolean option from the extension config table.
--- A bare YAML boolean arrives as a Lua boolean, and get_metadata_value's
--- truthiness guard would drop `false`, so the raw config value is read
--- directly.
--- @param config table|nil The extension config table.
--- @param key string The option key.
--- @param default boolean The value used when the option is absent.
--- @return boolean The option value.
local function read_boolean_option(config, key, default)
  local raw = config and config[key]
  if raw == nil then
    return default
  end
  if type(raw) == 'boolean' then
    return raw
  end
  return parse_boolean(pandoc.utils.stringify(raw))
end

--- Read the document-level offset from extension metadata.
--- @param meta table The document metadata.
--- @return table The unmodified metadata.
local function read_metadata(meta)
  local raw = meta_utils.get_metadata_value(meta, EXTENSION_NAME, OFFSET_OPTION)
  local offset = parse_offset(raw)
  if raw ~= nil and offset == nil then
    log.log_warning(EXTENSION_NAME, 'Ignoring non-integer "' .. OFFSET_OPTION .. '": "' .. raw .. '".')
    offset = 0
  end
  document_offset = offset or 0

  local config = meta_utils.get_extension_config(meta, EXTENSION_NAME)
  document_recursive = read_boolean_option(config, RECURSIVE_OPTION, true)

  local raw_max_level = meta_utils.get_metadata_value(meta, EXTENSION_NAME, MAX_LEVEL_OPTION)
  local max_level = parse_offset(raw_max_level)
  if raw_max_level ~= nil and max_level == nil then
    log.log_warning(EXTENSION_NAME, 'Ignoring non-integer "' .. MAX_LEVEL_OPTION .. '": "' .. raw_max_level .. '".')
    max_level = MAX_LEVEL
  end
  if max_level ~= nil then
    max_level = clamp_max_level_with_warning(max_level, MAX_LEVEL_OPTION)
  end
  document_max_level = max_level or MAX_LEVEL

  local raw_cascade_depth = meta_utils.get_metadata_value(meta, EXTENSION_NAME, DEPTH_OPTION)
  local cascade_depth = parse_offset(raw_cascade_depth)
  if raw_cascade_depth ~= nil and cascade_depth == nil then
    log.log_warning(EXTENSION_NAME, 'Ignoring non-integer "' .. DEPTH_OPTION .. '": "' .. raw_cascade_depth .. '".')
    cascade_depth = UNLIMITED_CASCADE_DEPTH
  end
  document_cascade_depth = cascade_depth or UNLIMITED_CASCADE_DEPTH

  document_quarto_shift_warning = read_boolean_option(config, QUARTO_SHIFT_WARNING_OPTION, true)

  return meta
end

--- Check whether Quarto's automatic "shift-heading-level-by: -1" can apply to
--- this output format. Quarto sets it for Typst, and for PDF/LaTeX with
--- numbered sections and no explicit top-level division, whenever the document
--- has no level-1 heading and "shift-heading-level-by" is not set explicitly.
--- Pandoc applies the shift after every Lua filter, and an explicit
--- "shift-heading-level-by" is invisible to filters, so the rule can only be
--- predicted, not read. This mirrors quarto-cli's internal rule
--- (format-typst.ts, format-pdf.ts) and may need updating when Quarto changes
--- it.
--- @return boolean True when this output format is subject to the shift.
local function quarto_may_shift_format()
  if quarto.doc.is_format('typst') then
    return true
  end
  if quarto.doc.is_format('latex') and not quarto.doc.is_format('beamer') then
    local writer_options = PANDOC_WRITER_OPTIONS or {}
    return writer_options.number_sections == true
      and writer_options.top_level_division == 'top-level-default'
  end
  return false
end

--- Offset heading levels across the whole document in reading order.
--- Processing the block sequence is required to support recursive cascading.
--- @param doc pandoc.Pandoc The full document.
--- @return pandoc.Pandoc The document with heading levels adjusted.
local function process_pandoc(doc)
  local cascade_offset = nil
  local cascade_base_level = nil
  local cascade_max_level = nil
  local cascade_depth = nil

  --- Stop the active cascade, clearing all of its tracked state.
  local function clear_cascade()
    cascade_offset = nil
    cascade_base_level = nil
    cascade_max_level = nil
    cascade_depth = nil
  end

  --- Quarto decides its automatic shift from the source heading levels, so
  --- they are tracked here before any offset is applied.
  local has_heading = false
  local has_level_one = false

  doc.blocks = doc.blocks:walk({
    Header = function(header)
      local original_level = header.level
      has_heading = true
      if original_level == MIN_LEVEL then
        has_level_one = true
      end
      local raw_offset = header.attributes[OFFSET_ATTRIBUTE]

      if raw_offset ~= nil then
        local offset = parse_offset(raw_offset)
        header.attributes[OFFSET_ATTRIBUTE] = nil
        local raw_recursive = header.attributes[RECURSIVE_ATTRIBUTE]
        local recursive
        if raw_recursive ~= nil then
          recursive = parse_boolean(raw_recursive)
        else
          recursive = document_recursive
        end
        header.attributes[RECURSIVE_ATTRIBUTE] = nil

        local raw_max_level = header.attributes[MAX_LEVEL_ATTRIBUTE]
        local max_level = document_max_level
        if raw_max_level ~= nil then
          local parsed_max_level = parse_offset(raw_max_level)
          if parsed_max_level == nil then
            log.log_warning(
              EXTENSION_NAME,
              'Ignoring non-integer "' .. MAX_LEVEL_ATTRIBUTE .. '": "' .. raw_max_level .. '".'
            )
          else
            max_level = clamp_max_level_with_warning(parsed_max_level, MAX_LEVEL_ATTRIBUTE)
          end
        end
        header.attributes[MAX_LEVEL_ATTRIBUTE] = nil

        local raw_cascade_depth = header.attributes[DEPTH_ATTRIBUTE]
        local depth = document_cascade_depth
        if raw_cascade_depth ~= nil then
          local parsed_depth = parse_offset(raw_cascade_depth)
          if parsed_depth == nil then
            log.log_warning(
              EXTENSION_NAME,
              'Ignoring non-integer "' .. DEPTH_ATTRIBUTE .. '": "' .. raw_cascade_depth .. '".'
            )
          else
            depth = parsed_depth
          end
        end
        header.attributes[DEPTH_ATTRIBUTE] = nil

        if offset == nil then
          log.log_warning(
            EXTENSION_NAME,
            'Ignoring non-integer "' .. OFFSET_ATTRIBUTE .. '": "' .. raw_offset .. '".'
          )
          header.level = clamp_level(original_level + document_offset)
          clear_cascade()
        else
          header.level = clamp_level_to_max(original_level + document_offset + offset, max_level)
          if recursive then
            cascade_offset = offset
            cascade_base_level = original_level
            cascade_max_level = max_level
            cascade_depth = depth
          else
            clear_cascade()
          end
        end
      elseif cascade_offset ~= nil and original_level <= cascade_base_level then
        -- Sibling or ancestor: stop cascading and apply only the document offset.
        clear_cascade()
        header.level = clamp_level(original_level + document_offset)
      elseif cascade_offset ~= nil
        and cascade_depth ~= UNLIMITED_CASCADE_DEPTH
        and (original_level - cascade_base_level) > cascade_depth then
        -- Deeper than the cascade depth limit: apply only the document offset.
        header.level = clamp_level(original_level + document_offset)
      elseif cascade_offset ~= nil then
        -- Descendant within the active cascade: apply document and cascade offsets.
        header.level = clamp_level_to_max(original_level + document_offset + cascade_offset, cascade_max_level)
      else
        header.level = clamp_level(original_level + document_offset)
      end

      return header
    end,
  })

  if document_quarto_shift_warning
    and has_heading and not has_level_one
    and quarto_may_shift_format() then
    log.log_warning(
      EXTENSION_NAME,
      string.format(
        'Quarto applies "shift-heading-level-by: -1" to this %s output after this'
          .. ' filter runs, shifting every heading one level up, unless'
          .. ' "shift-heading-level-by" is set explicitly. Set'
          .. ' "shift-heading-level-by: 0" in the front matter to keep the levels'
          .. ' this filter produces, then silence this warning with "%s: false"'
          .. ' under "extensions.%s" (an explicit "shift-heading-level-by" is'
          .. ' invisible to Lua filters).',
        FORMAT,
        QUARTO_SHIFT_WARNING_OPTION,
        EXTENSION_NAME
      )
    )
  end

  return doc
end

return {
  { Meta = read_metadata },
  { Pandoc = process_pandoc }
}
