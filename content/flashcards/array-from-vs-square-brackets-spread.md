+++
title = 'Beware false prophets: `[...arr]` is not harmful'
date = 2026-04-19
description = 'Decrying the Gospel of pseudo-punctilious optimisation in software'
taxonomies.section = ['flashcards']
taxonomies.tags = ['all', 'javascript', 'es6', 'quibblery']
extra.cited_tools = ['eslint', 'node']
+++

> [!NOTE]
>
> This is essentially a quick `TL;DR` of [You're wrong about `Array.from` vs
> `[...arr]`](@/flight-manual/array-from-vs-square-brackets-spread.md), a more
> comprehensible and far less digestible piece that goes in depth over the
> pitfalls of blanket, low-hanging _"performance fruits"_.

Most recently, a new [linting](https://en.wikipedia.org/wiki/Lint_(software))
rule has been adopted by popular JavaScript and TypeScript set-up:  I have
the great displeasure of introducing you to `e18e`[^e18e]'s abominable
`prefer-array-from-map` rule:

[^e18e]: the `e18e` itself is a very recent initiative whose goal is that of
_"Ecosystem Performance"_: that is what their name stands for.  They started
offering a collection of _"official"_ JavaScript [ESLint](https://eslint.org/)
plug-in for _"code modernization and performance best practices"_ linting rules
at `@e18e/eslint-plugin`.

> Prefer `Array.from(iterable, mapper)` over `[...iterable].map(mapper)` to
> avoid intermediate array allocation.
>
> {% attribution() %} Ecosystem Performance (`e18e`), `prefer-array-from-map` {% end %}

  As soon as that machinery spat out prescriptivist nonsense regarding my
beautiful tapestry of practical software, I remembered that one curious
adventure I'd been on nearly a decade ago, touching on some considerations
regarding what was at the time quite the usual pattern:<br>
  How preferable is `Array.prototype.slice.call(x)` to `[].slice.call(x)`?

As I go over in [this answer on
StackOverflow](https://stackoverflow.com/a/52820058/2427596), the factual,
learned, insightful answer is: **not one bit**—if anything, `[].slice` is
preferable in all sorts of ways, and primarily that of _"performance"_, despite
the contrary having been decried by its clueless detractors.

## The gist of `JIT`

An eminent tool in the great variety of mechanism that you brutalise whenever
you shovel your pointless React or Python monstrosities is **the <abbr
title="Just-In-Time">`JIT`</abbr> compilation**.

The `JIT` is a runtime optimisation strategy, whereby code is initially
interpreted or compiled to an intermediate form, then **selectively compiled
into native machine code during execution**, based on **actual usage patterns**.
In short, "hot" code paths—those executed frequently—are identified via
profiling, aggressively optimised in various ways (generally, for instance,
stripping away the edge-case handling bits), and **cached as native code**,
allowing subsequent executions to run at near-compiled speed while still
retaining the flexibility of dynamic languages and runtime adaptability.

You may want to go over this short introduction of what the _Just-In-Time_
compilation is about, from this [_"crash course"_ on Mozilla
Hacks](https://hacks.mozilla.org/2017/02/a-crash-course-in-just-in-time-jit-compilers/).

I would go so far as to claim that generally, short of altering your high-level
algorithm or data structure substantially, **performance optimisation is a
tricky beast**.  [Donald Knuth](https://en.wikipedia.org/wiki/Donald_Knuth)
would go even further, in judging **premature optimisation to be the
_"root of all evil"_**, especially when practised by what those he calls
_"pennywise-and-pound-foolish programmers"_.

## `Array.from(arr, fn)` vs `[...arr].map(fn)`

Back to the topic at hand: let's **actually** figure out whether ordaining
`Array.from(arr, fn)` is helping out with regards to performance.

In terms of memory consumption, a somewhat rigorous test
(the details of which are outlined only in [the complete
article](@/flight-manual/array-from-vs-square-brackets-spread.md)) yields the
following results:

<div class="grid-1-2">
<div>

```txt
iterations: 1             size: 10,000,000
------------------------------------------
[...arr].map(fn)      extra heap: 76.29 MB
Array.from(arr, fn)   extra heap: 84.27 MB
```
</div>
<div>

```txt
iterations: 10            size: 10,000,000
------------------------------------------
[...arr].map(fn)      extra heap: 76.30 MB
Array.from(arr, fn)   extra heap: 84.27 MB
```
</div>
</div>

<div class="grid-1-2">
<div>

```txt
iterations: 100           size: 10,000,000
------------------------------------------
[...arr].map(fn)      extra heap: 75.42 MB
Array.from(arr, fn)   extra heap: 83.38 MB
```
</div>
<div>

```txt
iterations: 1000          size: 10,000,000
------------------------------------------
[...arr].map(fn)      extra heap: 75.42 MB
Array.from(arr, fn)   extra heap: 83.39 MB
```
</div>
</div>

It transpires that `Array.from(arr, fn)` is generally in the order
of `~10%` worse overhead in terms of memory for immense arrays.
It is systematically worse than its counterpart in question, as
well as all others that I didn't mention here but [did consider
there](@/flight-manual/array-from-vs-square-brackets-spread.md).

But the more interesting point would likely be that of its _"speed"_: how much
faster would either method go?

<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">Benchmark 1</span>: [...arr].map(fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 1.538 s</span> ± <span class="term-fg32"> 0.099 s</span>    [User: <span class="term-fg34">1.015 s</span>, System: <span class="term-fg34">0.517 s</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 1.404 s</span> … <span class="term-fg35"> 1.754 s</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Benchmark 2</span>: Array.from(arr, fn)
  Time (<span class="term-fg32 term-fg1">mean</span> ± <span class="term-fg32">σ</span>):     <span class="term-fg32 term-fg1"> 3.351 s</span> ± <span class="term-fg32"> 0.148 s</span>    [User: <span class="term-fg34">2.281 s</span>, System: <span class="term-fg34">1.027 s</span>]
  Range (<span class="term-fg36">min</span> … <span class="term-fg35">max</span>):   <span class="term-fg36"> 3.122 s</span> … <span class="term-fg35"> 3.617 s</span>    <span class="term-fg2">20 runs</span>
&nbsp;
<span class="term-fg1">Summary</span>
  <span class="term-fg36">[...arr].map(fn)</span> ran
<span class="term-fg32 term-fg1">    2.18</span> ± <span class="term-fg32">0.17</span> times faster than <span class="term-fg35">Array.from(arr, fn)</span></code></pre>

Under the most recent iteration of the most ubiquitous JavaScript engine[^v8],
`Array.from(arr, mapper)` is **always**, **significantly**, **SLOWER** than
`[...arr].map(mapper)`.  Are we then to rewrite everything?

[^v8]: The most ubiquitous JavaScript engine, by very far, is
[`V8`](https://v8.dev/).

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

## [Missing the forest for the trees](https://dictionary.cambridge.org/dictionary/english/not-see-the-forest-for-the-trees)

We're splitting hairs to no avail.  For one, if you wanted to optimise for
performance, the unequivocal, vastly superior solution still remains that of
**using a `for`-loop: it's systematically significantly faster** and goes:

- `3.72` times faster than `[...arr].map(fn)`, and
- `8.05` times faster than `Array.from(arr, fn)`.  **EIGHT!!**

So, the next time your [linter](https://en.wikipedia.org/wiki/Lint_(software))
screams at you at the `ERROR` level that this is somehow inadequate:

```js
const boxes = [...document.querySelectorAll('.box')]
    .map(e => e.getBoundingClientRect())
```
{{ note(msg="this excerpt triggers the revolting `e18e/prefer-array-from-map` rule") }}

... **Know that it is rubbish.**

There is hardly any room for improvement, until you've measured that there is a
need for it; and when the time will come, be certain that some one-stop-shop,
low-hanging _"panacea"_ may be **more of a red herring than a [white
whale](https://en.wikipedia.org/wiki/Captain_Ahab)**[^red-herring].

[^red-herring]: _"More of a red herring than a white whale"_... Ah, I'm really
quite proud of that one!

Until then, good luck out there, have fun!
