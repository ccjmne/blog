+++
title = 'Why have no JavaScript'
date = 2025-11-16
description = "The reasons why, without distate for nor lack of competence in JavaScript, numerous Web sites forgo it altogether"
taxonomies.section = ['ramblings']
taxonomies.tags = ['all', 'web', 'javascript']
+++

This very blog is notably exempt of JavaScript, and it certainly isn't born
out of inability or disdain for the technology—on the contrary, my close
colleagues would know me to be quite the enthusiast.

Yet, be they technical, strategic, or user-centric, there are indeed quite a few
reasons why you might build a Web site without JavaScript, or **at least ensure
it works even when JavaScript is disabled**.

The first argument, however hand-wavy, would be that of reliability and
resilience: **a site that works without JavaScript simply has fewer failure
points.**  If a script fails to load, a dependency breaks, an ad(vert)-blocker
disallows some file or procedure, or through any of the slew of other errors
that could happen, the site still functions.  You would essentially be doing
away with an entire third of your technological landscape, and it would happen
to be the one by far most prone to breaking spuriously—**though JavaScript in
itself isn't in any way unreliable**.

<div class="hi">

Secondly, eliminating JavaScript (just as eliminating anything would), results
in faster loading times and better performance.  Though, again, **JavaScript
itself is astonishingly well optimised for speed nowadays**, relying on an
entire framework like React for each and every site is indisputably leading to
sluggishness, though admittedly mostly surfacing under certain conditions.

Let's not mince words: starting off with React **because it's what people do**
means founding your Web site on technologies catering to <abbr title="DX"
font="mono">_Developer Experience_</abbr>, presumably only ever tested on
high-end devices with extremely fast connections.

{% punchline() %} The product shouldn't take the back-seat to the developer's
"convenience" to the point of enabling complacency while establishing disdain
for enhancing the end-user experience. {% end %}

