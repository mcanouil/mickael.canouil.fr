--- Reveal.js Cascade - Filter
--- @module cascade
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @version 0.0.0
--- @description Repeat top-level headings on slides created with horizontal
---   rules (`---`).
---   In reveal.js presentations, a `---` separator creates a new slide without
---   a heading.
---   This filter replaces each `HorizontalRule` with clones of the heading
---   chain from the most recent slide.
---
---   When `---` is followed by a heading, only parent headings above that
---   level are repeated.
---   When followed by non-heading content, the entire heading chain is
---   repeated.
---
---   For non-reveal.js formats, behaviour depends on the `keep-hrule` option
---   (default: `true`).
---   When `false`, horizontal rules are removed from the output.
---
---   Headings below the slide level create section wrappers in reveal.js
---   output, so they are skipped when cloning the chain on `---` slides.
---   Accounts for `shift-heading-level-by` (applied after filters run) by
---   translating the writer's slide level back into AST coordinates.

--- Read the `keep-hrule` extension option from document metadata.
--- @param meta pandoc.Meta The document metadata.
--- @return boolean Whether to keep horizontal rules in non-reveal.js formats.
local function get_keep_hrule(meta)
  local extensions = meta['extensions']
  if not extensions then
    return false
  end
  local cascade = extensions['cascade']
  if not cascade then
    return false
  end
  local keep = cascade['keep-hrule']
  if keep == nil then
    return false
  end
  return pandoc.utils.stringify(keep) ~= 'false'
end

--- Detect the effective slide level in AST coordinates.
--- `PANDOC_WRITER_OPTIONS.slide_level` is the writer's (post-shift) slide
--- level. Pandoc/Quarto applies `shift-heading-level-by` after filters run,
--- so the AST still has pre-shift heading levels; subtract the shift to get
--- the slide level as it appears in the AST.
--- @param meta pandoc.Meta The document metadata.
--- @return integer The slide level in AST coordinates.
local function detect_slide_level(meta)
  local slide_level = 2
  if PANDOC_WRITER_OPTIONS and PANDOC_WRITER_OPTIONS.slide_level then
    slide_level = PANDOC_WRITER_OPTIONS.slide_level
  end
  local shift = meta['shift-heading-level-by']
  if shift then
    shift = tonumber(pandoc.utils.stringify(shift)) or 0
  else
    shift = 0
  end
  return slide_level - shift
end

--- Process the full document: detect the effective slide level, then
--- replace each `HorizontalRule` with clones of the heading chain
--- from the most recent slide.
--- For non-reveal.js formats, either keep or remove horizontal rules
--- based on the `keep-hrule` option.
--- @param doc pandoc.Pandoc The document to process.
--- @return pandoc.Pandoc The processed document.
function Pandoc(doc)
  if not quarto.doc.is_format('revealjs') then
    local keep_hrule = get_keep_hrule(doc.meta)
    if keep_hrule then
      return doc
    end
    doc.blocks = doc.blocks:filter(function(block)
      return block.t ~= 'HorizontalRule'
    end)
    return doc
  end

  local slide_level = detect_slide_level(doc.meta)
  local parents = {}
  local chain = {}
  local at_slide_start = false
  local new_blocks = pandoc.Blocks({})

  for i, block in ipairs(doc.blocks) do
    if block.t == 'Header' and block.level < slide_level then
      local new_parents = {}
      for _, p in ipairs(parents) do
        if p.level < block.level then
          table.insert(new_parents, p)
        end
      end
      table.insert(new_parents, block)
      parents = new_parents
      chain = {}
      at_slide_start = false
      new_blocks:insert(block)
    elseif block.t == 'Header' and block.level == slide_level then
      chain = {}
      for _, p in ipairs(parents) do
        table.insert(chain, p)
      end
      table.insert(chain, block)
      at_slide_start = true
      new_blocks:insert(block)
    elseif at_slide_start and block.t == 'Header' then
      table.insert(chain, block)
      new_blocks:insert(block)
    elseif block.t == 'HorizontalRule' and #chain > 0 then
      local next_block = doc.blocks[i + 1]
      local next_is_header = next_block and next_block.t == 'Header'
      local new_chain = {}
      for _, h in ipairs(chain) do
        if h.level >= slide_level and (not next_is_header or h.level < next_block.level) then
          local clone = h:clone()
          clone.identifier = ''
          new_blocks:insert(clone)
          table.insert(new_chain, clone)
        end
      end
      chain = new_chain
      at_slide_start = true
    else
      at_slide_start = false
      new_blocks:insert(block)
    end
  end

  doc.blocks = new_blocks
  return doc
end
