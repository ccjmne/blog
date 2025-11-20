+++
title = 'System-wide clipboard history with `fcitx5`'
date = 2025-11-19
description = 'Does not only the obvious, but also **hides your passwords**'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all']
draft = true

[[extra.cited_tools]]
   name    = 'fcitx5'
   repo    = 'https://github.com/fcitx/fcitx5'
   package = 'extra/x86_64/fcitx5'
   manual  = 'https://fcitx-im.org/wiki/Fcitx_5'
[[extra.cited_tools]]
   name    = 'keepassxc'
   repo    = 'https://github.com/keepassxreboot/keepassxc'
   package = 'extra/x86_64/keepassxc'
   manual  = 'https://keepassxc.org/docs/#command-line'
+++

A staple of the frantic user's tool belt, the clipboard history needs no
introduction.

I remember the day one of my colleagues excitedly demonstrated their
newly-acquired copy-paste buffer history plug-in that would work well inside
the very specific _"file editing"_ view of their <abbr title="convoluted
abstraction over build tools">`IDE`</abbr>.  I remember it well, because
it was **last year**—a whopping **half a century** or so after
[`vi`](https://en.wikipedia.org/wiki/Vi_(text_editor)) introduced them.

Ah, and <abbr title="The ubiquitous editor">Vim</abbr> today offers a lofty
**forty-five** registers, complete with bindings to append, replace, print from
as plain text, print from as if you were typing it, _et cet._; see [`:help
registers`](https://vimdoc.sourceforge.net/htmldoc/usr_10.html).

**But I digress.**

What Vim doesn't quite do with its many registers is **avail them to other
applications**.  For that, you've got your syste—

Ah, I'm being told that neither _Windows_ nor _macOS_ actually
offers any more than _one_ measly "clipboard", despite `X11`
having had, **since the early 1990s** at the latest, a
[complete, detailed specification for **no less than three such
buffers**](https://www.x.org/archive/current/doc/xorg-docs/icccm/icccm.pdf),
two of which are exceptionally convenient and still **completely
supported and working across the board (BSD and Linux)**—even many
[Wayland](https://wayland.freedesktop.org/) compositors implement that
compatibility to the `X11` specification.

**But I digress some more.**

If you're neither in a sensible text editor, nor on a sensible `OS`, and that
despite your recurring-payment-contingent system gradually unveiling its <abbr
title="lacking, pauce">dearthy</abbr> core, its familiar-enough face has you
keep coming back...  I bid you good luck[^good-luck]; the rest of us shall
tonight feast on a tidy serving of `fcitx5` goodness.

[^good-luck]: I truly mean this in good faith, and you're obviously much welcome
to stay and join us—I only jest here, I have no qualms against users of any
platform.  Plus, in all honestly, I have absolutely no doubt that the very same
capabilities are available on these as well.

## Clipboard history with `fcitx5`

A built-in add-on to `fcitx5`, the `clipboard` module lets you 

## Some discretion manipulating passwords

https://github.com/fcitx/fcitx5/blob/39274f29116681a16c3a0b02b814369c6530df09/src/modules/clipboard/clipboard.h#L45

Pairs well with **the premier password manager** (xkeepassxc): 

https://github.com/keepassxreboot/keepassxc/blob/f484d7f5ed00d77a6cd5f913663f5c437707901a/src/gui/Clipboard.cpp#L55-L65

## A proper input method

On the topic of passwords, another benefit of using `fcitx` is that it still
is an **input method**, rather than a tool that pastes content.  From the
perspective of the applications that receive your input, you're indeed just
typing text in.

Take the example of these utterly misguided—and hopefully
antiquated—practice[^dont-disallow-pasting], whereby some **password inputs
would disallow being pasted into**:

   [^dont-disallow-pasting]: Its main achievement is in **ensuring you're using
passwords you remember**, and that very principle is indeed becoming antiquated
quite fast.  It's not that keeping your password nowhere but in your head isn't
safe—that'd be safe alright, even you are subject to losing access—it's that
this practice encourages **reusing passwords, or perhaps familiar patterns in
designing them**: the very fact there's a **design** to your passwords is the
vulnerability.<br>
   Although, come to think of it, [diceware
passphrases](https://en.wikipedia.org/wiki/Diceware) are indeed quite a good
idea, and not too much of a chore to either remember or type.  Maybe the
obsolescence is obsolete.  What goes around comes around!

```html
<input type="password" onpaste="return false;" placeholder="Passwords, please!">
```

<!-- can't spread this over several lines, lest it gets wrapped into a <p> -->
<input type="password" onpaste="return false" placeholder="Passwords, please!" style="display: block; background-color: var(--colour-surface0); border: 1px solid var(--colour-accent); padding: .5rem 1rem; color: var(--colour-text); width: var(--column-width); box-shadow: 0 3px 0 0 var(--colour-crust); margin: 0 auto 3px;">
{{ note(msg="you shouldn't be able to **paste** anything in this `<input>`") }}

No pasting allowed.  But if you're running `fcitx5`, you may just open up
your trusty global clipboard machine and pour your precious secrets into my
confidential ear—though if you'd be so kind as to rather mail me them, I don't
operate a [keylogger](https://en.wikipedia.org/wiki/Keystroke_logging) here...
