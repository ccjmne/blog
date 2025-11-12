+++
title = 'Enter Unicode characters with `fcitx5`'
date = 2025-11-04
description = 'Reclaim the em-dash from the `LLM`s—or spell my name as my parents intended'
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

The `fcitx5` functionality I reach for the most, its
[Unicode](https://home.unicode.org/) module lets you **access an astronomical
number of characters**, symbols and glyphs with the expected convenience.
But beyond the obvious, it also bundles a pearl of ingenuity that lets you
**identify** these invisible, combining or other peculiarly artful characters
like a jeweller would delight in examining a rare gem.

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

- `Ctrl`-`Shift`-`U`, then `2013` and voilà, an **en dash (`–`)**,
transforming **subtractions** into a **numeric ranges**.

   The first World War didn't _"span negative four"_, or whatever _1914-1918_
   may mean; it actually raged on **from 1914 through 1918**, _1914–1918_.

- `Ctrl`-`Shift`-`U`, then `2014` and you can wield the **em dash (`—`)** to
aptly document your suspicion of unorthodoxy in the rhetoric of your fellow
comrades:

   > "Except—" began Winston doubtfully, and then stopped.<br>
   > It had been on the tip of his tongue to say "Except the proles," [...]

   {% attribution() %} — George Orwell, _Nineteen Eighty-Four_ {% end %}

- `Ctrl`-`Shift`-`U`, then `300` gives you the grave accent (`` ` ``), which
unlocks a Frenchman's ability to start a sentence with the preposition "to",
`À`.

- `301`, and you get to put the acute accent on any letter you fancy, possibly
even spelling my name the way my parents intended, `Éric`.

- `302` gives you the circumflex, `303` the tilde, `304`
the macron, `305` the overline, and so on... [take your
pick!](https://codepoints.net/combining_diacritical_marks)

But while I find all of these notable examples to be surprisingly
easy to remember, you do not have to index all of Unicode in your
head—that valuable space is well known to be [most suitable to `π`'s
digits](https://www.pi-world-ranking-list.com/?page=lists) after all.

## Unicode search

What about the characters you won't reach for regularly enough to commit to
(muscle?) memory their code point?  With `Ctrl`-`Shift`-`Alt`-`U` (I like to
call this "<abbr title="relating to the fingers">digital</abbr> mouthful" a
_"handful"_), you will be able to **search by description**.

- Drawing some <abbr title="Terminal User Interface">`TUI`</abbr>
menu?  Have enough [boxes to make Brad Pitt's head
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
that tool: the "digital mouthful" `Ctrl`-`Shift`-`Alt`-`U` pops up **already
displaying some elements** before you even start searching: they're **your
current selection** and the contents of your clipboard, for convenient
reverse-lookups.

Will you need that often?  It does have _some_ dubious value in being only able
to pop up **where you can type**, but I reckon that shouldn't be a problem for
any serious `CLI` dwellers.

And if once in a while you tend to some finesse writing, you might
very well save yourself some `xxd` invocations—unless you can
distinguish a [soft-hyphen](https://unicode-explorer.com/c/00AD) from a
[non-breaking space](https://unicode-explorer.com/c/00A0), from a [regular
space](https://unicode-explorer.com/c/0020)...