For reference, here's an article detailing how [Netflix dramatically improved
their site's performance by ditching React for their
front-end](https://medium.com/dev-channel/a-netflix-web-performance-case-study-c0bcde26a9d9).

In short, removing JavaScript generally **eliminates render-blocking
resources**, reduces **`CPU` usage** (especially valuable on mobile devices),
often cuts down enormously on **network requests**, and slashes the overall
**bundle size**.  Is it fair to complain that your Web browser with 20+
tabs running 24/7 is hogging 2GB of RAM, yet still reach for full-blown Web
"frameworks" every change you've got?

The science of Web performance isn't just vaguely arcane, either: numerous
metrics exist to quantify and qualify how well a site performs in real-world
conditions.  To name a few, have
the [`LCP`](https://developer.mozilla.org/en-US/docs/Glossary/Largest_contentful_paint),
the [`INP`](https://developer.mozilla.org/en-US/docs/Glossary/Interaction_to_next_paint),
the [`CLS`](https://developer.mozilla.org/en-US/docs/Glossary/CLS)
the [`TTI`](https://developer.mozilla.org/en-US/docs/Glossary/Time_to_Interactive), and
the [`TBT`](https://web.dev/total-blocking-time/)—yes, I am being serious, the
performance folks did figure that three-letter acronyms are <abbr title="the
focus of fashion or style">where it's at</abbr>.

Through these and many others, we have **a tangible baseline for real-world
performance**, all generally worsened by excessive JavaScript usage.

</div>

Thirdly, concerns regarding accessibility and compatibility arise: not
all users have JavaScript available or reliable.  For example, users on
**locked-down corporate machines** (both of my current professional activities
have this business requirement!), browsers or set-ups **disabling JavaScript
for privacy and/or security reasons**, low-power devices (**older mobile
phones, e-readers...**)...  Together with **greater support for Search Engine
Optimization** (`SEO`), too, in static Web sites being naturally far easier to
crawl and index.  In a few words: a JavaScript-free site ensures that everyone
gets a usable baseline.

<div class="hi">

But here's the kicker: maintenance burden and cognitive overload.  Adopting
whatever rubbish _"framework du jour"_ may help the clueless, resolve-less,
hapless Web developer-wannabe get something up and running by following the path
of greatest popularity, but it does come with a cost that we trained ourselves
to not perceive[^unperceived-cost]: **you have even less of a clue what you're
doing, and the several layers of abstractions in the way are constantly shifting
beneath your feet.**

<!-- [Web development-wannabe](@/ramblings/youre-no-web-developer.md) in the first place, as well as TODO: LINKME-->

[^unperceived-cost]: We tend to get so tangled up on software architecture,
design patterns, nauseatingly redundant "best practices", prescriptivist
<abbr title="Clean Code">baseline guidelines for the neophytes of 20
years ago</abbr> to contribute something vaguely coherent that "scales",
[`DRY`](@/ramblings/the-dry-hoax.md), `SOLID`, _et.c._, that we somewhere
seemingly **lost the habit of taking a break and a good holistic look at what
it is we're putting together**, and what's underneath the soulless shell of
ego-fattening inanities.

If you don't know yet, the **NodeJS ecosystem is infamous for its vast number
of dependencies and frequent breaking changes**.  We're talking libraries that
determine whether something's an array, whether a string is empty...  And yep,
there are actual, frequent (well, frequent enough, nowadays) criminal exploits
hinging on the fact that (most notably) **JavaScript projects run code acquired
transitively that the consumer neither cares for nor audits**.

Simplicity is (or rather, generally would be) of extraordinary value in software
development.  **[Ginger Bill](https://www.gingerbill.org/) (the mind behind
[Odin](https://odin-lang.org/)) talks of [package managers being
evil](https://www.gingerbill.org/article/2025/09/08/package-managers-are-evil/)**,
and you'd have a hard time rejecting the premise of his arguments against
sprawling dependencies, or the legitimacy of his credentials.

  **We used to prepare JavaScript for the Web with shell scripts and
Makefiles.**  Not because we didn't know any better; but because that was, not
even that long ago, the obvious, the sensible, the sufficient and the mainstay
way to go about doing that.<br>
  Then came [Grunt](https://odin-lang.org/), then [Gulp](https://gulpjs.com/),
then [Webpack](https://webpack.js.org/), then [Rollup](https://rollupjs.org/),
then [Vite](https://vitejs.dev/).  Each with their sets of plug-ins, loaders and
tools, with tree-shaking, bundling, minification, transpiling, polyfills, shims,
all **maintained by various eclectic communities of open-source developers,
arriving at different, similar, competing solutions to either battle-tested or
up-and-coming principles to still. just. stitch. together. bits of JavaScript in
a format that the Web of yesteryear is fine with**.

To procure said bits of code in the first place, are several repositories,
such as [Bower](https://bower.io/), [jsDelivr](https://www.jsdelivr.com/),
[unpkg](https://unpkg.com/); which may or may not be resolved and manage through
any combination of [npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/),
[pnpm](https://pnpm.io/)...  Some libraries didn't use to be published on all
platforms, either; how mad is that?  Actually not one bit.

Then come the several ways to solve the seemingly innocuous
problem of having several libraries available in a single
project, in spite of JavaScript's historically polluted global
namespace:  [AMD](https://requirejs.org/docs/whyamd.html),
[CommonJS](https://wiki.commonjs.org/wiki/CommonJS),
[SystemJS](https://github.com/systemjs/systemjs),
[UMD](https://github.com/umdjs/umd), [ES
Modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules),
[IIFEs](https://developer.mozilla.org/en-US/docs/Glossary/IIFE)...

And that's before we even touch on the stunning litany of ever-evolving
frameworks and libraries, from [jQuery](https://jquery.com/)
to [Angular](https://angular.io/), encompassing the obvious
[React](https://react.dev/), [Vue](https://vuejs.org/),
[Svelte](https://svelte.dev/), [Solid](https://www.solidjs.com/), but not either
forgetting [AngularJS](https://angularjs.org/), [Ember](https://emberjs.com/),
[Lit](https://lit.dev/), [Polymer](https://www.polymer-project.org/)—the list
goes on and on.

Of course, I'm assuming here that you're just running
[NodeJS](https://nodejs.org/en), not [Deno](https://deno.com/), not
[Bun](https://bun.com/).  And certainly not TypeScript—which used to be a
set-up challenge of its own.

Shall we suppose that just because the framework is deprecated and subsequently
abandoned, the several applications built on top of it needn't be maintained any
longer?

</div>

Anyhow, in spite of my deep, personal conviction that **the systematic,
uneducated, premature adoption of some megabyte of of production dependencies**
to essentially **template some button** makes for a deplorable practice, I
didn't only choose to forgo JavaScript for this blog just because _"dependencies
are misery, performance is paramount and compatibility is key"_.  Nah, I
wouldn't do anything about that: not only do I not know these axioms to be
true this generally, I also am confidently armed with the rarefied aptitude to
address and reconcile them through **incisive, learned, deliberate decisions
that don't start and end with the _"obvious"_**.

I've actually used all of the above technologies (and then some), enough to tout
professional capabilities in most, and outright mastery in a few; I have surfed
the `#usetheplatform` wave; I have built JavaScript-only applications; I have
engineered my <abbr title="Single-Page Application">`SPA`</abbr> library, still
used in production; I have made the innocent mistake of building my "native"
desktop app running on Electron...  **Whatever revolutionary, remotely popular
idea was had in the last 15 years with regards to building the Web, name it:
good or bad, I've given it a serious go.**

{% punchline() %} For now, I just want a break.  I want to be lean and scrappy,
and work within the limitations that foster creativity. {% end %}

I want to focus on building something that lets me push content, on the Web, in
a plain, simple, proven and perennial way, and build a system that could **stand
the test of time**.

Ultimately, I want to experience again the time when [we were fucking
Webmasters.](https://justinjackson.ca/webmaster/)
