/**
 * @module RevealJsCodefrag
 * @license MIT
 * @copyright 2026 Mickaël Canouil
 * @author Mickaël Canouil
 */

/**
 * Reveal.js Code Annotation Fragments
 *
 * Enables fragment navigation through code annotations in Reveal.js
 * presentations rendered by Quarto.
 *
 * Creates invisible fragment elements for each code annotation anchor,
 * allowing navigation through annotations using arrow keys or fragment controls.
 *
 * Configuration:
 * ```yaml
 * extensions:
 *   codefrag:
 *     enabled: true  # default
 * ```
 *
 * Custom annotation fragment indices:
 * ```{.r code-annotation-fragment-indices="2,4,6"}
 * library(dplyr)            # <1>
 * mtcars |>                 # <2>
 *   filter(mpg > 20)        # <3>
 * ```
 *
 * Custom line-highlight fragment indices:
 * ```{.r code-line-numbers="|2|3" code-line-fragment-indices="1,2,4"}
 * line1
 * line2
 * line3
 * ```
 */

window.RevealJsCodefrag = function () {
  "use strict";

  // --- Selectors -----------------------------------------------------------

  const SEL_ANCHOR = ".code-annotation-anchor";
  const SEL_ORIGINAL_ANCHOR = "code:not(.fragment) > .code-annotation-anchor";
  const SEL_HIGHLIGHT_FRAGMENT = "code.fragment.has-line-highlights";
  const SEL_ANNOTATION_FRAGMENT = ".code-annotation-fragment";
  const SEL_ANNOTATED_CODE = ".code-annotation-code";

  // Guard against pathological line-number ranges (e.g. "1-999999999").
  const MAX_LINE_RANGE_SIZE = 10_000;

  // --- Helpers --------------------------------------------------------------

  /**
   * @param {string} targetCell
   * @param {string} targetAnnotation
   * @returns {string} CSS selector for the matching anchor.
   */
  function buildAnchorSelector(targetCell, targetAnnotation) {
    return `${SEL_ANCHOR}[data-target-cell="${targetCell}"][data-target-annotation="${targetAnnotation}"]`;
  }

  /**
   * @param {Object} config
   * @returns {boolean} True if enabled (default).
   */
  function getEnabled(config) {
    const value = config["extensions"]?.["codefrag"]?.["enabled"];
    return typeof value === "boolean" ? value : true;
  }

  /**
   * @param {string} str - Comma-separated indices (e.g., "1,3,5").
   * @returns {Array<number|null>} Parsed indices.
   */
  function parseFragmentIndices(str) {
    if (!str || typeof str !== "string") return [];
    return str.split(",").map((s) => {
      const num = parseInt(s.trim(), 10);
      return isNaN(num) ? null : num;
    });
  }

  /**
   * Parse a line-number spec into a Set of line numbers.
   * Handles single numbers ("3"), ranges ("3-5"), and
   * comma-separated combinations ("1,3-5,7").
   * @param {string} spec
   * @returns {Set<number>}
   */
  function parseLineNumbers(spec) {
    const lines = new Set();
    if (!spec || typeof spec !== "string" || spec.trim() === "") return lines;
    for (const part of spec.split(",")) {
      const trimmed = part.trim();
      const range = trimmed.split("-");
      if (range.length === 2) {
        const start = parseInt(range[0], 10);
        const end = parseInt(range[1], 10);
        if (isNaN(start) || isNaN(end)) continue;
        if (end < start || end - start + 1 > MAX_LINE_RANGE_SIZE) {
          console.warn(
            `[codefrag] Ignoring invalid or oversized line range: "${trimmed}".`
          );
          continue;
        }
        for (let i = start; i <= end; i++) lines.add(i);
      } else {
        const num = parseInt(trimmed, 10);
        if (!isNaN(num)) lines.add(num);
      }
    }
    return lines;
  }

  /**
   * @param {Set<number>} a
   * @param {Set<number>} b
   * @returns {boolean} True if the two Sets contain the same elements.
   */
  function setsEqual(a, b) {
    if (a.size !== b.size) return false;
    for (const item of a) {
      if (!b.has(item)) return false;
    }
    return true;
  }

  /**
   * @param {Set<number>} a
   * @param {Set<number>} b
   * @returns {boolean} True if `a` is non-empty and every element of `a` is in `b`.
   */
  function isSubsetOf(a, b) {
    if (a.size === 0) return false;
    if (a.size > b.size) return false;
    for (const item of a) {
      if (!b.has(item)) return false;
    }
    return true;
  }

  /**
   * Get the line-number set for an annotation from its Quarto description span.
   * @param {string} cellId
   * @param {string} annotationNumber
   * @returns {Set<number>}
   */
  function getAnnotationLineSet(cellId, annotationNumber) {
    const span = document.querySelector(
      `span[data-code-cell="${cellId}"][data-code-annotation="${annotationNumber}"]`
    );
    if (!span || !span.dataset.codeLines) return new Set();
    return parseLineNumbers(span.dataset.codeLines);
  }

  /**
   * Only called in Phase 2 (after sortAll), so all clones have valid indices.
   * @param {Element} el
   * @returns {number} The element's data-fragment-index, or 0.
   */
  function getFragmentIndex(el) {
    return parseInt(el.getAttribute("data-fragment-index"), 10) || 0;
  }

  /**
   * @param {Element} codeBlock
   * @returns {Element} The nearest .cell wrapper, or the direct parent.
   */
  function getFragmentParent(codeBlock) {
    return codeBlock.closest(".cell") || codeBlock.parentNode;
  }

  /**
   * Create a hidden annotation fragment div and append it to parentNode.
   * @param {Element} parentNode
   * @param {Element} anchor
   * @param {number} anchorIndex
   * @param {number} [fragmentIndex] - If provided, sets `data-fragment-index`.
   */
  function appendAnnotationFragment(parentNode, anchor, anchorIndex, fragmentIndex) {
    const div = document.createElement("div");
    div.className = "code-annotation-fragment fragment";
    div.dataset.targetCell = anchor.dataset.targetCell;
    div.dataset.targetAnnotation = anchor.dataset.targetAnnotation;
    div.dataset.anchorIndex = anchorIndex;
    if (fragmentIndex != null) {
      div.setAttribute("data-fragment-index", fragmentIndex);
    }
    div.style.display = "none";
    parentNode.appendChild(div);
  }

  // --- Tooltips -------------------------------------------------------------

  /**
   * Hide visible annotation tooltips on the given slide.
   * @param {Element} slide
   */
  function hideAnnotationTooltips(slide) {
    for (const anchor of slide.querySelectorAll(SEL_ANCHOR)) {
      if (anchor._tippy?.state.isVisible) anchor._tippy.hide();
    }
  }

  /**
   * Patch all annotation tooltips to append to their slide.
   * Prevents overflow clipping from inner containers.
   */
  function patchAnnotationTooltips() {
    for (const anchor of document.querySelectorAll(SEL_ANCHOR)) {
      if (!anchor._tippy) continue;
      const slide = anchor.closest("section");
      if (slide) anchor._tippy.setProps({ appendTo: slide });
    }
  }

  /**
   * Show annotation tooltip for a specific anchor.
   * @param {string} targetCell
   * @param {string} targetAnnotation
   */
  function showAnnotationTooltip(targetCell, targetAnnotation) {
    const selector = buildAnchorSelector(targetCell, targetAnnotation);
    const anchor = document.querySelector(selector);
    if (!anchor) return;

    if (anchor._tippy) {
      anchor._tippy.show();
      // Tippy creates popperInstance lazily on first mount; defer the
      // position update so it runs after the instance is available.
      requestAnimationFrame(() => {
        anchor._tippy?.popperInstance?.update();
      });
    } else {
      anchor.click();
    }
  }

  // --- Fragment creation ----------------------------------------------------

  /**
   * Set up sequential fragment triggers for annotations.
   * When no custom indices are provided, fragments are left without
   * data-fragment-index so Reveal.js assigns them by DOM order during
   * its sortAll() pass (which runs after plugin init).
   * @param {Element} parentNode
   * @param {NodeList} anchors
   * @param {Array<number|null>} [customIndices]
   */
  function setupSequentialFragments(parentNode, anchors, customIndices) {
    const anchorList = [...anchors];
    const hasCustomIndices = customIndices && customIndices.length > 0;

    if (hasCustomIndices && customIndices.length !== anchorList.length) {
      console.warn(
        `[codefrag] Code block has ${anchorList.length} annotations but ${customIndices.length} fragment indices specified.`,
        parentNode
      );
    }

    for (const [i, anchor] of anchorList.entries()) {
      const idx = hasCustomIndices ? customIndices[i] : undefined;
      appendAnnotationFragment(parentNode, anchor, i, idx);
    }
  }

  /**
   * Phase 1: Create fragment elements for sequential annotations.
   * Must run during plugin init (before Reveal.js sortAll) so
   * fragments participate in DOM-order index assignment.
   * Line-highlight code blocks are marked for deferred setup.
   */
  function createAnnotationFragments() {
    const annotatedCells = document.querySelectorAll(
      `.reveal .slides ${SEL_ANNOTATED_CODE}`
    );

    for (const codeBlock of annotatedCells) {
      if (codeBlock.dataset.annotationFragmentsCreated) continue;
      codeBlock.dataset.annotationFragmentsCreated = "true";

      // Exclude anchors inside highlight clones (duplicated via cloneNode).
      const anchors = codeBlock.querySelectorAll(SEL_ORIGINAL_ANCHOR);
      if (anchors.length === 0) continue;

      const slide = codeBlock.closest("section");
      if (!slide) continue;

      const sourceCodeDiv = codeBlock.closest("div.sourceCode");
      const hasLineHighlighting =
        codeBlock.querySelectorAll(SEL_HIGHLIGHT_FRAGMENT).length > 0;
      const customIndices = sourceCodeDiv
        ? parseFragmentIndices(
          sourceCodeDiv.getAttribute(
            "data-code-annotation-fragment-indices"
          )
        )
        : [];

      if (hasLineHighlighting && sourceCodeDiv && customIndices.length === 0) {
        // Deferred to Phase 2: line matching determines sync vs partial.
        codeBlock.dataset.annotationSyncPending = "true";
      } else {
        setupSequentialFragments(getFragmentParent(codeBlock), anchors, customIndices);
      }

      slide.dataset.hasAnnotationFragments = "true";
    }
  }

  /**
   * Reassign fragment indices on line-highlight clones when the code block
   * specifies `code-line-fragment-indices`.
   *
   * `indices[0]` corresponds to step 0 (the original `<code>`, not a
   * fragment clone) and is skipped.  `indices[i+1]` maps to the i-th
   * clone.  Must run during plugin init (after QuartoLineHighlight has
   * created clones but before Reveal.js sortAll normalises indices) so
   * that custom indices participate in the same normalisation pass as
   * other explicit fragment indices on the slide.
   */
  function applyLineHighlightIndices() {
    const codeBlocks = document.querySelectorAll(
      ".reveal .slides div.sourceCode[data-code-line-fragment-indices]"
    );

    for (const sourceCodeDiv of codeBlocks) {
      const indices = parseFragmentIndices(
        sourceCodeDiv.getAttribute("data-code-line-fragment-indices")
      );
      if (indices.length === 0) continue;

      const pre = sourceCodeDiv.querySelector("pre");
      if (!pre) continue;

      const clones = pre.querySelectorAll(SEL_HIGHLIGHT_FRAGMENT);
      if (clones.length === 0) {
        console.warn(
          "[codefrag] code-line-fragment-indices specified but no line-highlight clones found. Is code-line-numbers missing?",
          sourceCodeDiv
        );
        continue;
      }

      const expectedCount = clones.length + 1;
      if (indices.length !== expectedCount) {
        console.warn(
          `[codefrag] Code block has ${expectedCount} highlight steps but ${indices.length} line fragment indices specified.`,
          sourceCodeDiv
        );
      }

      for (const [i, clone] of clones.entries()) {
        const idx = indices[i + 1];
        if (idx != null) {
          clone.setAttribute("data-fragment-index", idx);
        }
      }
    }
  }

  /**
   * Phase 2: Create annotation fragments for line-highlight code blocks.
   * Must run on ready (after Reveal.js sortAll has assigned final
   * fragment indices to highlight steps).
   *
   * Reads each highlight clone's `data-code-line-numbers` attribute
   * (set by QuartoLineHighlight during its init) and compares against
   * each annotation's `data-code-lines` from the description span.
   *
   * Annotations matched to a highlight clone share its fragment index
   * (same step). Unmatched annotations are appended after the highest
   * fragment index on the slide, one per new step, to avoid colliding
   * with other fragments. Highlight-clone indices (set by Phase 1 and/or
   * Reveal.js sortAll) are never rewritten.
   */
  function setupLineHighlightAnnotations() {
    const pendingBlocks = document.querySelectorAll(
      `${SEL_ANNOTATED_CODE}[data-annotation-sync-pending="true"]`
    );

    for (const codeBlock of pendingBlocks) {
      delete codeBlock.dataset.annotationSyncPending;

      const anchors = codeBlock.querySelectorAll(SEL_ORIGINAL_ANCHOR);
      if (anchors.length === 0) continue;

      const sourceCodeDiv = codeBlock.closest("div.sourceCode");
      if (!sourceCodeDiv) continue;

      const parentNode = getFragmentParent(codeBlock);

      const highlightFragments = [
        ...codeBlock.querySelectorAll(SEL_HIGHLIGHT_FRAGMENT),
      ];
      if (highlightFragments.length === 0) continue;

      highlightFragments.sort((a, b) => getFragmentIndex(a) - getFragmentIndex(b));

      const anchorList = [...anchors];

      // QuartoLineHighlight removes data-code-line-numbers from
      // div.sourceCode and sets it individually on each clone.
      const fragmentLineSets = highlightFragments.map((frag) =>
        parseLineNumbers(frag.getAttribute("data-code-line-numbers") || "")
      );

      const cellId = sourceCodeDiv.id;
      const annotationLineSets = anchorList.map((anchor) =>
        getAnnotationLineSet(cellId, anchor.dataset.targetAnnotation)
      );

      // Match each highlight fragment with an annotation. Pass 1 requires
      // exact line-set equality; pass 2 accepts an annotation whose lines
      // are a subset of the highlight's lines (e.g., a single-line
      // annotation inside a multi-line highlight range).
      const highlightMatch = new Array(highlightFragments.length).fill(-1);
      const annotationMatch = new Array(anchorList.length).fill(-1);

      for (let h = 0; h < fragmentLineSets.length; h++) {
        if (fragmentLineSets[h].size === 0) continue;
        for (let a = 0; a < annotationLineSets.length; a++) {
          if (annotationMatch[a] !== -1) continue;
          if (setsEqual(fragmentLineSets[h], annotationLineSets[a])) {
            highlightMatch[h] = a;
            annotationMatch[a] = h;
            break;
          }
        }
      }

      for (let h = 0; h < fragmentLineSets.length; h++) {
        if (highlightMatch[h] !== -1) continue;
        if (fragmentLineSets[h].size === 0) continue;
        for (let a = 0; a < annotationLineSets.length; a++) {
          if (annotationMatch[a] !== -1) continue;
          if (isSubsetOf(annotationLineSets[a], fragmentLineSets[h])) {
            highlightMatch[h] = a;
            annotationMatch[a] = h;
            break;
          }
        }
      }

      // Check whether the original code (step 0, non-fragment)
      // matches any unmatched annotation. That annotation is shown
      // with the initial highlight state rather than as a fragment.
      const originalCode = codeBlock.querySelector("code:not(.fragment)");
      const step0Lines = parseLineNumbers(
        originalCode?.getAttribute("data-code-line-numbers") || ""
      );
      const step0Matched = new Set();

      if (step0Lines.size > 0) {
        let step0Annotation = -1;
        for (let a = 0; a < anchorList.length; a++) {
          if (annotationMatch[a] !== -1) continue;
          if (setsEqual(step0Lines, annotationLineSets[a])) {
            step0Annotation = a;
            break;
          }
        }
        if (step0Annotation === -1) {
          for (let a = 0; a < anchorList.length; a++) {
            if (annotationMatch[a] !== -1) continue;
            if (isSubsetOf(annotationLineSets[a], step0Lines)) {
              step0Annotation = a;
              break;
            }
          }
        }
        if (step0Annotation !== -1) {
          step0Matched.add(step0Annotation);
          codeBlock.dataset.step0Cell = cellId;
          codeBlock.dataset.step0Annotation =
            anchorList[step0Annotation].dataset.targetAnnotation;
        }
      }

      // Attach matched annotations at their highlight's existing index.
      for (let h = 0; h < highlightFragments.length; h++) {
        const a = highlightMatch[h];
        if (a === -1) continue;
        const sharedIndex = getFragmentIndex(highlightFragments[h]);
        appendAnnotationFragment(parentNode, anchorList[a], a, sharedIndex);
      }

      // Avoid colliding with non-annotation fragments above the last highlight clone.
      const slide = codeBlock.closest("section") ?? codeBlock;
      let maxSlideIndex = -1;
      for (const frag of slide.querySelectorAll(
        ".fragment[data-fragment-index]"
      )) {
        const idx = getFragmentIndex(frag);
        if (idx > maxSlideIndex) maxSlideIndex = idx;
      }
      let currentIndex = maxSlideIndex + 1;
      for (let a = 0; a < anchorList.length; a++) {
        if (annotationMatch[a] !== -1 || step0Matched.has(a)) continue;
        appendAnnotationFragment(parentNode, anchorList[a], a, currentIndex);
        currentIndex++;
      }
    }
  }

  // --- Tooltip events -------------------------------------------------------

  let pendingTooltipUpdate = null;

  /**
   * Schedule a deferred tooltip update for a slide.
   * Uses requestAnimationFrame so that when multiple fragments share
   * the same data-fragment-index, all shown/hidden events settle
   * before the tooltip state is resolved.
   * @param {Element} slide
   */
  function scheduleTooltipUpdate(slide) {
    if (pendingTooltipUpdate) cancelAnimationFrame(pendingTooltipUpdate);
    pendingTooltipUpdate = requestAnimationFrame(() => {
      pendingTooltipUpdate = null;
      hideAnnotationTooltips(slide);

      const current = slide.querySelectorAll(
        `${SEL_ANNOTATION_FRAGMENT}.current-fragment`
      );
      if (current.length > 0) {
        const last = current[current.length - 1];
        showAnnotationTooltip(
          last.dataset.targetCell,
          last.dataset.targetAnnotation
        );
        return;
      }

      // No current annotation fragment: check for step-0 annotations
      // (initial highlight state matches an annotation, no clone visible).
      for (const block of slide.querySelectorAll(
        `${SEL_ANNOTATED_CODE}[data-step0-cell]`
      )) {
        const visibleClones = block.querySelectorAll(
          `${SEL_HIGHLIGHT_FRAGMENT}.visible`
        );
        if (visibleClones.length === 0) {
          showAnnotationTooltip(
            block.dataset.step0Cell,
            block.dataset.step0Annotation
          );
        }
      }
    });
  }

  /**
   * Handle fragment shown/hidden events.
   * Triggers tooltip update for any fragment change on slides that
   * have annotation fragments, so tooltips hide correctly when a
   * non-annotation fragment follows the last annotation.
   * @param {Object} event
   */
  function onFragmentChanged(event) {
    const slide = (event.fragment || event.fragments?.[0])?.closest("section");
    if (!slide || !slide.dataset.hasAnnotationFragments) return;
    scheduleTooltipUpdate(slide);
  }

  /**
   * Handle slide changed events.
   * Restores the tooltip for the current annotation fragment on the
   * new slide (fixes backward navigation where Reveal.js enters at
   * max fragment state without firing fragmentshown events).
   * @param {Object} event
   */
  function onSlideChanged(event) {
    if (event.previousSlide?.dataset.hasAnnotationFragments) {
      hideAnnotationTooltips(event.previousSlide);
    }
    const slide = event.currentSlide;
    if (slide?.dataset.hasAnnotationFragments) scheduleTooltipUpdate(slide);
  }

  // --- PDF export -----------------------------------------------------------

  /**
   * Collect annotation fragment steps for a slide, sorted by fragment index.
   * Returns an array of objects: { index, targetCell, targetAnnotation }.
   * When multiple annotation fragments share the same index (sync mode),
   * only one entry per index is returned (the last one by DOM order).
   * @param {Element} slide
   * @returns {Array<{index: number, targetCell: string, targetAnnotation: string}>}
   */
  function getAnnotationSteps(slide) {
    const fragments = slide.querySelectorAll(SEL_ANNOTATION_FRAGMENT);
    if (fragments.length === 0) return [];

    const byIndex = new Map();
    for (const frag of fragments) {
      const index = getFragmentIndex(frag);
      byIndex.set(index, {
        index,
        targetCell: frag.dataset.targetCell,
        targetAnnotation: frag.dataset.targetAnnotation,
      });
    }

    return [...byIndex.values()].sort((a, b) => a.index - b.index);
  }

  /**
   * Set fragment visibility state on a cloned page element.
   * All fragments with index <= upToIndex become visible.
   * The fragment at exactly atIndex becomes current-fragment.
   * @param {Element} page
   * @param {number} upToIndex
   * @param {number} atIndex
   */
  function setFragmentState(page, upToIndex, atIndex) {
    const allFragments = page.querySelectorAll(".fragment[data-fragment-index]");
    for (const frag of allFragments) {
      const idx = getFragmentIndex(frag);
      frag.classList.remove("visible", "current-fragment");
      if (idx <= upToIndex) {
        frag.classList.add("visible");
        if (idx === atIndex) {
          frag.classList.add("current-fragment");
        }
      }
    }
  }

  /**
   * Show annotation tooltip on a PDF page by creating a tippy instance
   * on the cloned anchor (cloneNode does not copy JS state).
   * @param {Element} page
   * @param {string} targetCell
   * @param {string} targetAnnotation
   */
  function showPdfAnnotation(page, targetCell, targetAnnotation) {
    if (typeof window.tippy !== "function") return;

    const selector = buildAnchorSelector(targetCell, targetAnnotation);
    const anchor = page.querySelector(selector);
    if (!anchor) return;

    // Find the annotation content from the description list on this page.
    const dl = page.querySelector("dl.code-annotation-container-grid");
    if (!dl) return;

    const dt = dl.querySelector(
      `dt[data-target-cell="${targetCell}"][data-target-annotation="${targetAnnotation}"]`
    );
    const dd = dt ? dt.nextElementSibling : null;
    if (!dd || dd.tagName !== "DD") return;

    const tipContent = dd.cloneNode(true);
    tipContent.classList.add("code-annotation-tip-content");

    // Destroy any existing instance (e.g. on the original, non-cloned page).
    if (anchor._tippy) anchor._tippy.destroy();

    const appendTarget = page.closest(".pdf-page") || anchor.closest("section") || page;
    window.tippy(anchor, {
      allowHTML: true,
      content: tipContent.outerHTML,
      maxWidth: 300,
      arrow: true,
      trigger: "manual",
      showOnCreate: true,
      hideOnClick: false,
      appendTo: appendTarget,
      interactive: false,
      theme: "light-border",
      placement: "right",
      popperOptions: {
        modifiers: [
          {
            name: "flip",
            options: {
              fallbackPlacements: ["left", "bottom", "top"],
            },
          },
          {
            name: "preventOverflow",
            options: {
              boundary: appendTarget,
              mainAxis: true,
              altAxis: true,
              padding: 8,
            },
          },
        ],
      },
    });
  }

  /**
   * Handle PDF export when pdfSeparateFragments is already enabled.
   * Reveal.js has cloned pages per fragment step. Show the correct
   * annotation tooltip on each page that has a current annotation fragment.
   * @param {NodeList} slides
   */
  function handlePdfWithSeparateFragments(slides) {
    for (const slide of slides) {
      if (!slide.dataset.hasAnnotationFragments) continue;

      const current = slide.querySelector(
        `${SEL_ANNOTATION_FRAGMENT}.current-fragment`
      );
      if (current) {
        showPdfAnnotation(
          slide.closest(".pdf-page") || slide,
          current.dataset.targetCell,
          current.dataset.targetAnnotation
        );
      }
    }
  }

  /**
   * Handle PDF export when pdfSeparateFragments is disabled (default).
   * Clones slides for each annotation step so that each annotation
   * appears on its own PDF page without affecting other slides.
   * @param {NodeList} slides
   */
  function handlePdfWithoutSeparateFragments(slides) {
    for (const slide of slides) {
      if (!slide.dataset.hasAnnotationFragments) continue;

      const steps = getAnnotationSteps(slide);
      if (steps.length === 0) continue;

      const pageElement = slide.closest(".pdf-page") || slide;

      // Show annotation 0 on the original page.
      setFragmentState(pageElement, steps[0].index, steps[0].index);
      showPdfAnnotation(
        pageElement,
        steps[0].targetCell,
        steps[0].targetAnnotation
      );

      // Clone for each remaining annotation step.
      let insertAfter = pageElement;
      for (let i = 1; i < steps.length; i++) {
        const clone = pageElement.cloneNode(true);
        setFragmentState(clone, steps[i].index, steps[i].index);
        showPdfAnnotation(
          clone,
          steps[i].targetCell,
          steps[i].targetAnnotation
        );

        insertAfter.parentNode.insertBefore(clone, insertAfter.nextSibling);
        insertAfter = clone;
      }
    }
  }

  /**
   * Entry point for PDF export handling.
   * @param {Object} config
   */
  function handlePdfExport(config) {
    // Snapshot into a static array: cloning inserts new section elements
    // which would cause a live NodeList to grow during iteration.
    const slides = [...document.querySelectorAll(".reveal .slides section")];

    if (config.pdfSeparateFragments) {
      handlePdfWithSeparateFragments(slides);
    } else {
      handlePdfWithoutSeparateFragments(slides);
    }
  }

  // --- Plugin entry ---------------------------------------------------------

  return {
    id: "RevealJsCodefrag",

    init: function (deck) {
      const config = deck.getConfig();

      deck.on("ready", patchAnnotationTooltips);

      if (!getEnabled(config)) return;

      // Phase 1: before Reveal.js sortAll() for correct DOM-order indexing.
      createAnnotationFragments();
      applyLineHighlightIndices();

      // Phase 2: after sortAll() has assigned final highlight indices.
      deck.on("ready", setupLineHighlightAnnotations);

      deck.on("fragmentshown", onFragmentChanged);
      deck.on("fragmenthidden", onFragmentChanged);
      deck.on("slidechanged", onSlideChanged);

      // PDF export: clone annotated slides so each step gets its own page.
      deck.on("pdf-ready", function () {
        handlePdfExport(deck.getConfig());
      });
    },
  };
};
