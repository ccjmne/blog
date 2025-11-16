+++
title = 'A `<details>` drop-down without JavaScript'
date = 2025-11-14
description = 'Exploring specifications and technical implementations to build collapsible content with nothing other than `HTML` and `CSS`'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'web', 'css']
+++

The very recent[^very-recent] `<details>` tag (and its `<summary>` companion)
lets us create collapsible content in plain `HTML`.  _In plain `HTML`!_  Though
you're likely to want to add some `CSS` styling to make it look remotely
palatable, JavaScript may very well be kept at bay entirely.  Let's explore a
bit and see what can be done with it.

<!-- (@/ramblings/why-no-javascript). TODO: LINKME -->

[^very-recent]: Available across browsers [since
2020](https://caniuse.com/details).

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

<div class="user-agent">
   <div id="actual-menu" style="border: 1px solid var(--colour-accent) !important; display: inline-flex !important;">
      <details name="menu">
         <summary>File</summary>
         <div>
            <button>Open</button>
            <button>Save</button>
            <button>Exit</button>
         </div>
      </details>
      <button>Undo</button>
      <button>Redo</button>
      <details name="menu">
         <summary>Font style</summary>
         <div>
            <button>Normal</button>
            <button style="font-weight: bold !important;">Bold</button>
            <button style="font-style: italic !important;">Italic</button>
         </div>
      </details>
      <details name="menu" min-sm>
         <summary>Alignment</summary>
         <div>
            <button style="text-align: left !important;">Left</button>
            <button style="text-align: center !important;;">Center</button>
            <button style="text-align: right !important;;">Right</button>
         </div>
      </details>
   </div>
</div>

A menu bar in ~20 lines of `CSS`, fully navigable by keyboard, [Web
crawlers](https://en.wikipedia.org/wiki/Web_crawler) and [screen
readers](https://en.wikipedia.org/wiki/Screen_reader), without a hint of
JavaScript in sight.

</div>

I'll section this article in three parts, where we'll go over the templating
aspects, the styling quirks and possibilities, and finally a practical example,
in that order.

## The `DOM` markup logic

In the relevant [`MDN`
docs](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/details),
the `<details>` element is introduced as such:

> The `<details>` HTML element creates a disclosure widget in which information
> is visible only when the widget is toggled into an open state. A summary or
> label must be provided using the `<summary>` element.

Consider the following `HTML` snippet:

```html
<details>
   This is the collapsible content.  It can include text,
   images—anything you want.
</details>
```

I do my best to render it below [as "default" as it
gets](https://www.geeksforgeeks.org/css/what-is-a-user-agent-stylesheet/),
except for some background colour and centring, to keep the article comfortable:

<div class="lo" style="margin: 0 auto; padding: 0;">
   <div class="user-agent" style="width: var(--column-width);">
      <details>
         This is the collapsible content.  It can include text,
         images—anything you want.
      </details>
   </div>
</div>

Yeah, that's pretty bare—but, crucially, _functional_.  You may click on the
label to collapse and expand the piece of content it's encapsulating.

### The `<summary>` in the `<details>`

Something's iffy, however: [just like the
devil](https://en.wikipedia.org/wiki/The_devil_is_in_the_details), wasn't the
`<summary>` prescribed to belong as well in the `<details>`?  The `MDN` quote
above mentions that **a label must be provided using the `<summary>` element**,
yet we didn't include one in the previous snippet.

To me today, that label reads _"Details"_.  While being fairly standard across
Web browsers in an English-language context (as far as I could tell), that value
still is left to the discretion of the **user agent** (_i.e._, the client's Web
browser).

  I went and tracked down [the specification
documents](https://html.spec.whatwg.org/multipage/interactive-elements.html#the-details-element)
at the <abbr title="Web Hypertext Application Technology Working
Group">`WHATWG`</abbr> to ascertain either way, and sure enough, it is fairly
ambiguous, in stating both that the _Content Model_ of `<details>` shall include:

> One `<summary>` element followed by _Flow Content_.

Yet also (and conversely), that:

> The first `<summary>` element child of the element, if any, represents the
> summary or legend of the details. If there is no child summary element, the
> user agent should provide its own legend (_e.g._ "Details").

In any case, there isn't a single example there of a `<details>` element without
its `<summary>` "firstborn" (`> summary:first-child`), and for what it's worth,
the [`W3C`'s Markup Validation Service](https://validator.w3.org/detailed.html)
is aligned to the `WHATWG` specification in disallowing the omission of the
`<summary>` child element in `<details>`.

I conclude that **we'd do well to always include a `<summary>` element** as
the first child of our `<details>`, to ensure consistent behaviour across user
agents—we'll likely wish to have some control over the label anyway.

In summary, you may customise the label of a `<details>` element by providing it
with a `<summary>` child:

```html
<details name="linked">
   <summary>Woof!</summary>
   <span style="font-size: 3em !important;">🐶</span>
</details>
```
<br>
<div class="lo" style="margin: 0 auto; padding: 0;">
   <div class="user-agent" style="display: flex; gap: 2rem;">
      <details name="linked">
         <summary>Woof!</summary>
         <span style="font-size: 3em !important;">🐶</span>
      </details>
   </div>
</div>

### The `[open]` attribute and the `[name]` linking

I lingered far too long on the `<summary>` element, so I'll keep this one
straight to the point.  There's only a couple more things to know about the
`DOM` structure:

- an **expanded** `<details>` element gets an additional `[open]` attribute, and
- several distinct `<details>` sharing the same `[name]` attribute get their
  expanded/collapsed states linked together, so that opening any forcibly closes
  the others.

```html
<details name="linked" open> <!-- note this <details> being [open] -->
   <summary>Quack!</summary>
   <span style="font-size: 3em;">🦆</span>
</details>
<details name="linked">
   <summary>Moo!</summary>
   <span style="font-size: 3em;">🐮</span>
</details>
<details name="linked">
   <summary>Meow!</summary>
   <span style="font-size: 3em;">🐱</span>
</details>
```
{{ note(msg="Its `[open]` attribute makes the 🦆 start out **expanded**") }}

<br>
<div class="lo" style="margin: 0 auto; padding: 0;">
   <div class="user-agent" style="display: flex; gap: 2rem;">
      <details name="linked" open>
         <summary>Quack!</summary>
         <span style="font-size: 3em !important;">🦆</span>
      </details>
      <details name="linked">
         <summary>Moo!</summary>
         <span style="font-size: 3em !important;">🐮</span>
      </details>
      <details name="linked">
         <summary>Meow!</summary>
         <span style="font-size: 3em !important;">🐱</span>
      </details>
   </div>
</div>

That's it!  There isn't much more to the `<details>` from the perspective of its
mark-up.  Let's get on now with the matter that is becoming most pressing, I'm
sure: its styling possibilities.

## The styling guidebook

First thing first: **you don't need to keep that odd triangle marker that
the user agent places before the `<summary>` text**.  You can style it away
or replace it with something more fitting to your design, by targeting its
`::marker` pseudo-element, in either of its two possible states, via the `:open`
pseudo-class on the parent `<details>`:

```html
<style type="text/css">
   details      summary::marker { content: '😶‍🌫️ ' }
   details:open summary::marker { content: '👻 ' }
</style>
<details>
   <summary>Peekaboo?</summary>
   I see you!
</details>
```
<br>
<div class="lo" style="margin: 0 auto; padding: 0;">
   <div class="user-agent">
      <style type="text/css">
         details[name="peekaboo"]       summary::marker { content: '😶‍🌫️ ' }
         details[name="peekaboo"][open] summary::marker { content: '👻 ' }
      </style>
      <details name="peekaboo">
         <summary>Peekaboo?</summary>
         I see you!
      </details>
   </div>
</div>

In practice, support [for the `:open`
pseudo-class](https://caniuse.com/?search=%3Aopen) on the `<details>` and
[for the `::marker` pseudo-element](https://caniuse.com/?search=%3Aopen) on
`<summary>` is not quite universal yet: _Safari is the notable bad apple on that
front_—ha!

- To circumvent the lacking support for `:open`, you can simply target the
  `[open]` attribute on `<details>` instead, and
- to play nice with the poor `::marker` support, the WebKit-based browsers
  (read: _Safari_) can target it with `::-webkit-details-marker` instead (which
  will _only work with those Browsers_).

  > [!WARNING]
  >
  > The `::-webkit-details-marker` selector [only supports tweaking _very
  > few_ properties](https://bugs.webkit.org/show_bug.cgi?id=204163),
  > such as `color` and `font-*`, which is regrettably largely inadequate
  > for many purposes—notably that of proper internationalisation.
  > In short, Safari's support for remotely serious uses of
  > the `::marker` pseudo-selector, for `<li>` just as for
  > `<summary>` is _not there yet_.  However, in [September 2024, the
  > `GoodFirstBug`](https://bugs.webkit.org/show_activity.cgi?id=204163) keyword
  > was added to the tracker for that issue upstream at WebKit, so you may have
  > at it ;)

In any case, bending that marker to your specific will would often entail
**disabling it entirely** and working rather with your own `::before` and
`::after` additions—just as you would with `<li>` elements in lists:

```html
<style type="text/css">
   details summary { cursor: pointer }
   details summary::marker { content: '' }
   details::before {
      content: 'New';
      font-size: .8em;
   }
   details:not(:open)::before { color: green }
   details:open::before { content: 'Read' }
   details:open summary {
      text-decoration: line-through;
      color: grey;
   }
   summary + section { padding-left: 1.5em; border-left: 2px solid lightgrey; }
</style>
<details>
   <summary>Subject: 🎉💰 URGENT: You've Won $1,000,000 Today! 💰🎉</summary>
   <section>
      <h3>Congratulations, lucky friend!</h3>
      Click HERE to claim your prize NOW! 💷💶💵💴
   </section>
</details>
```
<br>
<div class="lo" style="margin: 0 auto; padding: 0; box-sizing: border-box !important;">
   <div class="user-agent">
      <style type="text/css">
         details[name=mail] summary { cursor: pointer !important; }
         details[name=mail] summary::marker { content: '' !important; }
         details[name=mail]::before {
            content: 'New' !important;
            font-size: .8em !important;
         }
         details[name=mail]:not(:open)::before { color: var(--colour-green) !important; }
         details[name=mail]:open::before { content: 'Read' !important; }
         details[name=mail]:open summary {
            text-decoration: line-through !important;
            color: var(--colour-overlay2) !important;
         }
      </style>
      <details name="mail">
         <summary>Subject: 🎉💰 URGENT: You've Won $1,000,000 Today! 💰🎉</summary>
         <section>
            <h3>Congratulations, lucky friend!</h3>
            Click HERE to claim your prize NOW! 💷💶💵💴
         </section>
      </details>
   </div>
</div>

In any case, this is still workable, without even forgoing Safari users!
Without further ado, onto the <abbr title="The chief dish of a meal">pièce de
résistance</abbr> we go.

## A practical drop-down example

Let us, arrive at the crown jewel of this article: **a drop-down menu bar,
entirely in `HTML` and `CSS`**:

```html
<style type="text/css">
   #menu              { display: flex }
   #menu details      { position: relative }
   #menu button:hover,  #menu details summary:hover  { background-color: grey }
   #menu button:active, #menu details summary:active { background-color: lightgrey }
   #menu button,        #menu details summary {
      padding: .5rem 1rem;
      cursor:  pointer;
      /* Add tweaks to align the style of button and summary */
   }
   #menu details > :not(summary) {
      display:        flex;
      flex-direction: column;
      position:       absolute;
      min-width:      100%;
      z-index:        1;
   }
</style>

<div id="menu">
   <details name="menu">
      <summary>File</summary>
      <div>
         <button>Open</button>
         <button>Save</button>
         <button>Exit</button>
      </div>
   </details>
   <button>Undo</button>
   <button>Redo</button>
   <details name="menu">
      <summary>Font style</summary>
      <div>
         <button>Normal</button>
         <button style="font-weight: bold;">Bold</button>
         <button style="font-style: italic;">Italic</button>
      </div>
   </details>
   <details name="menu">
      <summary>Alignment</summary>
      <div>
         <button style="text-align: left;">Left</button>
         <button style="text-align: center;">Center</button>
         <button style="text-align: right;">Right</button>
      </div>
   </details>
</div>
```

Yep, it really is **that simple**.  Some ~20 lines of `CSS`, and a stunningly
sane `HTML` template.  Here's a live rendering of the above—with adjustments
to the colours to fit this blog's scheme:

<div class="lo" style="margin: 0 auto; padding: 0; border: 1px solid var(--colour-accent);">
   <div class="user-agent">
      <style type="text/css">
      #actual-menu              { display: flex !important; }
      #actual-menu details      { position: relative !important; }
      #actual-menu button:hover,  #actual-menu details summary:hover  { background-color: var(--colour-base) !important; }
      #actual-menu button:active, #actual-menu details summary:active { background-color: var(--colour-mantle) !important; }
      #actual-menu button,        #actual-menu details summary {
         padding:          .5rem 1rem !important;
         border:           0 !important;
         border-radius:    0 !important;
         background-color: var(--colour-lo-bg) !important;
         color:            var(--colour-text) !important;
         font-size:        1rem !important;
         cursor:           pointer !important;
      }
      #actual-menu details > :not(summary) {
         display:        flex !important;
         flex-direction: column !important;
         position:       absolute !important;
         min-width:      calc(100% + 2px) !important;  /* Align own borders    */
         left:           -1px !important;              /* to that of container */
         border:         1px solid var(--colour-accent) !important;
         border-top:     0 !important;
         z-index:        1 !important;
      }
      #actual-menu, #actual-menu * {
         box-sizing: border-box !important;  /* Assist in aligning borders */
      }
      #actual-menu [min-sm] { display: none !important; }
      @media (min-width: 544px) { #actual-menu [min-sm] { display: initial !important } }
      </style>
      <div id="actual-menu" style="margin-inline: -1rem !important;">
         <details name="menu">
            <summary>File</summary>
            <div>
               <button>Open</button>
               <button>Save</button>
               <button>Exit</button>
            </div>
         </details>
         <button>Undo</button>
         <button>Redo</button>
         <details name="menu">
            <summary>Font style</summary>
            <div>
               <button>Normal</button>
               <button style="font-weight: bold !important;">Bold</button>
               <button style="font-style: italic !important;">Italic</button>
            </div>
         </details>
         <details name="menu" min-sm>
            <summary>Alignment</summary>
            <div>
               <button style="text-align: left !important;">Left</button>
               <button style="text-align: center !important;;">Center</button>
               <button style="text-align: right !important;;">Right</button>
            </div>
         </details>
      </div>
   </div>
</div>

> [!TIP]
>
> You could consider adding `user-select: none` to the `<summary>` elements to
> prevent accidental text selection when the user may be frantically clicking
> around, especially in these sorts demonstrations.

Of course this menu I suggest would rely on buttons that cannot work without
JavaScript, but you'll note that **I use essentially the same template on this
very blog to collapse the navigation items on mobile devices**, where space
comes at a premium.

Using bare `<a>` links and `CSS` media queries, I can have a **fully functional
navigation menu that works responsively across all devices**, without a single
line of JavaScript.  And now, so can you!
