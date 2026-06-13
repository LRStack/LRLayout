# LRLayout

A collection of CSS layout classes. Responsiveness built in.

LRLayout is a small set of composable layout primitives that handle spacing and
responsiveness intrinsically — they adapt to the space available **without media
queries**. Every class is tuned per-instance through a handful of CSS
custom-property "knobs" that you set directly or via ready-made modifier classes.

- [`cluster`](#cluster) — even-gapped items that wrap; the go-to for most rows
- [`stack`](#stack) — vertical rhythm between children
- [`split`](#split) — push zones to opposite ends
- [`frame`](#frame) — fixed-ratio media, cropped to fit
- [`flank`](#flank) — a sidebar beside a flexible main region
- [`grid`](#grid) — auto-fitting responsive columns

## Installation

LRLayout will be distributed on npm:

```bash
npm install @lrstack/lrlayout
```

> **Heads up:** the package isn't published yet. Until it is, build
> `dist/lrlayout.css` locally (see [Development](#development)) or vendor the
> `src/` SCSS into your project. The usage below is written for the published
> package.

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
layout never leaks into a nested one.

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
the main region would fall below `--content-min` — no media queries. Add
`.lr-flank-end` to move the sidebar to the trailing side without changing the
markup order.

```html
<div class="lr-flank" style="--side: 14rem">
  <aside>Sidebar</aside>
  <main>Main content…</main>
</div>
```

Knobs: `--side` (16rem) · `--content-min` (50%) · `--gap` (md) · `--items` (stretch) · `--pad` (0)
Modifier: `.lr-flank-end`

### grid

A responsive grid that auto-fits as many columns as will hold `--min`, reflowing
the count as it resizes. Set `--cols` to a number for a fixed column count.

```html
<div class="lr-grid" style="--min: 12rem">
  <div>…</div><div>…</div><div>…</div>
</div>
```

Knobs: `--min` (16rem) · `--cols` (auto-fit) · `--gap` (md) · `--pad` (0)

## Modifiers

Modifier classes set a knob, so they compose across every layout.

| Family    | Classes                                                  | Sets                                          |
| --------- | -------------------------------------------------------- | --------------------------------------------- |
| gap       | `.lr-gap-{0,xs,sm,md,lg,xl,2xl}`                         | `--gap`                                        |
| pad       | `.lr-pad-{0,xs,sm,md,lg,xl,2xl}`                         | `--pad` (padding)                              |
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
stylesheet at `dist/lrlayout.css`. There is intentionally **no `package.json` /
`node_modules`** — use whichever Sass compiler and static server you already
trust. Pick one of the setups below.

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

To compile once without watching:

```bash
sass src/lrlayout.scss dist/lrlayout.css --no-source-map --style=expanded
```

## Showcase

The `showcase/` directory demonstrates each layout class on its own page, plus a
combined **full-page app** example at `showcase/combined.html` that composes all
of them. Start a server (above) and open `showcase/index.html`.
