# LRLayout

A collection of CSS layout classes. Responsiveness built in.

LRLayout is a small set of composable layout primitives that handle spacing and
responsiveness intrinsically — they adapt to the space available **without media
queries**. Every class is tuned per-instance through a handful of CSS
custom-property "knobs" that you set directly or via ready-made modifier classes.

- [`cluster`](#cluster) — even-gapped items that wrap; the go-to for most rows
- [`switcher`](#switcher) — a few equal items that flip to a column all at once
- [`stack`](#stack) — vertical rhythm between children
- [`split`](#split) — push zones to opposite ends
- [`frame`](#frame) — fixed-ratio media, cropped to fit
- [`flank`](#flank) — a sidebar beside a flexible main region
- [`grid`](#grid) — auto-fitting responsive columns
- [`center`](#center) — a max-width content column, centered in its container
- [`cover`](#cover) — a region that fills the viewport with a centered child
- [`overlay`](#overlay) — a child floated over the rest, centered or pinned

## Installation

LRLayout is distributed on npm:

```bash
npm install @lrstack/lrlayout
```

## Usage

### Plain CSS

Link the compiled stylesheet, or import it through your bundler:

```html
<link rel="stylesheet" href="node_modules/@lrstack/lrlayout/dist/lrlayout.css" />
```

```js
// …or from JavaScript, with a bundler
import "@lrstack/lrlayout/dist/lrlayout.css";
```

### In your SCSS

Pull the library into your own Sass build with `@use`:

```scss
@use "@lrstack/lrlayout";
```

- **Bundlers** (Vite, webpack + `sass-loader`, Parcel, …) resolve that from
  `node_modules` automatically.
- **Dart Sass CLI** — use the package importer:
  `@use "pkg:@lrstack/lrlayout";` (run `sass` with `--pkg-importer=node`); or add
  `node_modules` to the load path and `@use "@lrstack/lrlayout/src/lrlayout";`.

LRLayout is configured entirely through **runtime CSS custom properties** — the
knobs and the `--lr-space-*` scale — so there's nothing to pass at `@use` time.
Adjust it by overriding those properties in your own CSS (see
[Customizing](#customizing)).

### Composing

However you include it, compose with the classes — primitives nest freely:

```html
<div class="lr-stack lr-gap-lg">
  <header class="lr-split lr-items-center">
    <strong>Logo</strong>
    <nav class="lr-cluster lr-gap-sm">
      <a href="#">Docs</a>
      <a href="#">Pricing</a>
    </nav>
  </header>
</div>
```

## How it's configured

Every primitive reads a small set of **knobs** — CSS custom properties with sensible
fallbacks. Drive a knob two ways; both land on the same `var()`:

```html
<!-- a modifier class -->
<div class="lr-cluster lr-gap-lg"> … </div>

<!-- or set the custom property inline (for one-off / non-scale values) -->
<div class="lr-cluster" style="--gap: 2rem"> … </div>
```

Knobs are registered with `@property … { inherits: false }`, so a value set on one
layout never leaks into a nested one. (The single deliberate exception is flank's
`--flank-basis`, which inherits on purpose — see [flank](#flank).)

## Layouts

### cluster

Even-gapped items that wrap onto new lines as space runs out — tags, button bars,
nav. The go-to primitive for most rows.

```html
<div class="lr-cluster lr-gap-sm">
  <span>one</span><span>two</span><span>three</span>
</div>
```

Knobs: `--gap` (md) · `--justify` (flex-start) · `--items` (center) · `--wrap` (wrap) · `--pad` (0)

### switcher

A small set of equal-width items that share one row, then flip — all together,
all at once — to a full-width stacked column when the container drops below
`--threshold`. No media queries: the switch rides a flexbox quantity query. Use
it for a *small* number of peers (two panels, a three-up card row); where
`cluster` wraps one item at a time, `switcher` is all-or-nothing.

```html
<div class="lr-switcher" style="--threshold: 30rem">
  <div>One</div><div>Two</div><div>Three</div>
</div>
```

Knobs: `--threshold` (30rem) · `--gap` (md) · `--items` (stretch) · `--pad` (0)

`--threshold` is an *approximate* switch width: the gap isn't subtracted from the
internal math, so the real flip lands a touch wider than the value you set.
There's deliberately no count limit — for an arbitrary-length list of cards reach
for [`grid`](#grid) instead, which reflows the column count a row at a time.

### stack

Vertical flow with even spacing between children; the gap sits *between* items
only, so the first/last child stay flush with the stack's padding edges.

```html
<div class="lr-stack lr-gap-md">
  <h2>Title</h2>
  <p>Paragraph…</p>
  <button>Action</button>
</div>
```

Knobs: `--gap` (md) · `--pad` (0)

### split

Pushes children to opposite ends of the row (`space-between`). Works for two or
more items, and wraps to stacked when the row gets too tight.

```html
<div class="lr-split lr-items-center">
  <strong>Brand</strong>
  <nav class="lr-cluster lr-gap-sm"> … </nav>
</div>
```

Knobs: `--gap` (md) · `--justify` (space-between) · `--items` (center) · `--wrap` (wrap) · `--pad` (0)

### frame

A fixed aspect-ratio box that crops its media with `object-fit`. Accepts an
`img`, `video`, `picture`, or `iframe` child.

```html
<div class="lr-frame" style="--ratio: 4 / 3">
  <img src="photo.jpg" alt="" />
</div>
```

Knobs: `--ratio` (16 / 9) · `--object` (cover) · `--pad` (0)

### flank

A sidebar of intrinsic width beside a flexible main region. Wraps to stacked when
the main region would fall below `--content-min` — no media queries. Comes in
three variants, each used on its own (there is no bare `.lr-flank`):

- `.lr-flank-start` — sidebar on the leading edge, main after it.
- `.lr-flank-end` — sidebar on the trailing edge, main before it.
- `.lr-flank-both` — a sidebar at each end with a flexible centre (three children).

```html
<div class="lr-flank-start" style="--side: 14rem">
  <aside>Sidebar</aside>
  <main>Main content…</main>
</div>
```

Knobs: `--side` (16rem) · `--side-start` / `--side-end` (`-both` only, fall back to `--side`) · `--flank-basis` (16rem, inherits) · `--content-min` (50%) · `--gap` (md) · `--items` (stretch) · `--pad` (0)
Variants: `.lr-flank-start` · `.lr-flank-end` · `.lr-flank-both`

`--side` sizes the sidebar on a single flank. `--flank-basis` does the same but
**inherits**, so setting it once on an ancestor — say a `<form>` — gives every
nested flank the same sidebar width. That's the way to line up a column of form
labels: make each `<label>` a flank and set the column width on the form.
`--side` wins when both are set.

```html
<form class="lr-stack lr-gap-md" style="--flank-basis: 8rem">
  <label class="lr-flank-start lr-items-center"><span>Full name</span><input /></label>
  <label class="lr-flank-start lr-items-center"><span>Email address</span><input /></label>
</form>
```

`.lr-flank-both` flanks the centre on both sides. It expects exactly three element
children — start sidebar, main, end sidebar — and wraps progressively as space
tightens: the trailing rail drops below first, then the leading one, ending fully
stacked in source order. Size both rails together with `--side`, or independently
with `--side-start` / `--side-end` (each falls back to `--side`).

```html
<div class="lr-flank-both" style="--side-start: 9rem; --side-end: 13rem">
  <nav>Nav rail</nav>
  <main>Main content…</main>
  <aside>Aside</aside>
</div>
```

### grid

A responsive grid that auto-fits as many columns as will hold `--min`, reflowing
the count as it resizes. Set `--cols` to a number for a fixed column count.

```html
<div class="lr-grid" style="--min: 12rem">
  <div>…</div><div>…</div><div>…</div>
</div>
```

Knobs: `--min` (16rem) · `--cols` (auto-fit) · `--gap` (md) · `--pad` (0)

### center

A content column capped at `--max` and centered in its container with auto inline
margins — the page/content wrapper most layouts sit inside, and usually the first
primitive you reach for. It stays a plain block, so it composes both ways: nest a
layout inside it, or apply it to the same element as one.

```html
<div class="lr-center" style="--max: 60rem">
  <article class="lr-stack lr-gap-md"> … </article>
</div>

<!-- …or on the same element -->
<main class="lr-center lr-stack lr-gap-lg" style="--max: 60rem"> … </main>
```

`--pad` doubles as a gutter: with border-box sizing it keeps content off the edges
on viewports narrower than `--max`, while the column never grows past `--max`.

Knobs: `--max` (60rem) · `--pad` (0)

### cover

A region that fills at least `--min` of block space (default `100svh`) with one
vertically-centered principal child and optional header/footer pinned to the top
and bottom edges. The library's only block-axis centering primitive — the classic
full-viewport hero or a card centered in the screen. Mark the centered child with
`.lr-cover-center`; a sole child centers on its own.

```html
<div class="lr-cover lr-pad-md">
  <header>Brand</header>
  <h1 class="lr-cover-center">Hero headline</h1>
  <footer>Scroll ↓</footer>
</div>
```

The centered child takes `margin-block: auto`, which in a flex column absorbs the
free space above and below it — so it lands at the container's center whatever the
header/footer height. `--gap` is the *minimum* space between regions; the
auto-margins stack on top of it and never collapse it. `--min` is a *minimum*, so
content taller than it grows the region rather than overflowing.

`cover` only centers on the **block (vertical) axis** — horizontal alignment is
the normal flex cross-axis, so by default (`--items: stretch`) the child spans the
full width. For a hero, center the *content* (e.g. a `stack` child with
`lr-items-center` and centered text); for a lone card centered both ways, set
`--items: center`.

Knobs: `--min` (100svh) · `--gap` (md) · `--items` (stretch) · `--pad` (0)
Child marker: `.lr-cover-center`

`.lr-cover-center` is the one class in the library that targets a *child* rather
than the container — the centered slot sits between header and footer, so it can't
be picked positionally. Mark at most one child. Centering works by giving that
child `margin-block: auto`, so a global margin reset (`* { margin: 0 }` or
`h2 { margin: 0 }`) in your own *unlayered* CSS will override it and defeat the
centering — put the marker on a wrapper element, or scope your reset with
`:where()` so it doesn't outrank the library layer. Note also that `--min` is
shared with [`grid`](#grid) (min column width there); they only collide if both
classes land on the same element, which is a meaningless combination.

### overlay

Floats one child *over* the region's other content — a play button on a
[`frame`](#frame), a badge on an avatar, a dialog over a backdrop. Where `frame`
and `cover` center content that stays in flow, `overlay` takes a child *out of
flow* and positions it on top, leaving the rest of the region undisturbed. (The
classic "imposter" of intrinsic-layout lore.) Like [`cover`](#cover) it's a
container plus a child marker:

- `.lr-overlay` on the host establishes the positioning context **and nothing
  else**, so it composes onto any element or primitive — add it to a `frame` and
  the frame becomes the stage.
- `.lr-overlay-item` on the floated child centers it over the host by default.

```html
<!-- a play button centered over a frame -->
<div class="lr-frame lr-overlay">
  <img src="photo.jpg" alt="" />
  <button class="lr-overlay-item">▶</button>
</div>
```

Centering uses symmetric insets plus `margin: auto` (not a `translate`), so the
item lands centered with no knowledge of its own size, and `fit-content` keeps it
shrink-wrapped and capped to the host so it can't spill sideways.

To leave the center, add a **placement modifier** to the item. Each one drops the
constraint on a single edge, pulling the item to the opposite one; combine two
non-opposite modifiers for a corner. They're logical (`start`/`end`), so corners
flip under RTL.

```html
<!-- a notification badge in the top-trailing corner -->
<div class="lr-overlay">
  <img class="avatar" src="me.jpg" alt="" />
  <span class="lr-overlay-item lr-overlay-top lr-overlay-end" style="--inset: .15rem">3</span>
</div>
```

`--inset` holds the item that far off its pinned edges (default `0`); set it on
the **item**, the element that reads it. For content that can outgrow the host —
a tall dialog — add `.lr-overlay-contain`: the item caps itself to the host
(minus `--inset` on each side) and scrolls internally rather than bleeding past
the edges.

```html
<div class="lr-overlay">
  <div class="backdrop"></div>
  <div class="lr-overlay-item lr-overlay-contain" style="--inset: 1rem"> … </div>
</div>
```

Knobs: `--inset` (0, set on the item)
Classes: `.lr-overlay` (host) · `.lr-overlay-item` (child) · `.lr-overlay-{top,bottom,start,end}` (placement) · `.lr-overlay-contain`

A host that clips its overflow — `frame` does, via `overflow: hidden` — also
clips an overlay item larger than itself. That's usually what you want for a
media overlay, but it means a tooltip or menu that needs to escape the host's
box wants a plain (non-clipping) host instead. `overlay` positions *within* a
container; for a modal over the whole page, make a full-viewport element the
host (or override the item to `position: fixed` in your own CSS).

## Modifiers

Modifier classes set a knob, so they compose across every layout.

| Family    | Classes                                                  | Sets                                          |
| --------- | -------------------------------------------------------- | --------------------------------------------- |
| gap       | `.lr-gap-{0,xs,sm,md,lg,xl,2xl}`                         | `--gap`                                        |
| pad       | `.lr-pad-{0,xs,sm,md,lg,xl,2xl}`                         | `padding` (works on any element)               |
| items     | `.lr-items-{start,center,end,stretch,baseline}`          | `--items` (`align-items`)                      |
| justify   | `.lr-justify-{start,center,end,between,around,evenly}`   | `--justify` (`justify-content`)                |
| wrap      | `.lr-wrap`, `.lr-nowrap`, `.lr-wrap-reverse`             | `--wrap` (`flex-wrap`)                         |
| scroll    | `.lr-scroll`, `.lr-scroll-x`, `.lr-scroll-y`             | overflow (+ `scrollbar-gutter` on vertical)    |
| sticky    | `.lr-sticky`                                             | `position: sticky; top: var(--sticky-top, 0)` |

The gap/pad spacing scale (`--lr-space-*`):

| step  | 0   | xs     | sm    | md   | lg     | xl   | 2xl  |
| ----- | --- | ------ | ----- | ---- | ------ | ---- | ---- |
| value | 0   | .25rem | .5rem | 1rem | 1.5rem | 2rem | 3rem |

- **scroll** — the vertical variants reserve a stable scrollbar gutter
  (`scrollbar-gutter: var(--gutter, stable)`) to avoid layout shift; tune with
  `--gutter` (`auto`, `stable both-edges`).
- **sticky** — `--sticky-top` sets the offset (default `0`). Includes
  `align-self: start` so a sticky flex item (e.g. a flank sidebar) isn't stretched
  to full height, which would stop it pinning.

## Customizing

Retune the spacing scale globally with an ordinary `:root` override — the
modifiers point at these tokens, so they follow:

```css
:root { --lr-space-lg: 1.25rem; }
```

Override any rule with a plain selector. The library is wrapped in
`@layer lrlayout`, and **unlayered CSS always wins over layered CSS**, so you
never need `!important` or a specificity fight:

```css
.lr-cluster { gap: 0.25rem; } /* wins over the library */
```

## Browser support

Modern evergreen browsers. LRLayout relies on `@layer`, `@property`,
`aspect-ratio`, `:is()`, and `min()` — all shipped across Chrome/Edge, Firefox,
and Safari since early 2022. `scrollbar-gutter` (used by the scroll modifier) is
newer in Safari (18.2) but degrades gracefully where unsupported.

## Development

The library is authored in **SCSS** under `src/` and compiles to a single
stylesheet at `dist/lrlayout.css`. A `package.json` exists for npm publishing;
it has no dev dependencies, so **no `node_modules`** are needed for development.
Use whichever Sass compiler and static server you already trust. Pick one of the
setups below.

You need two things while developing:

1. **A Sass compiler** watching `src/lrlayout.scss` → `dist/lrlayout.css`.
2. **A static server** for the `showcase/` pages (they link `../dist/lrlayout.css`),
   ideally with live reload.

### Option A — Editor extensions (no terminal)

**VS Code:**

- [**Live Sass Compiler**](https://marketplace.visualstudio.com/items?itemName=glenn2223.live-sass)
  compiles the SCSS on save. Point its output at `dist/` by adding this to your
  workspace `settings.json`:

  ```json
  "liveSassCompile.settings.formats": [
    { "format": "expanded", "extensionName": ".css", "savePath": "/dist" }
  ]
  ```

  Then click **Watch Sass** in the status bar. (Partials prefixed with `_` are
  ignored automatically; only `src/lrlayout.scss` is emitted.)

- [**Live Server**](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)
  serves the project with auto-reload. Right-click `showcase/index.html` →
  **Open with Live Server**.

**JetBrains IDEs (WebStorm, etc.):** use a built-in **File Watcher** for SCSS and
the built-in web server (just open `showcase/index.html` in the browser from the
IDE).

### Option B — `browser-sync` + Dart Sass (terminal)

Install the tools once, globally (or use the standalone
[Dart Sass](https://github.com/sass/dart-sass/releases) and
[browser-sync](https://browsersync.io/) binaries — no project dependencies):

```bash
npm install -g sass browser-sync   # or install the standalone binaries
```

Run each in its own terminal:

```bash
# 1. compile + watch the SCSS
sass --watch src/lrlayout.scss:dist/lrlayout.css --no-source-map

# 2. serve the showcase with live reload
browser-sync start --server \
  --startPath showcase/index.html \
  --files "dist/*.css, showcase/**/*"
```

### One-off build

To compile once without watching, use the npm script (requires `sass` installed
globally):

```bash
npm run build
```

Or invoke Sass directly:

```bash
sass src/lrlayout.scss dist/lrlayout.css --no-source-map --style=expanded
```

## Showcase

The `showcase/` directory demonstrates each layout class on its own page, plus a
combined **full-page app** example at `showcase/combined.html` that composes all
of them. Start a server (above) and open `showcase/index.html`.

## Releasing

Before cutting a release, bump the version in `package.json`:

```bash
npm version patch --no-git-tag-version
```

Use `patch` for bug fixes, `minor` for new features, `major` for breaking
changes. The `--no-git-tag-version` flag updates `package.json` without
creating a commit or tag — commit the version bump yourself as part of your
normal flow.

Once the version is committed and pushed, create a GitHub Release. The
[publish workflow](.github/workflows/publish.yml) triggers on release and runs
`npm publish` automatically.
