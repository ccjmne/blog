+++
title = 'Enter Unicode characters with `fcitx5`'
date = 2025-11-04
description = 'Reclaim the em-dash from the LLMs—or spell my name as my parents intended'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'quibblery']

[[extra.cited_tools]]
   name    = "ibus"
   repo    = "https://github.com/ibus/ibus"
   package = "extra/x86_64/ibus"
   manual  = "https://github.com/ibus/ibus/wiki"

[[extra.cited_tools]]
   name    = "fcitx5"
   repo    = "https://github.com/fcitx/fcitx5"
   package = "extra/x86_64/fcitx5"
   manual  = "https://fcitx-im.org/wiki/Fcitx_5"
+++

`IBus`, standing (vaguely) for *Intelligent Input Bus*, is an input framework
that allows users to, for example, switch between different keyboard layouts,
which any non-English native speakers reading this blog would certainly be
familiar with.

It is used by default notably on `GNOME`-based desktop environments, making it
the *de facto* standard for many Linux users.  However, `IBus` has been somewhat
finicky for me (and others) when working with <abbr title="A replacement for the
X11 window system protocol">Wayland</abbr>[^wayland-finicky]—which is where
`fcitx5`[^fcitx-5] comes in.

[^wayland-finicky]: Although "applications being finicky" under Wayland will
come at no surprise to anyone, I will note that it mostly has to do with running
a lot of <abbr title="X Window System version 11">`X11`</abbr> applications
actually **through a compatibility layer**, and [`NVIDIA` notoriously having
been an execrable collaborator](https://www.youtube.com/watch?v=MShbP3OpASA) in
helping the Linux kernel developers integrate their hardware into the ecosystem.

[^fcitx-5]: `fcitx5` is a fairly recent project (started around 2019) led by the
same original author, a *complete rewrite* of its predecessor, infusing new life
into `fcitx` notably in including first-class Wayland support, a vastly more
modern codebase, greater performance (reportedly), and some unified theming and
configuration tools.

But `fcitx5` is a lot other than *"Wayland's `IBus`"*: just as vaguely, it
stands for *Flexible Context-aware Input Tool with eXtension support*, and today
I intend to keep it short and focus on its [Unicode](https://home.unicode.org/)
input module, to tie up this introduction.

## Familiar code points entry

`fcitx5` has a **built-in Unicode input method** that allows users to enter any
Unicode character by its code point.  Just start the daemon, verify that your
`journalctl --user --unit fcitx5` shows `Loaded addon unicode`, and you're all
set.

To use it, simply switch to the `Unicode` input method—by default,
`Ctrl`-`Shift`-`U`, and type the **hexadecimal code point** of the character you
want to enter, followed by `Enter` or `Space`, cancelling out with `Esc`.

I am hugely fond of hyphens, en dashes and em dashes (and I do sorely resent
the dreadful notion that [writers that employ them may be of the artificial
complexion](https://www.nightwater.email/em-dash-ai/), and you will not catch me
present a range with anything other than the adequate punctuation mark.

- `Ctrl-Shift-U`, then `2013` and voilà, you transformed **a subtraction** into
a **numeric range**.

   The first World War didn't *"span negative four"*, or whatever `1914-1918`
   may mean; it actually raged on **from 1914 through 1918**, `1914–1918`.

- `Ctrl-Shift-U`, then `2014`, and you can aptly document the suspicion of
unorthodoxy in the rhetoric of your fellow comrades:

   > "Except—" began Winston doubtfully, and then stopped.<br>
   > It had been on the tip of his tongue to say "Except the proles," [...]

<div style="text-align: end;">— George Orwell, <em>Nineteen Eighty-Four</em></div>

- `Ctrl-Shift-U`, then `300` unlocks a Frenchman's ability to start a sentence
with the preposition "to", `À`.

- `301`, and I get to put the acute accent (`́ `) on any letter I fancy,
possibly even spelling my name the way my parents intended, `Éric`.

- `302` gives you the circumflex, as in `Île` (island in French), `303`
the tilde, `304` the macron, `305` the overline, and so on... [take your
pick!](https://codepoints.net/combining_diacritical_marks)

But you don't have to index all of Unicode in your head—besides,
that valuable space is well-known to be [most suitable for `π`'s
digits](https://www.pi-world-ranking-list.com/?page=lists).

## Unicode search

What about the characters you won't reach for regularly enough to commit to
(muscle?) memory their code point?  With `Ctrl`+`Shift`+`Alt`+`U` (I like to
call this "<abbr title="relating to the fingers">digital</abbr> mouthful" a
*"handful"*), you will be able to **search by description**.

- Drawing some <abbr title="Terminal User Interface">`TUI`</abbr>
menu?  Have enough boxes to [make Brad Pitt's head
spin](https://en.wikipedia.org/wiki/Seven_(1995_film)):

   ```txt
   ┌───────────────────┐
   │  ╔═══╗ Some Text  │
   │  ╚═╦═╝ in the box │
   ╞═╤══╩══╤═══════════╡
   │ ├──┬──┤           │
   │ └──┴──┘           │
   └───────────────────┘
   ```
   {{ note(msg="from Wikipedia's article on [box-drawing characters](https://en.wikipedia.org/wiki/Box-drawing_characters)") }}

- the ideograph for love?  [戀 is all that you
need](https://en.wikipedia.org/wiki/All_You_Need_Is_Love)—according to the
Beatles

- a healthy serving of spaghetti?  🍝, delivered on a silver platter.

## And even reverse-search

Lastly, here's the neat trick that originally sold me on better adopting
that tool: the "digital mouthful" `Ctrl`+`Shift`+`Alt`+`U` pops up **already
displaying some elements** before you even start searching: they're **your
current selection** and the contents of your clipboard, for convenient
reverse-lookups.

Will you need that often?  It does have *some* dubious value in being only able
to pop up **where you can type**, but I reckon that shouldn't be a problem for
any serious `CLI` dwellers.

And if once in a while you tend to some finesse writing, you might
very well save yourself some `xxd` invocations—unless you can
distinguish a [soft-hyphen](https://unicode-explorer.com/c/00AD) from a
[non-breaking space](https://unicode-explorer.com/c/00A0), from a [regular
space](https://unicode-explorer.com/c/0020)...
