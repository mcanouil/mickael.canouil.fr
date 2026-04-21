--- Fragmention - Filter
--- @module fragmention
--- @license MIT License
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @version 0.0.0
--- @brief Hoist fragment attributes from empty marker spans to parent elements.
--- @description Moves .fragment class and fragment-index from empty inline
---   Spans to their parent <li> elements in RevealJS presentations.
---   Also renames fragment-index to data-fragment-index on Table cells/rows
---   for compatibility with pandoc-ext/list-table.

--- Whether the table fragment CSS has already been injected.
--- @type boolean
local css_injected = false

--- Inject CSS to collapse table fragment rows/cells until they become visible.
--- RevealJS hides fragments with opacity:0 but the row still occupies space
--- and shows borders. This CSS collapses them entirely.
local function inject_table_fragment_css()
  if css_injected then
    return
  end
  css_injected = true
  quarto.doc.add_html_dependency({
    name = 'fragmention',
    version = '0.0.0',
    stylesheets = {},
  })
  quarto.doc.include_text('in-header', [[
<style>
.reveal table tbody tr.fragment:not(.visible) {
  border-color: transparent;
}
.reveal table tbody tr.fragment:not(.visible) td,
.reveal table tbody tr.fragment:not(.visible) th {
  border-color: transparent;
}
</style>
]])
end

--- Check whether the current output format is RevealJS.
--- @return boolean
local function is_revealjs()
  return quarto.doc.is_format('revealjs')
end

--- Check whether a Span is an empty fragment marker.
--- An empty fragment marker is a Span with the "fragment" class and no content.
--- @param span pandoc.Span
--- @return boolean
local function is_empty_fragment_span(span)
  return span.t == 'Span'
      and span.classes:includes('fragment')
      and #span.content == 0
end

--- Build an HTML attribute string from a fragment Span's classes and attributes.
--- Maps fragment-index to data-fragment-index for RevealJS.
--- @param span pandoc.Span
--- @return string
local function build_li_attrs(span)
  local parts = {}

  if #span.classes > 0 then
    table.insert(parts, 'class="' .. table.concat(span.classes, ' ') .. '"')
  end

  if span.identifier and span.identifier ~= '' then
    table.insert(parts, 'id="' .. span.identifier .. '"')
  end

  for key, value in pairs(span.attributes) do
    table.insert(parts, 'data-' .. key .. '="' .. value .. '"')
  end

  return table.concat(parts, ' ')
end

--- Render Pandoc Blocks to an HTML string, trimming whitespace.
--- @param blocks pandoc.Blocks
--- @return string
local function render_blocks_html(blocks)
  local html = pandoc.write(pandoc.Pandoc(blocks), 'html')
  local trimmed = html:gsub('^%s+', ''):gsub('%s+$', '')
  return trimmed
end

--- Check whether a list item starts with an empty fragment span.
--- @param item table List of Blocks (one list item)
--- @return pandoc.Span|nil The fragment span, or nil
local function get_item_fragment_span(item)
  local first_block = item[1]
  if not first_block then
    return nil
  end
  if first_block.t ~= 'Plain' and first_block.t ~= 'Para' then
    return nil
  end
  local inlines = first_block.content
  if #inlines < 1 then
    return nil
  end
  if is_empty_fragment_span(inlines[1]) then
    return inlines[1]
  end
  return nil
end

--- Check whether any item in a list (or nested lists) has a fragment span.
--- @param items table List of list items
--- @return boolean
local function list_has_fragments(items)
  for _, item in ipairs(items) do
    if get_item_fragment_span(item) then
      return true
    end
    for _, block in ipairs(item) do
      if (block.t == 'BulletList' or block.t == 'OrderedList')
          and list_has_fragments(block.content)
      then
        return true
      end
    end
  end
  return false
end

local render_bullet_list, render_ordered_list

--- Render list item content to HTML.
--- Strips the empty fragment span from the first block and renders
--- remaining inlines and blocks (including recursively processed nested lists).
--- @param item table List of Blocks
--- @param has_fragment boolean Whether this item has a fragment span
--- @return string
local function render_item_content(item, has_fragment)
  local blocks = pandoc.Blocks({})
  local first_block = item[1]

  if first_block and (first_block.t == 'Plain' or first_block.t == 'Para') then
    local inlines = pandoc.Inlines(first_block.content)

    if has_fragment then
      inlines:remove(1)
      if #inlines > 0 and inlines[1].t == 'Space' then
        inlines:remove(1)
      end
    end

    if #inlines > 0 then
      if first_block.t == 'Para' then
        blocks:insert(pandoc.Para(inlines))
      else
        blocks:insert(pandoc.Plain(inlines))
      end
    end
  elseif first_block then
    blocks:insert(first_block)
  end

  for i = 2, #item do
    local block = item[i]
    if block.t == 'BulletList' and list_has_fragments(block.content) then
      blocks:insert(pandoc.RawBlock('html', render_bullet_list(block)))
    elseif block.t == 'OrderedList' and list_has_fragments(block.content) then
      blocks:insert(pandoc.RawBlock('html', render_ordered_list(block)))
    else
      blocks:insert(block)
    end
  end

  return render_blocks_html(blocks)
