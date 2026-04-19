+++
title = "You're wrong about `Array.from` vs `[...arr]`"
date = 2026-04-19
description = 'Decrying the Gospel of pseudo-punctilious optimisation in software'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'javascript', 'es6', 'quibblery']
extra.cited_tools = ['eslint', 'hyperfine', 'node']
+++

> [!IMPORTANT]
>
> Buckle up, this one's actually quite the rant, followed by some quite dense
> and less didactic than it the custom on this blog.  Basically yelling at
> clouds, although these are cries of desolation laced with somewhat studied
> insight.

Today, in upgrading tooling dependencies, I pulled in yet another atrocious,
well-intended yet simply damaging addition to the presumed-savvy developer's
tool belt. `@e18e/eslint-plugin`[^e18e-eslint]—`e18e` who?  I hear
you—introduced their abominable `prefer-array-from-map` rule:

[^e18e-eslint]:  That repository is the _"official"_ `e18e`
[ESLint](https://eslint.org/) plug-in for _"code modernization and performance
best practices"_; the `e18e` itself is a very recent initiative whose goal is
that of _"Ecosystem Performance"_: that is what their name stands for.

> Prefer `Array.from(iterable, mapper)` over `[...iterable].map(mapper)` to
> avoid intermediate array allocation.
>
> {% attribution() %} Ecosystem Performance (`e18e`), `prefer-array-from-map` {% end %}

**It's aggravatingly misguided at best.**  And for a newly founded, well-funded
initiative that calls itself _"official"_, is empowered by fairly popular
individuals in the Web development community, and receives the financial backing
of some sizeable institutions **before having even proven its worth**; we may be
looking down the barrel of yet another piece of forever-unavoidable mixed bag of
possibly sweet nuts coated in agonising tar: just what the doctor ordered.

## A long-standing [pet peeve](https://en.wikipedia.org/wiki/Pet_peeve) of mine

I brushed up against that topic before, and my findings then were ravishing
enough that nearly a decade later, through some routine maintenance procedure, I
did a little [double-take](https://en.wikipedia.org/wiki/Double-take_(comedy))
that sowed the seed of doubt in spite of even the standing of the authors of
that already lauded `e18e` enterprise.

At 4 in the morning, I turn in my sleep: the doubt has morphed into anguish, and
the only way to quell it would be for it to be wrong, and for me to have proven
as much.  Unfortunately, as you'll soon find out, I shall have no respite, for
the just-nascent yet already-engulfing scepticism was on point...  Again.

Just a whiff of validation from my past self, and we're off to the
races: I wrote about a very similar problem _(ages ago, in 2018!)_ on
[StackOverflow](https://stackoverflow.com/a/52820058/2427596).  Its `TL;DR`
would likely be:

> Contrary to what you'd think and read pretty much everywhere,
> **`[].slice.call(...)` does NOT instantiate a new, empty `Array` just to
> access its `slice` property!**.
>
>    Nowadays (it has been so **for 5+ years**—as of late 2018), the [`JIT`
> compilation](https://hacks.mozilla.org/2017/02/a-crash-course-in-just-in-time-jit-compilers/) is included everywhere you run JavaScript (unless you're still
> browsing the Web with `IE8` or lower).<br>
>
> This mechanism allows the JavaScript engine to resolve `[].slice` directly,
> and statically, as direct `Array.prototype` reference in one shot, and just
> one configurable property access: `forEach`.
>
>    [On the other hand, `Array.prototoype.slice` results in] a lookup for the
> whole scope for an `Array` reference until all scopes are walked 'till the
> global one... Because you can name a variable `Array` any time you want.<br>
>    Once the global scope is reached, and the native found, the engine accesses
> its proottype [sic] and after that its method:
>
> `O(N)` scope resolution + 2 properties access (`.prototype` and `.forEach`).
>
> {% attribution() %} A younger me, and [Andrea Giammarchi](https://twitter.com/WebReflection), [`[].slice` vs `Array.prototoype.slice`](https://stackoverflow.com/a/52820058/2427596) {% end %}

Fascinating!  There are indeed many layers between the high-level abstraction
that you juggle through the semantics of your programming language, and
the resulting operations executed by your processor.  This here, the <abbr
title="Just-In-Time">`JIT`</abbr>[^jit-compiler-crash-course] compilation, is
but _one_ of these, and already it subverts all sorts of expectations.

[^jit-compiler-crash-course]: You may want to go over this short introduction of
what the Just-In-Time compilation is about, from this ["crash course" on Mozilla
Hacks](https://hacks.mozilla.org/2017/02/a-crash-course-in-just-in-time-jit-compilers/).

I would go so far as to claim that generally, short of altering your high-level
algorithm or data structure substantially, **performance optimisation is a
tricky beast**—assuming you are vaguely capable of understanding what goes
into implementing a reasonable benchmark in the first place.  Amusingly enough,
it's yet another case where the more clueless you are, the easier a time you'll
have with the topic.

The eminent [Donald Knuth](https://en.wikipedia.org/wiki/Donald_Knuth) would
go even further, in judging **premature optimisation to be the _"root of all
evil"_**[^premature-optimisation-knuth], especially when practised by what those
he calls _"pennywise-and-pound-foolish programmers"_.

[^premature-optimisation-knuth]:  Donald Knuth's distinguished publication is
most ubiquitously reduced to an aphorism that I feel is best shared here in its
context, and with its mitigating follow-up:
    > There is no doubt that the grail of efficiency leads to abuse.
    > Programmers waste enormous amounts of time thinking about, or worrying
    > about, the speed of non-critical parts of their programs, and these
    > attempts at efficiency actually have a strong negative impact when
    > debugging and maintenance are considered.  We should forget about small
    > efficiencies, say about 97% of the time: **premature optimization is the
    > root of all evil**.
    >
    > Yet we should not pass up our opportunities in that critical 3 %. A good
    > programmer will not be lulled into complacency by such reasoning, he will
    > be wise to look carefully at the critical code; but only after that code
    > has been identified.  It is often a mistake to make _a priori_ judgements
    > about what parts of a program are really critical, since the universal
    > experience of programmers who have been using measurement tools has been
    > that their intuitive guesses fail.
    >
    > {% attribution() %} Donald Knuth, [Structured Programming with `goto` Statements](https://pic.plover.com/knuth-GOTO.pdf) {% end %}

## `Array.from(arr, fn)` vs `[...arr].map(fn)`

Back to the topic at hand: let's **actually** figure out whether ordaining
`Array.from(arr, fn)` is helping out with regards to performance.

Before we go forward, a note on my methodology: the benchmarks will run on my
personal computer, which will be somewhat otherwise busy, and will be using _the
latest consumer release_ of **the engine by far the most prominent, Google's
`V8`[^most-prominent-engine]**; that is:

[^most-prominent-engine]: `V8` is by far the most prominent of the many
JavaScript environments, which count:

    - the Web Browsers, of which there are quite a few: _Firefox_, _Safari_,
      _Chrome_, _Edge_, _et cet_...
    - those for server-side computation, like _Node.js_, _Deno_ and _Bun_,
    - A myriad others for another myriad of applications, such as for the
      `GNOME` ecosystem, for the <abbr title="Internet of Things">`IoT`</abbr>
      or even smart devices, such as _Amazon Echo_.

    In the end, most of these end up relying on one of three major JavaScript
    engines (though _QuickJS_ and _Hermes_ may be worth a mention in the
    `IoT`/embedded/mobile device space):

    - _SpiderMonkey_ serves _Firefox_ and _GNOME JavaScript_,
    - _JavaScriptCore_ serves _Safari_ and other _iOS_ browsers, as well as
      _Bun_,
    - `V8` serves _Node.js_ and all Chromium derivatives (_Brave_, _Edge_, _et
      cet_)

    Of those, Google's `V8` is indisputably the most ubiquitous,
    by an enormous margin: [some ~75% of all Web browsers run
    it](https://gs.statcounter.com/browser-market-share), and that's
    not even the segment it fares best at: the "server-side" JavaScript
    is largely more dominated by _Node.js_ today: **over 90% of the
    11,141 respondents** to the [latest edition of the State of JS
    survey](https://2025.stateofjs.com/en-US/other-tools/) declared using that
    runtime.

- _Node.js_[^node-dot-js] version `25.9.0`, released 4 days ago, which bundles:
- `V8` engine version `14.1.146.11-node.25`.

[^node-dot-js]: Yep, [capitalised `Node`, dot,
`js`](@/ramblings/aptly-capitalised-names.md); that's how it's spelled.

My 16 `CPU` cores shall be mostly idle, and well over `16 GB` of `RAM` will be
made available.

> [!TIP]
>
> When some JavaScript is executed using _Node.js_, it actually runs against
> [Google's `V8` JavaScript engine](https://v8.dev/): that is the interpreter
> upon which _Node.js_ builds by adding numerous things, such as `HTTP`
> libraries, file system libraries, `OS` libraries (`process`, environment
> variables...), integration with the `npm` ecosystem, _et cet_.
>
> In the end, **in the case of _Node.js_ as well as all Chromium-derivative Web
> browsers**, it's `V8` that you'll find under the hood.  In serious JavaScript
> performance profiling matters, the distinction needs to be made.

### Memory consumption

Let's start with what may possibly have been meant, or be the most obvious
implication of avoiding _"intermediate array allocation"_, as I remind you that
such is the rhetoric for this fresh new rule to help you build better software:

> Prefer `Array.from(iterable, mapper)` over `[...iterable].map(mapper)` to
> avoid intermediate array allocation.
>
> {% attribution() %} Ecosystem Performance (`e18e`), `prefer-array-from-map` {% end %}

Just how much heap is either option consuming?  Trivially answered: start `node`
with the <abbr title="Garbage Collection">`--expose-gc`</abbr> flag, and its
inner workings are made available.  Let's create a simple script monitoring the
`heapUsed`:

```javascript,name=mem.js
const [size = 100_000, iterations = 10] = process.argv.slice(1).map(Number)
const arr = Array.from({ length: size }, (_, i) => i)
function touch(arr) { return arr.length + (arr[0] ?? 0) + (arr[arr.length - 1] ?? 0) }
function measure(name, fn) {
    const before = (global.gc(), process.memoryUsage().heapUsed)
    let sum = 0; for (let i = 0; i < iterations; i++) sum += touch(fn())
    const after =  (global.gc(), process.memoryUsage().heapUsed)
    console.log(name.padEnd(21) + `extra heap: ${((after - before)/ 2 ** 20).toFixed(2).padStart(5)} MB`.padStart(21))
}
```
{{ note(msg="always `touch` the result to prevent optimising away the entire computation") }}

Here's how you use it:

```sh
base=$(cat mem.js)
while IFS= read -r script; do
	node --expose-gc -e "$base; $script" -- 100000 10
done <<-'EOF'
	measure('for (...)',           () => { const r = new Array(arr.length); for (let i = 0; i < arr.length; i++) r[i] = arr[i] + 1; return r })
	measure('arr.map(fn)',         () => arr.map(x => x + 1))
	measure('[...arr].map(fn)',    () => [...arr].map(x => x + 1))
	measure('Array.from(arr, fn)', () => Array.from(arr, x => x + 1))
EOF
```
{{ note(msg="no time to explain—if you don't get it, you should consider hanging out in this blog some more") }}

Each test will run in its own _Node.js_ process so as to avoid having any
sort of unfair benefit from any engine optimisation, which **did occasionally
happen** in some earlier iteration.

Starting with a modest 10 iterations over `100,000`-item-long arrays:

<div class="grid-1-2">
<div>

```txt
iterations: 10               size: 100,000
------------------------------------------
for (...)             extra heap:  0.77 MB
arr.map(fn)           extra heap:  0.76 MB
[...arr].map(fn)      extra heap:  0.76 MB
Array.from(arr, fn)   extra heap:  0.97 MB
```
{{ note(msg="this baseline already seems quite revealing...") }}
</div>
<div>

```txt
iterations: 10               size: 100,000
------------------------------------------
Array.from(arr, fn)   extra heap:  0.97 MB
[...arr].map(fn)      extra heap:  0.76 MB
arr.map(fn)           extra heap:  0.76 MB
for (...)             extra heap:  0.77 MB
```
{{ note(msg="the order matters not") }}
</div>
</div>

Let's explore with larger arrays of `1,000,000` elements:

<div class="grid-1-2">
<div>

```txt
iterations: 1              size: 1,000,000
------------------------------------------
for (...)             extra heap:  7.63 MB
arr.map(fn)           extra heap:  7.63 MB
[...arr].map(fn)      extra heap:  7.63 MB
Array.from(arr, fn)   extra heap: 11.09 MB
```
{{ note(msg="the number of iterations matters (almost) not") }}
</div>
<div>

```txt
iterations: 100            size: 1,000,000
------------------------------------------
for (...)             extra heap:  7.64 MB
arr.map(fn)           extra heap:  7.64 MB
[...arr].map(fn)      extra heap:  7.64 MB
Array.from(arr, fn)   extra heap: 10.22 MB
```
{{ note(msg="notice a curious bump **down** for `Array#from`") }}
</div>
</div>

And even larger, `10,000,000` elements:

<div class="grid-1-2">
<div>

```txt
iterations: 1             size: 10,000,000
------------------------------------------
for (...)             extra heap: 76.30 MB
arr.map(fn)           extra heap: 76.29 MB
[...arr].map(fn)      extra heap: 76.29 MB
Array.from(arr, fn)   extra heap: 84.27 MB
```
{{ note(msg="absolutely no surprise there") }}
</div>
<div>

```txt
iterations: 10            size: 10,000,000
------------------------------------------
for (...)             extra heap: 76.30 MB
arr.map(fn)           extra heap: 76.30 MB
[...arr].map(fn)      extra heap: 76.30 MB
Array.from(arr, fn)   extra heap: 84.27 MB
```
{{ note(msg="nor any here either") }}
</div>
</div>

And crank the iterations yet higher:

<div class="grid-1-2">
<div>

```txt
iterations: 100           size: 10,000,000
------------------------------------------
for (...)             extra heap: 75.42 MB
arr.map(fn)           extra heap: 75.42 MB
[...arr].map(fn)      extra heap: 75.42 MB
Array.from(arr, fn)   extra heap: 83.38 MB
```
{{ note(msg="another marginal yet curious decrease ") }}
</div>
<div>

```txt
iterations: 1000          size: 10,000,000
------------------------------------------
for (...)             extra heap: 75.42 MB
arr.map(fn)           extra heap: 75.42 MB
[...arr].map(fn)      extra heap: 75.42 MB
Array.from(arr, fn)   extra heap: 83.39 MB
```
{{ note(msg="this one ran for **7m 57s**") }}
</div>
</div>

Throughout the entire test suite, the results were actually **extremely
consistent**.  That is, _the results were entirely reproducible with the exact
same values every time_; the bump from `7.63 MB` to `7.64 MB` across three
methods when going from 1 to 100 iterations is **not accidental**, neither is
the bump **down some ~7.8%** (from `11.09` to `10.22 MB`) for the `Array#from`:
both _"would-be oddities"_ could be reproduced again and again, always the same.
These numbers are **exact and absolutely not subject to flakiness**, not in the
current set-up.

> [!NOTE]
>
> I attribute the bump **down** at 100 iterations and above to the higher
> pressure put on the garbage collector by the accumulating data beyond a
> certain threshold.  Then, then engine's heuristics change _"just-in-time"_ and
> it starts more aggressively pruning the heap as a result.

In any case, what transpires: `Array.from(arr, fn)` generally
is in the order of **~30% more demanding on the heap usage**,
tapering down to being a mere \~10% worse at its best, with some
occasional \~45% worse heap consumption in the reverse-[Goldilocks
zone](https://en.wikipedia.org/wiki/Goldilocks_and_the_Three_Bears).  It is
systematically worse than all counterparts; all others of which, always, perform
essentially identically.

### Speed performance

This one always fluctuates somewhat.  I'll be using
[`hyperfine`](https://github.com/sharkdp/hyperfine) to help me run some simple
benchmarks and tally up some basic analysis.

```javascript,name=spd.js
const [size = 100_000, iterations = 10] = process.argv.slice(1).map(Number)
const arr = Array.from({ length: size }, (_, i) => i)
function touch(arr) { return arr.length + (arr[0] ?? 0) + (arr[arr.length - 1] ?? 0) }
function measure(fn) {
    let sum = 0; for (let i = 0; i < iterations; i++) sum += touch(fn())
}
```
{{ note(msg="the same as `mem.js`, only stripped from the explicit garbage collection triggers and logging") }}

Let's run **the very same code**, take 20 sample each time and just let the
system warm up before hand with 5 trial runs prior to the proper ones:

```sh,name=spd.sh
base=$(cat spd.js)
hyperfine      \
    --warmup 5 \
    --runs  20 \
    --style=color \
    --command-name='for (...)'           \
    --command-name='arr.map(fn)'         \
    --command-name='[...arr].map(fn)'    \
    --command-name='Array.from(arr, fn)' \
    "node -e '$base; measure(() => { const r = new Array(arr.length); for (let i = 0; i < arr.length; i++) r[i] = arr[i] + 1; return r })' -- $*" \
    "node -e '$base; measure(() => arr.map(x => x + 1))'         -- $*" \
    "node -e '$base; measure(() => [...arr].map(x => x + 1))'    -- $*" \
    "node -e '$base; measure(() => Array.from(arr, x => x + 1))' -- $*"
```
{{ note(msg="this time I'll use an extra layer of scripting goodness for ease of use") }}

Let's get started!  How about `100` iterations over arrays with `10,000` items?

```sh
sh spd.sh 10000 100
```
<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">Benchmark 1</span>: for (...)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 25.8 ms</span> ± <span class="term-fg32">  1.8 ms</span>    [User: <span class="term-fg34">21.4 ms</span>, System: <span class="term-fg34">6.7 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 22.8 ms</span> … <span class="term-fg35"> 29.4 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 2</span>: arr.map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 30.7 ms</span> ± <span class="term-fg32">  1.7 ms</span>    [User: <span class="term-fg34">25.3 ms</span>, System: <span class="term-fg34">6.7 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 27.6 ms</span> … <span class="term-fg35"> 34.2 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 3</span>: [...arr].map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 32.9 ms</span> ± <span class="term-fg32">  2.3 ms</span>    [User: <span class="term-fg34">26.6 ms</span>, System: <span class="term-fg34">7.4 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 30.5 ms</span> … <span class="term-fg35"> 38.2 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 4</span>: Array.from(arr, fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 46.2 ms</span> ± <span class="term-fg32">  2.2 ms</span>    [User: <span class="term-fg34">37.2 ms</span>, System: <span class="term-fg34">10.2 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 43.6 ms</span> … <span class="term-fg35"> 51.7 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Summary</span>
  <span class="term-fg36">for (...)</span> ran
<span class="term-fg32 term-fg1">    1.19</span> ± <span class="term-fg32">0.11</span> times faster than <span class="term-fg35">arr.map(fn)</span>
<span class="term-fg32 term-fg1">    1.28</span> ± <span class="term-fg32">0.13</span> times faster than <span class="term-fg35">[...arr].map(fn)</span>
<span class="term-fg32 term-fg1">    1.79</span> ± <span class="term-fg32">0.15</span> times faster than <span class="term-fg35">Array.from(arr, fn)</span></code></pre>
{{ note(msg="oh yeah, `hyperfine`'s got some fancy output and I'm getting better at honouring these") }}

Note that we we already have a bit of variance.  These aren't all quite
identical under the hood...  Let's keep going.

> [!TIP]
>
> So as to not bore you to death, I'll use collapsible elements ([without
> JavaScript, by the way](@/colophon.md)): click (or `<Tab>`-navigate and
> `<Space>`/`<Enter>`, this Web site is keyboard-friendly) on their summaries to
> access their details.

`100,000` items, `100` iterations:

<details class="code">
<summary>

```sh
sh spd.sh 100000 100
```
<pre class="giallo z-code">
<code data-lang="plain"><span class="term-fg1">Summary</span>
  <span class="term-fg36">for (...)</span> ran
<span class="term-fg32 term-fg1">    2.19</span> ± <span class="term-fg32">0.18</span> times faster than <span class="term-fg35">arr.map(fn)</span>
<span class="term-fg32 term-fg1">    2.61</span> ± <span class="term-fg32">0.24</span> times faster than <span class="term-fg35">[...arr].map(fn)</span>
<span class="term-fg32 term-fg1">    5.41</span> ± <span class="term-fg32">0.36</span> times faster than <span class="term-fg35">Array.from(arr, fn)</span></code></pre>
</summary>
<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">Benchmark 1</span>: for (...)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 69.8 ms</span> ± <span class="term-fg32">  3.1 ms</span>    [User: <span class="term-fg34">46.0 ms</span>, System: <span class="term-fg34">29.6 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 66.0 ms</span> … <span class="term-fg35"> 77.6 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 2</span>: arr.map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">152.9 ms</span> ± <span class="term-fg32"> 10.4 ms</span>    [User: <span class="term-fg34">127.1 ms</span>, System: <span class="term-fg34">29.9 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">140.4 ms</span> … <span class="term-fg35">174.0 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 3</span>: [...arr].map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">181.9 ms</span> ± <span class="term-fg32"> 14.5 ms</span>    [User: <span class="term-fg34">130.0 ms</span>, System: <span class="term-fg34">56.4 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">167.0 ms</span> … <span class="term-fg35">216.4 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 4</span>: Array.from(arr, fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">377.3 ms</span> ± <span class="term-fg32"> 18.4 ms</span>    [User: <span class="term-fg34">265.5 ms</span>, System: <span class="term-fg34">117.8 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">342.2 ms</span> … <span class="term-fg35">412.7 ms</span>    <span class="term-fg2">20 runs</span>
</code></pre>
</details>
{{ note(msg="") }}

`10,000` items, `1,000` iterations:

<details class="code">
<summary>

```sh
sh spd.sh 10000 1000
```
<pre class="giallo z-code">
<code data-lang="plain"><span class="term-fg1">Summary</span>
  <span class="term-fg36">for (...)</span> ran
<span class="term-fg32 term-fg1">    2.71</span> ± <span class="term-fg32">0.26</span> times faster than <span class="term-fg35">arr.map(fn)</span>
<span class="term-fg32 term-fg1">    2.90</span> ± <span class="term-fg32">0.28</span> times faster than <span class="term-fg35">[...arr].map(fn)</span>
<span class="term-fg32 term-fg1">    6.12</span> ± <span class="term-fg32">0.64</span> times faster than <span class="term-fg35">Array.from(arr, fn)</span></code></pre>
</summary>
<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">Benchmark 1</span>: for (...)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 42.4 ms</span> ± <span class="term-fg32">  3.6 ms</span>    [User: <span class="term-fg34">35.2 ms</span>, System: <span class="term-fg34">11.8 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 38.5 ms</span> … <span class="term-fg35"> 52.7 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 2</span>: arr.map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">114.7 ms</span> ± <span class="term-fg32">  5.7 ms</span>    [User: <span class="term-fg34">106.1 ms</span>, System: <span class="term-fg34">12.0 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">105.6 ms</span> … <span class="term-fg35">127.0 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 3</span>: [...arr].map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">122.9 ms</span> ± <span class="term-fg32">  5.8 ms</span>    [User: <span class="term-fg34">111.3 ms</span>, System: <span class="term-fg34">14.2 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">115.1 ms</span> … <span class="term-fg35">132.3 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 4</span>: Array.from(arr, fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">259.3 ms</span> ± <span class="term-fg32"> 15.8 ms</span>    [User: <span class="term-fg34">246.0 ms</span>, System: <span class="term-fg34">15.1 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">227.0 ms</span> … <span class="term-fg35">283.6 ms</span>    <span class="term-fg2">20 runs</span>
</code></pre>
</details>
{{ note(msg="") }}

`100,000` items, `1,000` iterations:

<details class="code">
<summary>

```sh
sh spd.sh 100000 1000
```
<pre class="giallo z-code">
<code data-lang="plain"><span class="term-fg1">Summary</span>
  <span class="term-fg36">for (...)</span> ran
<span class="term-fg32 term-fg1">    2.97</span> ± <span class="term-fg32">0.14</span> times faster than <span class="term-fg35">arr.map(fn)</span>
<span class="term-fg32 term-fg1">    3.72</span> ± <span class="term-fg32">0.20</span> times faster than <span class="term-fg35">[...arr].map(fn)</span>
<span class="term-fg32 term-fg1">    8.05</span> ± <span class="term-fg32">0.32</span> times faster than <span class="term-fg35">Array.from(arr, fn)</span></code></pre>
</summary>
<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">Benchmark 1</span>: for (...)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1">406.1 ms</span> ± <span class="term-fg32">  6.1 ms</span>    [User: <span class="term-fg34">173.8 ms</span>, System: <span class="term-fg34">241.2 ms</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36">397.0 ms</span> … <span class="term-fg35">419.2 ms</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 2</span>: arr.map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 1.204 s</span> ± <span class="term-fg32"> 0.056 s</span>    [User: <span class="term-fg34">0.968 s</span>, System: <span class="term-fg34">0.230 s</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 1.117 s</span> … <span class="term-fg35"> 1.283 s</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 3</span>: [...arr].map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 1.512 s</span> ± <span class="term-fg32"> 0.078 s</span>    [User: <span class="term-fg34">1.002 s</span>, System: <span class="term-fg34">0.505 s</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 1.415 s</span> … <span class="term-fg35"> 1.740 s</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 4</span>: Array.from(arr, fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 3.269 s</span> ± <span class="term-fg32"> 0.121 s</span>    [User: <span class="term-fg34">2.243 s</span>, System: <span class="term-fg34">1.000 s</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 3.097 s</span> … <span class="term-fg35"> 3.478 s</span>    <span class="term-fg2">20 runs</span>
</code></pre>
</details>
{{ note(msg="") }}

So, there you have it.

Under the most recent iteration of the most ubiquitous JavaScript engine,
`Array.from(arr, mapper)` is **always**, **significantly**, **SLOWER** than
`[...arr].map(mapper)`.

## Technical and broader takeaways

I compared **three versions of creating a new array that maps each element
through some transformer**.  One of them even goes so far as to perform a
(sometimes redundant) shallow copy of the original array before performing the
mapping: this is the object of that _well-intended-yet-obscenely-misguided
**"performance optimisation"** rule_ of the recently founded `e18e` organisation
presuming to further and/or democratise the **performance of JavaScript
packages**:

> Prefer `Array.from(iterable, mapper)` over `[...iterable].map(mapper)` to
> avoid intermediate array allocation.
>
> {% attribution() %} Ecosystem Performance (`e18e`), `prefer-array-from-map` {% end %}

The **memory consumption** is **strictly** and **always** worse (`~10` to `~45%`
worse)when using `Array.from(arr, mapper)` than with every single other method,
all of which are otherwise essentially identical.

However, that isn't the most interesting metric for us here, and the deviation
isn't all that significant, next to, say, the size of the items themselves.

The more interesting point would likely be that of its _"speed"_: how much
faster would either method go?

**Across the board, `Array.from(arr, fn)` is, systematically and enormously
slower.**

### The two operations in question

First, comparing to `[...arr].map(fn)` in isolation:

```txt
                       A - B           A - B
                   =============   =============
  100 iterations   32.9  -  46.2   181.9 - 377.3
1,000 iterations   122.9 - 259.3   1512  -  3269
                   -------------   -------------
                   10,000  items   100,000 items
```
{{ note(msg="the durations are in milliseconds, **`A` is `[...arr].map(fn)`, and `B` is `Array.from(arr, fn)`**") }}

1. **fewer** items, **fewer** iterations:

    **`Array.from(arr, fn)` is 49.42% slower than `[...arr].map(fn)`**

2. **more** items, **fewer** iterations:

    **`Array.from(arr, fn)` is 107.42% slower than `[...arr].map(fn)`**

3. **fewer** items, **more** iterations:

    **`Array.from(arr, fn)` is 110.98% slower than `[...arr].map(fn)`**

4. **more** items, **more** iterations:

    **`Array.from(arr, fn)` is 116.20% slower than `[...arr].map(fn)`**

> [!IMPORTANT]
>
> `Array.from(arr, fn)` appears to somewhat stabilise at taking **over twice
> as long** to perform the task!  The difference grows as we go further across
> either dimension.
>
> There is **no** performance reason to preferring `Array.from(arr, fn)` over
> `[...arr].map(fn)`: the **opposite** is unequivocally accurate.

### Isolating `[...arr]` vs mere `arr`

Secondly, comparing the cost of the _"intermediate array allocation"_:

```txt
                       A - C           A - C
                   =============   =============
  100 iterations   32.9  -  30.7   181.9 - 152.9
1,000 iterations   122.9 - 114.7   1512  -  1204
                   -------------   -------------
                   10,000  items   100,000 items
```
{{ note(msg="the durations are in milliseconds, **`A` remains `[...arr].map(fn)`, and `C` is `arr.map(fn)`**") }}

> [!IMPORTANT]
>
> We observe an increase in cost ranging from `~7.1%` to `~25.6%` when
> introducing `[...arr]` instead of merely using `arr`.  The difference grows as
> we go further across either dimension.  It's not insignificant, but much less
> so than using `Array.from(arr, fn)` is.

### And `for`-loop trumps all others

Really, here's the takeaway, for those that really require some specific array
mapping transformation to go fast and often:

Use a `for`-loop: it's systematically significantly faster.  In the most
stressing case, using `100,000` items and `1,000` iterations, for `for`-loop
performed about:

- `2.97` times faster than `arra.map(fn)`,
- `3.72` times faster than `[...arr].map(fn)`, and
- `8.05` times faster than `Array.from(arr, fn)`.

So, the next time your linter screams at you at the `ERROR` level that this is
somehow inadequate:

```js
const boxes = [...document.querySelectorAll('[grid-area=headline]')]
    .map(e => e.getBoundingClientRect())
```
{{ note(msg="this excerpt triggers the revolting `e18e/prefer-array-from-map` rule") }}

### Is that really what you need?

**Know that it is rubbish.**  Know that <abbr title="Just-In-Time">`JIT`</abbr>
compilation is tricky, and so is measuring performance.

But mostly: know that **it matters not here**.  Know that more time elapses from
from `hover` to `click` on your buttons (provided a mammalian brain is operating
the cursor), than it takes modern hardware to mess around with your bits of
data.

And that's before [Fitt's law](https://en.wikipedia.org/wiki/Fitts%27s_law)
comes into play.  And that's before [Hick's
law](https://en.wikipedia.org/wiki/Hick%27s_law) also kicks off.

And that's all **assuming you DO have more than your usual pitiful 4 items** in a
list!

## Going forward

**Make ample use of discernment**, don't presume that the cool new kids
online know any better, keep track of what actually matters and be capable of
extracting a ballpark estimation yourself.

But most importantly: **don't make me change my perfectly serviceable code**
because of some second-hand Gospel from the _pennywise-and-pound-foolish_
missionaries you've assumed is the end-all-be-all of performance improvement.

There is hardly any room for improvement, until you've measured that there is a
need for it; and when the time will come, be certain that some one-stop-shop,
low-hanging _"panacea"_ may be **more of a red herring than a [white
whale](https://en.wikipedia.org/wiki/Captain_Ahab)**[^red-herring].

[^red-herring]: _"More of a red herring than a white whale"_... Ah, I'm really
quite proud of that one!

This right here is almost **splitting hairs** compared to the vastness and
complexity of the topic of performance optimisation, but I'll acknowledge that
in some instance, maybe making _"it"_ faster at _that_ level as well isn't a bad
idea.  In this case, **measure** the options with your **real data and usage
patterns**, or perhaps revert to writing code that your compiler best translates
into the ideal instructions for your `CPU`: in this case, just spell out the
whole `for`-loop yields unmistakably better output.

Until then, good luck out there, have fun!
