+++
title = "More comprehensive key combinations with `XTerm`'s `modifyOtherKeys`"
date = 2026-07-16
description = '(Most of) the science that goes into having Vim distinguish `Ctrl`+`Shift`+`Y` from `Ctrl`+`Y`'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'quibblery', 'tmux', 'vim']
extra.cited_tools = ['tmux', 'vim']
+++

Your keyboard has no trouble distinguishing `Ctrl`-`Y` from
`Ctrl`-`Shift`-`Y`.  Your desktop has no trouble distinguishing them,
either.  Yet, if you were to attempt to distinguish them in your Vim
mappings, you might end up unravelling a thread not unlike that of
[Ariadne](https://en.wikipedia.org/wiki/Ariadne), though leading you down a
feverish rabbit-hole rather than out a [_"bovinarchic"_ (over which a bovine
reigns) hedge maze](https://en.wikipedia.org/wiki/Labyrinth).

<!-- more -->

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

In `tmux`, `set -g extended-keys on`; in Vim, `set keyprotocol=tmux:mok2`.<br>
And maybe a touch of `set noesckeys` as well.

> [!NOTE]
>
> Note that [Neovim](https://neovim.io/) needn't even be instructed explicitly
> and will by default negotiate one of two protocols (as of today, `XTerm or
> CSI-u`) with your terminal emulator.

And... Voilà!  You're all set.
Run the following:

```vim
nmap <C-S-Y> <CMD>echo 'Ctrl-Shift-Y'<CR>
nmap <C-Y>   <CMD>echo 'Ctrl-Y'<CR>
```

And see it work as you'd expect!

This set-up allows the various moving pieces to use a protocol that actually
distinguishes `<Alt/Meta>` + `<Some letter>` pressed together, from `<Esc>`,
then `<Some letter>` pressed in succession, which is indeed the baseline the
(CLI) world has been running on for over half a decade.

The solution here for Vim, `set keyprotocol=tmux:mok2`, does come with
some **possibly disappointing side-effect, in dismantling the semi-arcane
(albeit quite nifty) consequences** of that historical encoding for key
sequences that you may have come to rely on: if you do indulge in some
eyebrow-raising trickery (as I do), **you may find some recourse in [the
`noesckeys` option](#noesckeys)—though only through one of its surprising
by-products**.

> [!NOTE]
>
> Again, Neovim is exempt of that peculiarly, in having rethought
> that whole handling of keys, forgoing the more ancient
> architectures.[^not-that-nvim-is-better]

[^not-that-nvim-is-better]: Though I do not mean to say that Neovim is strictly
superior by all metrics on that front: it is a more complete, more "do what
we mean or expect", out of the box, for most people most of the time.<br>
The set-up with `noesckeys` is only paling in that context in comparison to
that of Neovim in, for example, not granting your possible wish for `PageUp`,
`PageDown`, `Home`, `End`, `Left`, `Down`, `Up`, `Right`, _et cet._ to behave
the way they would in a non-modal editor.  I—and many others—live just fine
without these in Vim.

This is **somehow remedied by a side-effect** to [setting the, otherwise
discouraged, `noesckeys` option](#noesckeys) in Vim.

</div>

Yet, if you were to attempt recognising either in your terminal application, the
best you'd generally interpret is `Ctrl`+`Y`, as you can experience for yourself
by mapping both in Vim:

```vim
nmap <C-S-Y> <CMD>echo 'Ctrl-Shift-Y'<CR>
nmap <C-Y>   <CMD>echo 'Ctrl-Y'<CR>
```

This is not a Vim mapping-syntax deficiency, it is an information-loss problem,
which has long been addressed: let's explore together!

## The diagnosis

An interactive terminal is not handed a rich graphical-toolkit key event saying
_"the key at such-and-such position went down while Control and Shift were
held"_.  It reads a stream of bytes from a pseudo-terminal.  The terminal
emulator therefore has to encode the keypress; every intermediary has to
preserve or translate that encoding; and the application has to decode it.

The traditional encoding predates any expectation that every modifier
combination should be bindable.  The [`VT100` user
guide](https://vt100.net/docs/vt100-ug/chapter3.html#T3-5) explicitly describes
the `CTRL` result for a key as applying whether it is _"shifted or unshifted"_.
For ASCII letters, the familiar operation is effectively to clear bits `5` and
`6`:

```txt
Y              0x59
Ctrl-Y         0x19
Ctrl-Shift-Y   0x19
```

There simply is no Shift bit left in `0x19`.  The same old encoding gives us
such aliases as `Ctrl-I` and `Tab`, both `0x09`; `Ctrl-M` and `Enter`, both
`0x0d`; and `Ctrl-[` and `Escape`, both `0x1b`.  These are not bugs in one
emulator.  They are properties of a compact, venerable convention that remains
indispensable for compatibility and inadequate for expressing a modern
keyboard in full.

Before changing configuration, keep the entire route in mind:

```txt
keyboard -> terminal emulator -> tmux -> Vim
```

Without `tmux`, remove one hop.  At every terminal-emulation boundary, however,
a participant may need to understand the chosen extension.

### Keys protocols

There is, alas, no one keyboard RFC to implement.  There are several
overlapping schemes, each describing somewhat different ideas of what a key
_is_ and how an application should negotiate for it.

The single most valuable account of their actual genealogy and
mechanics is **Thomas Dickey's [_XTerm — “Other” Modified
Keys_](https://invisible-island.net/xterm/modified-keys.html)**.  It preserves
the original correspondence, dates the implementations, explains the interaction
with `XKB` and X11's `*LookupString()` functions, and—rather more unusually—
tests competing implementations instead of merely repeating their promotional
claims.  Much of the chronology below is indebted to it.

> [!NOTE]
>
> _Thomas Dickey_ has been, **for several decades, the maintainer of `XTerm`,
> the most influential terminal emulator in existence**—second only to the
> `DEC VT100`, which was a physical one; of `ncurses`, the incontestably most
> influential <abbr title="Terminal User Interface">TUI</abbr> library in
> existence, he curates the `terminfo` directory, and is, by all metrics, a most
> stalwart and central figure to anything-terminal that's technically competent.

#### The normal, legacy encoding

The default remains the conservative one: printable keys produce their text,
established control combinations produce their control bytes, and `Alt` is
commonly represented by prefixing a key with `Escape`.

Thus `Alt-X` commonly arrives as:

```txt
ESC x
```

which is byte-for-byte identical to pressing `Escape`, then `x`, sufficiently
quickly.  Applications and multiplexers disambiguate those by waiting for a
short time.  We shall return to the resulting mischief in Insert mode.

#### `XTerm`'s `modifyOtherKeys`

Thomas Dickey added [`modifyOtherKeys` to
`XTerm`](https://invisible-island.net/xterm/xterm.log.html#xterm_214) in patch
`214`, released on 18 June 2006, at Dan Nicolaescu's suggestion.  Rather than
throwing modifiers away, level `2` can encode our example as:

```txt
Ctrl-Y         CSI 27 ; 5 ; 121 ~
Ctrl-Shift-Y   CSI 27 ; 6 ; 89  ~
```

`CSI` is the _Control Sequence Introducer_, ordinarily the two bytes `ESC [`.
The middle parameter follows xterm's modifier arithmetic: start at `1`, then
add `1` for Shift, `2` for Alt and `4` for Control.  Hence Control is `5`, and
Control plus Shift is `6`.

The current [`XTerm` manual's `modifyOtherKeys`
entry](https://invisible-island.net/xterm/manpage/xterm.html#VT100-Widget-Resources:modifyOtherKeys)
defines levels `0` through `3`:

- `0` disables it;
- `1` encodes only combinations without a useful conventional representation;
- `2` encodes all modified ordinary keys;
- `3`, added much later, also encodes unmodified ordinary keys.

Do not confuse those levels with the `4` in the control sequence used to select
the facility:

```txt
CSI > 4 ; 2 m    enable modifyOtherKeys level 2
CSI > 4 m        reset it
```

That `4` identifies the `modifyOtherKeys` resource; it is not a fourth level.
For Vim, level `2` is the useful one.  Its own help is admirably blunt: level
`1` does not work for this purpose.

#### `CSI u` and `fixterms`

`XTerm` patch
[`235`](https://invisible-island.net/xterm/xterm.log.html#xterm_235), from 20
April 2008, added Paul Evans's alternative `formatOtherKeys` representation:

```txt
Ctrl-Y         CSI 121 ; 5 u
Ctrl-Shift-Y   CSI 89  ; 6 u
```

Evans subsequently set out a more comprehensive set of rules in
[_fixterms_](https://www.leonerd.org.uk/hacks/fixterms/).  The term _CSI-u_ is
now used rather loosely: sometimes it denotes that wire shape, sometimes the
`fixterms` proposal around it, and sometimes a newer protocol extending both.
Do not infer identical semantics merely because two sequences end in `u`.

One consequential disagreement concerns shifted keys.  Should `Shift-Y` be
uppercase `Y`, with Shift consumed in producing the character, or base-key `y`
plus an explicit Shift modifier?  Both models are coherent.  They are not the
same model.

There is also the so-called [Kitty keyboard
protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/), an expansion of
the `CSI-u` idea which is of no use to the solution developed here and which I
will relegate to the footnote it deserves.[^kitty-keyboard-protocol]

[^kitty-keyboard-protocol]: Dickey's indispensable [_“Other” Modified
    Keys_](https://invisible-island.net/xterm/modified-keys.html#prog_kitty)
    documents a rather less heroic genealogy than Kitty's branding suggests:
    Goyal began Kitty by importing `pyte` and `glfw`, later discarded the
    attribution to `pyte`, and made his keyboard scheme from Evans's `CSI-u`
    and Shift handling together with xterm's modifier encoding for special
    keys.  Kitty's own document says merely that it is _“based on initial
    work in fixterms”_, then foregrounds _“Bugs in fixterms”_ and _“Why
    xterm's modifyOtherKeys should not be used”_.  That scarcely conveys the
    giants upon whose work it stands.  For our actual problem—losslessly
    reporting modifiers on ordinary keys—I have yet to find a deficiency in
    `modifyOtherKeys` level `2` that would warrant replacement.

    Firstly, I am not enamoured of taking an old, shared problem; building
    one more private extension around existing work; naming the result after
    one's own terminal emulator; and then relying on forceful promotion to
    have that branding mistaken for neutral standardisation.  Cue [`xkcd 927`
    on _Standards_](https://xkcd.com/927/), but sprinkle in a hefty dose of
    disparaging communication regarding alternative to your one hallowed truth.

    Secondly, I do not consider protocol stewardship separable
    from the steward's public conduct.  [This Hacker News
    discussion](https://news.ycombinator.com/item?id=41224245) collects an
    extraordinary chorus of independent encounters with a maintainer variously
    described as arrogant, insulting, dismissive and openly contemptuous
    of workflows he did not prescribe—`tmux` most of all.  The same
    pig-headedness manifests in features of varying degrees of abhorrence:
    official Kitty binaries, for instance, perform an opt-out network
    update check every `24` hours and announce any result through a desktop
    notification.  Goyal is of course entitled to build whatever he pleases;
    nobody else is obliged to mistake belligerence for technical authority or
    entrust him with a shared standard.

    The disingenuity in the achievement, the glaring disdain for the greater
    environmental diversity and the generally blind arrogance elevated to a
    proper faith, all constitute a material reason not to hand that project more
    influence over the ecosystem.  A serious `CLI` dweller should dweller should
    quite seriously think twice before jumping aborad the kitty-everything
    train: the propaganda you're being served is never the whole story.

For this article, we need only a lossless description of modifiers, and
`modifyOtherKeys` level `2` is a deliberately modest common denominator for
`tmux` and Vim.

### Adoption and compatibility concerns

There is more to picking a protocol: **the support requirement is conjunctive**.
It is not enough that your terminal emulator supports a protocol, nor that Vim
supports it; every terminal-emulation boundary between keyboard and editor must
agree upon some representation which preserves the information you care about:

```txt
terminal emulator <-> multiplexer <-> application
```

The arrows go both ways.  The application requests a mode towards the left; the
eventual key report travels towards the right.  The participants have distinct
jobs:

- the **terminal emulator**, such as Ghostty or `foot`, must understand the
  request and encode the physical input without collapsing its modifiers;
- the **terminal multiplexer**, such as `screen` or `tmux`, must understand
  what the outer terminal sends _and_ present a compatible terminal to the
  application in its pane;
- the **application**, such as Vim or Neovim, must request an encoding its
  immediate terminal understands and decode what comes back.

One missing implementation breaks the chain.  A terminal can emit the richest
key event imaginable; if `tmux` parses it as an ordinary legacy key, the lost
modifier cannot be reconstructed downstream.  Conversely, immaculate support in
`tmux` and Vim is moot if the outer terminal sent both chords as `0x19` in the
first place.

> [!NOTE]
>
> `SSH` does not ordinarily add another such boundary.  It transports the byte
> stream between a local and remote pseudo-terminal; it neither parses a
> keyboard protocol into internal key events nor serialises those events anew.
> `$TERM`, remote `terminfo`, PTY allocation and latency can certainly cause
> terminal trouble over `SSH`, but `SSH` itself is a courier here, not another
> translator.

`tmux`, by contrast, very much **is** another terminal emulator.  It terminates
the outer protocol, represents the key internally, and serialises it again for
the pane.  The outer and inner formats need not even match.  This is precisely
the extra compatibility surface for which Mitchell Hashimoto criticises
multiplexers.  [I still love `tmux`](@/flight-manual/tmux-or-not-tmux.md); that
does not make him wrong about the plumbing.

For our particular chain:

- Ghostty and foot both understand xterm `modifyOtherKeys` level `2`;
- tmux has understood extended xterm and `CSI-u` keys since `3.2`, with its
  present, much less surprising mode handling arriving in `3.5`;
- Vim gained `modifyOtherKeys` decoding in patch `8.1.2134`, and gained the
  declarative `'keyprotocol'` option in patch `9.0.0930`;
- Neovim understands both encodings and negotiates them automatically.

This is also why `$TERM` matters without telling the whole story.  Outside
`tmux`, Vim addresses the actual terminal emulator.  Inside, it normally sees
`tmux-256color`: an accurate description of its **immediate** terminal, and the
one for which Vim must select a protocol.  The rest is tmux's responsibility.

## Solution for tmux + vim

The following targets tmux `3.5` or later, where extended-key handling and the
output-format choice have their current, intelligible shape.

In `tmux.conf`:

```tmux
set -s extended-keys on
set -s extended-keys-format xterm
set -as terminal-features ',foot*:extkeys,xterm-ghostty:extkeys'
```

`extended-keys-format xterm` is currently the default; spelling it out makes
the contract with Vim explicit.  The `terminal-features` line tells tmux that
those _outer_ terminals understand extended keys.  Recent tmux versions detect
foot themselves; released versions may still need the Ghostty entry.  Use your
actual outer `$TERM` pattern if it differs.

These are server and terminal-capability settings.  Reload the file, then start
a fresh tmux server—or at least attach a fresh client—before concluding that
nothing happened.

In a current `vimrc`:

```vim
set keyprotocol+=tmux:mok2,screen:mok2

nnoremap <C-S-Y> <Cmd>echo 'Ctrl-Shift-Y'<CR>
nnoremap <C-Y>   <Cmd>echo 'Ctrl-Y'<CR>
```

The `screen` entry covers configurations that expose a `screen-*` `$TERM`
inside tmux.  `mok2` tells Vim to request level `2` and decode its xterm
sequences.

For an older Vim without `'keyprotocol'`, use the less declarative equivalent:

```vim
let &t_TI = "\<Esc>[>4;2m"
let &t_TE = "\<Esc>[>4;m"
```

The complete transaction is now:

```txt
Vim -> tmux:      enable modifyOtherKeys level 2
tmux -> terminal: enable modifyOtherKeys level 2
terminal -> tmux: report Ctrl-Shift-Y with its modifiers intact
tmux -> Vim:      re-encode Ctrl-Shift-Y in xterm format
Vim:              match <C-S-Y>, not <C-Y>
```

Use `:verbose map` to have current Vim show the detected protocol and mappings.
Testing at the shell with `cat -v` is liable to mislead: unless something has
enabled an extended protocol there, it can only show you the legacy encoding.

### Problems it creates

There is a tempting but wrong way to make the tmux setting more emphatic:

```tmux
set -s extended-keys always
```

`always` sounds reassuring.  It is not a stronger spelling of `on`.

- With `on`, the application in a pane may request mode `1`, mode `2`, or the
  normal mode.
- With `always`, tmux substitutes mode `1` when the application requests the
  normal mode.

That can expose extended encodings to programmes that never asked for them,
including ZLE or Readline.  More subtly, it prevents an application from fully
returning to the old encoding when it has a good reason to do so.  **Use `on`;
let the foreground application negotiate.**

Vim has such a reason in Insert mode.  Recall that legacy `Alt-X` is `ESC x`.
`tmux` also watches for an `ESC` prefix and, within its `escape-time`, may
recognise `Escape` followed by `x` as the logical key `Alt-X`.  With extended
keys active, it can re-encode that key unambiguously.  An intended pair of
actions—leave Insert mode with `Escape`, then execute normal command `x`—has
become one `<M-x>` key before Vim can separate it.

That is especially bothersome if, like me, you use Alt mappings in Insert mode
as one-stroke excursions into normal-mode actions:

```vim
inoremap <M-I> <Esc>I
inoremap <M-A> <Esc>A
inoremap <M-O> <Esc>O
```

One can patch individual collisions with more mappings, but that is not a
systematic answer.  It mistakes the symptom for the boundary at which the
problem should be solved.

Neovim largely _Just Works_: it probes for `CSI-u` support and falls back to
`modifyOtherKeys` when unavailable.  Through `tmux`, that generally means
the latter.  It decodes either format, so no Neovim counterpart to Vim's
`'keyprotocol'` line is normally required.

### This just in!!! {#noesckeys}

Vim already has the systematic answer:

```vim
set noesckeys
```

The name is less exciting than the result.  `'esckeys'` controls whether keys
beginning with `Escape` are recognised in Insert mode.  Since patch `8.1.2261`,
turning it off also makes Vim disable `modifyOtherKeys` while entering Insert
mode, then restore it upon leaving.  In Vim's own words:

> NOTE: when this option is off then the `modifyOtherKeys` and
> `xterm-bracketed-paste` functionality is disabled while in Insert mode to
> avoid ending Insert mode with any key that has a modifier.

That qualification—_while in Insert mode_—is the elegant bit.  Normal, Visual
and the other command-oriented modes retain their spacious extended-key
vocabulary.  Insert mode temporarily returns to the old encoding, where Vim
treats `ESC` as `Escape` rather than waiting to discover whether it prefaces a
special key.  Thus `Escape`, `x` is once again `Escape`, `x`, and the protocol
comes back on as soon as Vim has left Insert mode.

There is a price.  Modified and function keys whose encodings begin with
`Escape` no longer work normally in Insert mode; `modifyOtherKeys` mappings are
unavailable there; and Vim also disables bracketed paste for that mode, so it
cannot distinguish pasted text from typed text with the usual delimiters.  If
you rely heavily on any of those, `'noesckeys'` may be the wrong trade.

For my use, it is exactly right: richer mappings where Vim is interpreting
commands; plain, immediate `Escape` semantics where I am inserting text.
Together, the complete configuration is pleasingly small:

```tmux
# tmux.conf
set -s extended-keys on
set -s extended-keys-format xterm
set -as terminal-features ',foot*:extkeys,xterm-ghostty:extkeys'
```

```vim
" vimrc
set keyprotocol+=tmux:mok2,screen:mok2
set noesckeys
```

The important achievement is not that Vim has learned a cleverer mapping.  It
is that **the entire chain has agreed not to discard the distinction before the
mapping engine sees it**.  Yippee!

So, I suppose the final verdict is: either use Neovim, or don't rely on
semi-arcane (albeit quite nifty) consequences of the historical encoding for key
sequences, or set both `keyprotocol=tmux:mok2` (or `kitty` in place of `mok2`,
although...[^kitty-keyboard-protocol]) as well as `noesckeys` and live with
the (possibly effectively innocuous) consequences of particular keys yielding
certainly undesirable results in `i`nsert mode.
