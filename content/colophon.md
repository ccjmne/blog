+++
title = 'Colophon'
template = 'plain.html'
description = 'Exceptionally boring technology, by design'
+++

<!-- [choose boring technology](@/flight-manual/choose-boring-technology). TODO: LINKME -->

<div class="hi">

This colophon[^colophon] addresses all that goes into the design principles that
drive the technical implementation of this blog.

In a few words, it isn't built like one of these moderns Web blobs throwing
heaps of heterogeneous modern solutions at modern problems.

</div>

## Not much of anything

I suggest here that these modern problems are merely perceptual or cultural:
there is no problem and I therefore provide, refreshingly, no solution.

**No dependencies.**

This Web site is compiled using a [single binary
executable](https://www.getzola.org/): it has zero dependencies.

None on `CSS` preprocessors, none on JavaScript frameworks, none on templating
system, none on image processing pipelines...

There are no vaguely arcane vulnerabilities possible, no breaking changes
upstream, no obsolescence of any kind in any development tool: no maintenance,
at all, by design, for perpetuity.

**No JavaScript either.**

Despite being quite the enthusiast, here I mean again to take a stance: no
JavaScript.  None for the interactive elements (drop-down menu, links and
back-references, annotation tooltips, collapsible table of contents...), none
for the responsiveness, none for the templating or styling.

**And no pictures.**

What do you know, text also works quite well to convey information, although
I did indulge in some few <abbr title="Scalable Vector Graphics">`SVG`</abbr>
icons rendered in their native dimension of 16×16 pixels.

## Uncompromising simplicity

This entire Web site employs a single `CSS` document, and
each article is a single `HTML` page.  The rest are a few
fonts, optimised for Web performance using the [Web Open Font
Format](https://en.wikipedia.org/wiki/Web_Open_Font_Format).

On the topic of the `CSS`, you won't find in there any rounded corner, any
shadows, any opacity, any background or text gradient, nor any click or hover
animation.  I trade generic, hyper-modern, canned design for some bold,
stand-alone, simple elegance.

A full "production" build, creating all files from scratch, syntactically
highlighting code blocks, preparing all `RSS`/Atom feeds, _et cet._ takes about
`125ms`.

Once I address the <a href="#room-for-improvement">outstanding caching
challenge</a>, that entry shall also tout uncompromising performance.

<!-- TODO: in uncompromising performance, mention savvy preloading mechanisms,
among other things -->

## B-but, the user experience?

The `UX` is still very much front and centre.

This Web site is optimised for all devices from mobiles to desktop,
for landscape and portrait displays alike, for both dark and light
modes, all responsively adjusting to your physical set-up and [personal
preferences](@/flight-manual/web-media-user-preferences.md).

It also looks surprisingly fancy in offering [semantically grounded
transitions](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API)
on Web browsers that support them while also degrading gracefully
on those that do not, and being respectful of your [possible
preferences](@/flight-manual/web-media-user-preferences.md) for reduced motion
in either case.

I'd go so far as to argue that this package is certain to be quite more
polite and comprehensive than the average <abbr title="Single-Page
Application">`SPA`</abbr> you'd find in the wild.

## Some room for improvement {#room-for-improvement}

There remains the question of adequate accessibility that I haven't quite
addressed yet: this Web site isn't most navigable through screen readers,
and some elements in the info-bar for articles and series may be lacking in
contrast—though that is a semantic and stylistic choice.

Additionally, the caching strategy is suboptimal: this site is currently hosted
on [GitHub Pages](https://docs.github.com/en/pages), which doesn't support
custom caching rules, but I intend to remedy that situation one of these days.

[^colophon]: The [colophon](https://en.wikipedia.org/wiki/Colophon_(publishing))
is a piece of content that shares meta information regarding the document it
annotates.  Examples of such are found as far back as antiquity, on very clay
tablets.
