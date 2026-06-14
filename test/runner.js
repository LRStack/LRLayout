// =============================================================================
// LRLayout test runner — zero-dependency, browser-driven.
// -----------------------------------------------------------------------------
// Loaded by test/*.html before that page's inline <script> registers cases via
// LR.test(name, fn). Each case runs inside the `load` event (so the stylesheet
// is applied and layout is settled), asserts against getComputedStyle /
// geometry, and the results are serialized into the DOM. test/run.sh then reads
// the page back with Chromium `--dump-dom` and greps the summary line:
//
//     RESULT: PASS=<n> FAIL=<m>
//
// Any FAIL (or a missing summary) fails the suite. Each failure is printed as
//     FAIL: <name> — <detail>
// so the dump is self-describing without needing the browser open.
// =============================================================================

window.LR = (function () {
  const cases = [];
  const results = [];

  // --- assertions ------------------------------------------------------------
  function assert(name, pass, detail) {
    results.push({ name, pass: !!pass, detail: detail || "" });
  }

  // Numbers from layout never land exactly; allow a sub-pixel slop.
  function near(a, b, tol) {
    return Math.abs(a - b) <= (tol == null ? 0.5 : tol);
  }
  function assertNear(name, actual, expected, tol) {
    assert(
      name,
      near(actual, expected, tol),
      `expected ≈${expected}px, got ${round(actual)}px`
    );
  }
  function assertEq(name, actual, expected) {
    assert(name, actual === expected, `expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
  }
  function round(n) {
    return Math.round(n * 100) / 100;
  }

  // --- DOM / layout helpers --------------------------------------------------
  function fixtures() {
    return document.getElementById("fixtures");
  }
  // Parse an HTML string to one element and mount it; returns the element.
  function el(html) {
    const tpl = document.createElement("template");
    tpl.innerHTML = html.trim();
    const node = tpl.content.firstElementChild;
    fixtures().appendChild(node);
    return node;
  }
  function kids(node) {
    return Array.from(node.children);
  }
  // px length of n rem, per the document's actual root font-size.
  function rem(n) {
    const root = parseFloat(getComputedStyle(document.documentElement).fontSize);
    return n * root;
  }
  function style(node, prop) {
    return getComputedStyle(node)[prop];
  }
  function px(node, prop) {
    return parseFloat(getComputedStyle(node)[prop]);
  }
  function rect(node) {
    return node.getBoundingClientRect();
  }
  // Count of distinct column positions among siblings — i.e. grid column count.
  function colCount(nodes) {
    return new Set(nodes.map((n) => Math.round(rect(n).left))).size;
  }
  // All elements share a top edge (one row).
  function sameRow(nodes) {
    const tops = nodes.map((n) => n.offsetTop);
    return tops.every((t) => near(t, tops[0], 1));
  }
  // Every element starts a new row (fully stacked).
  function distinctRows(nodes) {
    const tops = nodes.map((n) => n.offsetTop).sort((a, b) => a - b);
    for (let i = 1; i < tops.length; i++) {
      if (near(tops[i], tops[i - 1], 1)) return false;
    }
    return true;
  }

  // --- registration + run ----------------------------------------------------
  function test(name, fn) {
    cases.push({ name, fn });
  }

  function runAll() {
    for (const c of cases) {
      try {
        c.fn();
      } catch (e) {
        assert(c.name + " (threw)", false, String((e && e.stack) || e));
      }
    }
    render();
  }

  function render() {
    const fail = results.filter((r) => !r.pass);
    const out = document.createElement("pre");
    out.id = "results";
    const lines = [`RESULT: PASS=${results.length - fail.length} FAIL=${fail.length}`];
    for (const r of results) {
      lines.push(`${r.pass ? "ok  " : "FAIL"}: ${r.name}${r.pass ? "" : " — " + r.detail}`);
    }
    out.textContent = lines.join("\n");
    document.body.appendChild(out);
  }

  window.addEventListener("load", runAll);

  return { test, assert, assertNear, assertEq, near, el, kids, rem, style, px, rect, colCount, sameRow, distinctRows };
})();
