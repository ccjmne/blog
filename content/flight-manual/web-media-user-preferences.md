+++
title = 'Adapt the Web to `@media` preferences'
date = 2025-10-28
description = "Account for [media features](https://developer.mozilla.org/en-US/docs/Web/CSS/@media#media_features) describing your user's wants or needs"
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'web', 'css', 'accessibility']
+++

In building for the Web, we have access to quite a bit of context in surrounding
the environment in which our content is being consumed.

Right there, in [Håkon Wium's](https://www.w3.org/People/howcome/)
original [proposal for Cascading Style Sheets
(`CSS`)](https://www.w3.org/People/howcome/p/cascade.html) all the way back in
1994, that idea had already been incepted—although only the **presentation
target medium** was considered back then:

> Current browsers consider the computer screen to be the primary presentation
> target, but HTML [...] has the potential of supporting many output media, e.g.
> paper, speech and braille.

Two years later, the first version of `CSS` saw the light of day, albeit without
media rules, and another two years after that, `CSS2` introduced the `@media`
queries reifying precisely Håkon's original vision.

Now well into `CSS3`, the `@media` queries have kept evolving as a specification
of their own, and today offer a large set of [media
features](https://developer.mozilla.org/en-US/docs/Web/CSS/@media#media_features),
among which come several pertaining to **user preferences**
introduced by the [W3C's Media Queries Level 5 working
draft](https://www.w3.org/TR/mediaqueries-5/).  Let's get familiarised with
these, in decreasing order of prevalence in the wild.

## `prefers-color-scheme`

The most common **user preference** `@media` feature is the
[`prefers-color-scheme`](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme),
which lets you probe for the **user's preference in either a light or a dark
theme**.  On operating systems that support dark mode settings, modern Web
browsers often offer to propagate this option dynamically as the preference to
be picked up by this `@media` feature.

```css
body {
  background-color: #333;
  color: #fff;
}

@media (prefers-color-scheme: light) {
  body {
    background-color: #fff;
    color: #333;
  }
}
```

Its possible values are `light` and `dark`.

In the example above, the default styles provide bright text (`#fff`) on a dark
background (`#333`).  If the user prefers a light theme, the styles inside
the `@media` rule will override the defaults to swap the background and text
colours.

> [!TIP]
>
> You can also use the `prefers-color-scheme` media feature directly in `<link>`
> elements to load different style sheets based on the user's colour scheme
> preference:
>
> ```html
><link rel="stylesheet" href="/light.css">
><link rel="stylesheet" href="/dark.css" media="(prefers-color-scheme: dark)">
> ```
>
> There's more on that in **the last section of this article** regarding the
> [`media` HTML attribute](#the-media-html-attribute).

## `prefers-reduced-motion`


The [`prefers-reduced-motion`](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion)
media feature allows a site to detect if the user has requested that animations
and motion be minimized.  While this is particularly important for users who
may experience motion sickness, it also is much liked by those of us that like
browsing the Web to **gather information**.

For example, my blog uses [view
transitions](https://developer.mozilla.org/en-US/docs/Web/CSS/view-transitions),
but justly disables them according to your possible preference for reduced
motion:

```css
@media (prefers-reduced-motion) {
  html { scroll-behavior:      unset; }
  *    { view-transition-name: none !important; }
}
```

I had also been toying with the idea of using `smooth` scrolling, but couldn't
even suffer it for myself and made sure to disable that in as well.  Other
notable uses may be to avoid `autoplay`ing videos, animated GIFs, etc...

> [!NOTE]
>
> Your implementation for "reduced" motion needn't be as drastic as I chose it
> to be for my blog: you could also opt for, for instance, **largely speeding up
> animations instead of removing them** altogether.

Its possible values are `no-preference` and `reduce`.

Besides the two most prevalent user preference `@media` features described
above, there are a few more that you may consider supporting:

## `prefers-contrast`

This `@media` feature lets you adapt your design with regards to contrast
preferences.  I've rarely seen this used, but I know that some popular colour
schemes for syntax highlighting offer variants with varying contrast options,
notably for the dark variants.

For example, [Rosé Pine](https://github.com/rose-pine/neovim) has three variants:

- the default one is dark,
- a _"Moon"_ variant is dark with lowered contrast, and
- a _"Dawn"_ variant is light.

You could use a combination of `prefers-color-scheme` and `prefers-contrast` to
serve the appropriate variant based on the user's preferences:

```css
:root {
  /* source Rosé Pine *Dawn* here         (light) */
}
@media (prefers-color-scheme: dark) {
  :root {
    /* source Rosé Pine *default* here    (dark) */
  }
}
@media (prefers-color-scheme: dark) and (prefers-contrast: less) {
  :root {
    /* source Rosé Pine *Moon* here       (dark, lower contrast) */
  }
}
```

In the example above, you'd have the light theme by default, the main dark theme
if your user communicates such a preference, and the lower-contrast one if you
require both a dark theme and lower contrast.

Its possible values are `no-preference`, `more`, and `less`.

## `prefers-reduced-transparency`

Rarely if ever come across, in my (admittedly) limited experience, this `@media`
feature lets you respect your users' preference for reduced transparency
effects.

Its possible values are `no-preference` and `reduce`.

## `prefers-reduced-data`

Lastly, this `@media` feature is intended to help you detect whether your user
prefers would prefer Web content that consumes less data.

In practice, you could maybe disable the [prefetching of
resources](https://developer.mozilla.org/en-US/docs/Glossary/Prefetch), or could
for example serve images of lower resolution:

```html
<link rel="prefetch" href="readmore.html" media="(prefers-reduced-data: no-preference)">
```
{{ note(msg="you can pre-load the next blog article unless the user wants to save their data") }}

Although, in practice, prefetching is more likely to be disabled in the data &
privacy configuration of a Web browser than through this preference.

Its possible values are `no-preference` and `reduce`.

## The `media` HTML attribute

The `media` attribute on the `<link>` and `<style>` HTML elements allows you to
specify the media type or media query that the linked or embedded style sheet is
designed for.  This attribute can be used to apply styles conditionally based on
the user's device or preferences.

For example, you can use the `media` attribute to apply styles specifically for
print media:

```html
<link rel="stylesheet" href="print.css" media="print">
```

In this example, the `print.css` style sheet will only be applied when the
document is printed.

> [!TIP]
>
> This isn't limited to style sheets or even `<link>` elements: you can use it
> anywhere.  For example, it may find purpose in `<picture>` elements to serve
> different images based on many things, such as your user's preference in terms
> of contrast, whether their device is in portrait or landscape mode, etc...
>
> ```html
> <picture>
>     <source srcset="/assets/lamp-post.jpg" media="(orientation: portrait)" />
>     <img    src="/assets/longboat.jpg" />
> </picture>
> ```
