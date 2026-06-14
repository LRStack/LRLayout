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
- **cover** *(high value)* — a region that fills its space (e.g.
  `min-block-size`) with a vertically-centered principal child and optional
  pinned header/footer. There is no vertical-centering primitive today.
- **imposter / overlay** — an absolutely-positioned centered box over another
  (modal, badge, a play button on a `frame`). `frame` centers *media* but can't
  position an arbitrary overlay.
- **two-sided flank** — `flank` is single-sidebar only; no sidebar-both-ends
  layout.

## Gaps inside existing primitives

- **Separate row/column gap** *(small, high impact)* — add `--gap-x` / `--gap-y`
  alongside `--gap`. Bites most on `cluster` (wrapped rows often want a tighter
  vertical gap) and `grid`.
- **`grid` alignment** *(small, high impact)* — `grid` reads `--gap` / `--cols` /
  `--min` but ignores `--items`, `--justify`, and `align-content`. Can't align
  items within tracks; no modifier class for `auto-fill` (must use inline
  `--cols: auto-fill`); no row-height control.
- **`stack` bottom-pin** — express the "fill height, push the last child to the
  bottom" pattern (auto-margin on the last child). Common inside cards.
- **`frame` child list is closed** — currently `img` / `video` / `picture` /
  `iframe`. An `svg`, `canvas`, or `embed` child won't be sized.

## Missing modifiers / knobs

- **`align-content`** — nothing exposes multi-line cross-axis distribution, which
  is exactly what matters once `cluster` / `grid` wrap to multiple lines.
- **Self-alignment** — no `align-self` override or auto-margin helper to push one
  item to the end of a `cluster` / `split`. A single item can't break from the
  group's alignment today.
- **Bottom sticky** — sticky is top-only (`--sticky-top` / `top` hardcoded). No
  bottom-pinning variant for footer bars.
- **`order`** — no helper for source-order-independent reordering (only flank's
  end-swap exists).

## Distribution / process

- **Minified build** — npm ships only the expanded `dist/lrlayout.css`; no
  `.min.css` and no shipped source map.
- **Tests** — no visual-regression or rendering checks; the showcase is the only
  verification surface.
- **CHANGELOG** — none yet.
- **1.0 / API freeze** — currently `0.1.x`; the knob and class API isn't frozen.

## Explicitly not a gap

- **RTL / writing-mode** — already handled well via `margin-inline` /
  `inline-size` and flex row-direction; most of it works logically out of the
  box. (Sticky's physical `top` is the one holdout — see Bottom sticky above.)
