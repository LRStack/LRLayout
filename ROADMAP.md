# Roadmap

Candidate work for LRLayout, not promises. The library is pre-1.0, so the knob
and class API isn't frozen — items here are triage notes for deciding what's
worth adding before that line is drawn. Shipped behavior lives in `README.md`;
this file is only the backlog.

Rough priority lean is noted per section, not a committed order.

## Missing primitives

Classic intrinsic-layout primitives with no current equivalent.

- ~~**switcher**~~ — *shipped.* The "all-or-nothing" flip from a horizontal row
  to a fully stacked column at a threshold. See the `switcher` section in `README.md`.
- ~~**cover**~~ — *shipped.* A region that fills at least `--min` of block space
  with a vertically-centered principal child (`.lr-cover-center`) and optional
  pinned header/footer. The library's block-axis centering primitive. See the
  `cover` section in `README.md`.
- ~~**imposter / overlay**~~ — *shipped* as `overlay`. An out-of-flow child
  positioned over the host's other content (play button on a `frame`, corner
  badge, dialog over a backdrop): a `.lr-overlay` host (positioning context only)
  plus a `.lr-overlay-item` child, centered by default with
  `top`/`bottom`/`start`/`end` placement modifiers and a `.lr-overlay-contain`
  option. See the `overlay` section in `README.md`.
- ~~**two-sided flank**~~ — *shipped* as `.lr-flank-both`. Alongside the rename of
  the single-sided variants to `.lr-flank-start` / `.lr-flank-end` (there is no
  bare `.lr-flank`), a third variant puts a sidebar at each end of a flexible
  centre, wrapping progressively. Adds `--side-start` / `--side-end` knobs. See
  the `flank` section in `README.md`.

## Gaps inside existing primitives

- ~~**Separate row/column gap**~~ — *shipped.* `--gap-x` (column gap) / `--gap-y`
  (row gap) override `--gap` per axis, with `.lr-gap-x-*` / `.lr-gap-y-*`
  modifiers from the spacing scale. Available on every gap-bearing primitive;
  most useful on a wrapped `cluster` / `grid`. See the gap note in `README.md`.
- ~~**`grid` alignment**~~ — *shipped.* `grid` now reads `--items` (align-items,
  item-in-track), `--justify` (justify-content, track distribution), and
  `--content` (align-content) — the flex modifier classes apply unchanged.
  `.lr-cols-fit` / `.lr-cols-fill` expose the `auto-fit` / `auto-fill` keywords,
  and `--rows` maps to `grid-auto-rows` for row-height control. See the `grid`
  section in `README.md`; design record in `docs/grid-alignment.md`.
- **`stack` bottom-pin** — express the "fill height, push the last child to the
  bottom" pattern (auto-margin on the last child). Common inside cards.
- **`frame` child list is closed** — currently `img` / `video` / `picture` /
  `iframe`. An `svg`, `canvas`, or `embed` child won't be sized.

## Missing modifiers / knobs

- ~~**`align-content`**~~ — *shipped.* `--content` + the `.lr-content-*` modifier
  family set `align-content` (multi-line block-axis distribution) on `grid`,
  `cluster`, and `split`. See the gap/alignment notes in `README.md`.
- ~~**Self-alignment**~~ — *shipped.* Two per-item modifier families let a single
  child break from the group: `.lr-self-*` (`align-self`, the per-item counterpart
  to `.lr-items-*`) and `.lr-push-start` / `.lr-push-end` (main-axis auto-margin
  shoving one item to an edge). See the modifiers table in `README.md`; design
  record in `docs/self-alignment.md`. (Block-axis bottom-pin stays the separate
  **`stack` bottom-pin** item below — push is inline-axis only.)
- **Bottom sticky** — sticky is top-only (`--sticky-top` / `top` hardcoded). No
  bottom-pinning variant for footer bars.
- **`order`** — no helper for source-order-independent reordering (only flank's
  end-swap exists).

## Distribution / process

- **Minified build** — npm ships only the expanded `dist/lrlayout.css`; no
  `.min.css` and no shipped source map.
- ~~**Tests**~~ — *shipped.* `npm test` (`test/run.sh`) builds `dist/` and drives
  a Chromium-family browser headless via `--dump-dom`, asserting computed-style
  contracts and container-driven layout geometry against the real built CSS.
  Zero-dependency: global `sass` plus an auto-detected browser (`$CHROME_BIN`
  override; Linux/macOS — Windows not covered by design). Covers every layout
  primitive and modifier plus the `@layer` / `@property` cascade contracts. Open
  follow-ups: no **CI** runs it yet (a workflow would need to install a browser,
  e.g. `apt-get install -y chromium`); no visual-regression / screenshot diffing
  (the showcase remains the eyeball surface for that).
- **CHANGELOG** — none yet.
- **1.0 / API freeze** — currently `0.1.x`; the knob and class API isn't frozen.

## Explicitly not a gap

- **RTL / writing-mode** — already handled well via `margin-inline` /
  `inline-size` and flex row-direction; most of it works logically out of the
  box. (Sticky's physical `top` is the one holdout — see Bottom sticky above.)