end

--- Render a BulletList to HTML with fragment attributes hoisted to <li>.
--- @param list pandoc.BulletList
--- @return string
render_bullet_list = function(list)
  local lines = { '<ul>' }

  for _, item in ipairs(list.content) do
    local frag_span = get_item_fragment_span(item)
    if frag_span then
      local attrs = build_li_attrs(frag_span)
      local content = render_item_content(item, true)
      table.insert(lines, '<li ' .. attrs .. '>' .. content .. '</li>')
    else
      local content = render_item_content(item, false)
      table.insert(lines, '<li>' .. content .. '</li>')
    end
  end

  table.insert(lines, '</ul>')
  return table.concat(lines, '\n')
end

--- Render an OrderedList to HTML with fragment attributes hoisted to <li>.
--- Preserves start number and list type.
--- @param list pandoc.OrderedList
--- @return string
render_ordered_list = function(list)
  local type_map = {
    Decimal = '1',
    LowerAlpha = 'a',
    UpperAlpha = 'A',
    LowerRoman = 'i',
    UpperRoman = 'I',
  }

  local ol_attrs = {}
  if list.start and list.start ~= 1 then
    table.insert(ol_attrs, 'start="' .. list.start .. '"')
  end
  local html_type = type_map[list.style]
  if html_type and html_type ~= '1' then
    table.insert(ol_attrs, 'type="' .. html_type .. '"')
  end

  local ol_open = '<ol'
  if #ol_attrs > 0 then
    ol_open = ol_open .. ' ' .. table.concat(ol_attrs, ' ')
  end
  ol_open = ol_open .. '>'

  local lines = { ol_open }

  for _, item in ipairs(list.content) do
    local frag_span = get_item_fragment_span(item)
    if frag_span then
      local attrs = build_li_attrs(frag_span)
      local content = render_item_content(item, true)
      table.insert(lines, '<li ' .. attrs .. '>' .. content .. '</li>')
    else
      local content = render_item_content(item, false)
      table.insert(lines, '<li>' .. content .. '</li>')
    end
  end

  table.insert(lines, '</ol>')
  return table.concat(lines, '\n')
end

--- Rename fragment-index to data-fragment-index on an Attr object.
--- @param attr pandoc.Attr
--- @return boolean Whether a rename occurred
local function fix_fragment_attr(attr)
  local idx = attr.attributes['fragment-index']
  if idx then
    attr.attributes['fragment-index'] = nil
    attr.attributes['data-fragment-index'] = idx
    return true
  end
  return false
end

--- Process a Table to rename fragment-index on cells and rows.
--- Ensures compatibility with pandoc-ext/list-table which transfers
--- empty span attributes to table elements but does not add the data- prefix.
--- @param el pandoc.Table
--- @return pandoc.Table|nil
local function process_table(el)
  local changed = false

  local function process_rows(rows)
    for _, row in ipairs(rows) do
      if row.attr and row.attr.classes:includes('fragment') then
        if fix_fragment_attr(row.attr) then
          changed = true
        end
      end
      for _, cell in ipairs(row.cells) do
        if cell.attr and cell.attr.classes:includes('fragment') then
          if fix_fragment_attr(cell.attr) then
            changed = true
          end
        end
      end
    end
  end

  process_rows(el.head.rows)
  for _, body in ipairs(el.bodies) do
    process_rows(body.head)
    process_rows(body.body)
  end
  if el.foot then
    process_rows(el.foot.rows)
  end

  if changed then
    inject_table_fragment_css()
    return el
  end
  return nil
end

return {
  {
    BulletList = function(el)
      if not is_revealjs() then
        return el
      end
      if not list_has_fragments(el.content) then
        return el
      end
      return pandoc.RawBlock('html', render_bullet_list(el))
    end,
    OrderedList = function(el)
      if not is_revealjs() then
        return el
      end
      if not list_has_fragments(el.content) then
        return el
      end
      return pandoc.RawBlock('html', render_ordered_list(el))
    end,
    Table = function(el)
      if not is_revealjs() then
        return el
      end
      return process_table(el)
    end,
  },
}
