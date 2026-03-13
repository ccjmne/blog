+++
title = 'Incrementing and decrementing with Vim'
date = 2026-02-23
description = 'A simple trick, masterfully doubled-down upon with one of these `g`-twists'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'vim']

[[extra.cited_tools]]
name    = "vim"
repo    = "https://github.com/vim/vim"
package = "extra/x86_64/vim"
manual  = "https://vimhelp.org/"
[[extra.cited_tools]]
name    = "date"
repo    = "https://github.com/coreutils/coreutils"
package = "core/x86_64/coreutils"
manual  = "https://man.archlinux.org/man/date.1.en"

[[extra.cited_vimhelp]]
code    = "'nrformats'"
page    = "options.txt"
excerpt = """
    This defines what bases Vim will consider for numbers when using the
    `CTRL-A` and `CTRL-X` commands for adding to and subtracting from a number
    respectively."""
[[extra.cited_vimhelp]]
code    = "v_g_CTRL-A"
page    = "change.txt"
excerpt = """
    Add `[count]` to the number or alphabetic character in the highlighted
    text.  If several lines are highlighted, each one will be incremented by
    an additional `[count]` (so effectively creating a `[count]` incrementing
    sequence)."""
[[extra.cited_vimhelp]]
code    = "v_o"
page    = "visual.txt"
excerpt = """
    Go to `O`ther end of highlighted text: The current cursor position becomes
    the start of the highlighted text and the cursor is moved to the other end
    of the highlighted text.  The highlighted area remains the same."""
+++

Vim has a delightful built-in feature, whereby it can increment—or
decrement—numbers directly in the text.  But, as usual, this simple
premise gets squeezed for maximum utility when you combine with the _count_
mechanism, the visual mode(s), and the `g` prefix.  Oh and, one very simple
plug-in[^be-wary-of-plugins] can make it more usable yet.

[^be-wary-of-plugins]: I've mentioned this before, but I should mention it
    again: **plug-ins are third-party code that you install and run on
    your machine**.  Do not install plug-ins whose codebase you haven't
    assessed, whose maintainers you haven't vetted.  In _no case_ is it okay
    to auto-update plug-ins.  And do pin them to a specific version; merely
    reinstalling them on a new machine shouldn't be an excuse for ignoring the
    fact that you're now running code from _some guy on the Internet_.

    You don't quite have to perform a full-on review each commit, but **you do
    have to discern** which are maintained by communities you don't have full,
    extensive confidence in, and **take _a look_ at _each commit_**, for its
    subject message and its author, complete with signature.

    Is that too extreme?
    [Not](https://visualstudiomagazine.com/articles/2025/12/08/threat-actors-keep-weaponizing-vs-code-extensions.aspx)
    [one](https://instatunnel.my/blog/automated-dependency-side-loading-the-invisible-supply-chain-attack-via-ai-extensions)
    [bit](https://byteiota.com/malicious-vs-code-extensions-steal-developer-credentials/).
    No time for this?  Then, no plug-ins; or no updating plug-ins you've already
    reviewed.  Generally, I'll recommend plug-ins that are **done**, because
    these you can review and maintain!

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

The basics are strikingly simple:

- `<C-A>` **increments** the number under the cursor, or the next one on the line,
- `<C-X>` **decrements** the number under the cursor, or the next one on the line,
- you may prefix with a count: `5<C-A>` adds `5`, `10<C-X>` subtracts `10`.

In the visual selection mode(s):

- `<C-A>` and `<C-X>` operate on the number closest to the beginning of each
  line in the selection, on each line, at once;
- you may use visual-block (`<C-V>`) selection to operate only on specific
  columns of a subset of lines

And, a surprise to many, the `g` prefix turns this into a nifty **sequence
manipulator**:

- `g<C-A>` increments them **sequentially**: first line by `1`, second by `2`,
  third by `3`, etc.
- `g<C-X>` decrements them **sequentially**: first line by `-1`, second by `-2`,
  third by `-3`, etc.
- using a _count_ with `g` controls the step size: `5g<C-A>` increments the
  first line by `5`, the second by `10`, the third by `15`, etc.

> [!TIP]
>
> In Vim, the `bin`, `octal` and `hex` flags of `nrformats` are on by
> default.This means that `007` becomes `010` when incremented, not `008`. You
> may want to add `set nrformats-=octal` to your `.vimrc` to disable this
> behaviour.
>
> Note that **Neovim does away with the `octal` one** being on _by default_,
> which alleviates that puzzlement.  You can of course still _choose_ to use it.

</div>

## The basics: `<C-A>` and `<C-X>`

In normal mode, place your cursor on (or before) a number and hit `<C-A>` to
increment it, or `<C-X>` to decrement it:

Relating the good news brought about by
[Deep Thought](https://en.wikipedia.org/wiki/List_of_The_Hitchhiker%27s_Guide_to_the_Galaxy_characters#Deep_Thought)?
Place your cursor on `41`, and press `<C-A>`:

<div class="grid-1-2">
<div>

```txt
The answer is 41.
```
{{ note(msg="be on `41`") }}
</div>
<div>

```txt
The answer is 42.
```
{{ note(msg="after `<C-A>`") }}
</div>
</div>

> [!IMPORTANT]
>
> From now on, I'll use the `^A` and `^X` notations to denote `<C-A>` and
> `<C-X>`, respectively.  Also, in case that wasn't too clear, `<C-A>`, as well
> as `^A`, mean holding `Ctrl` and pressing `A`.

### Automatically jump to valid target

Well, actually, **you don't have to be quite _on_ a number**.  Anywhere on a
line that contains a valid `^A` or `^X` target will have Vim **jump to that
target** when performing said action:

<div class="grid-1-2">
<div>

```txt
Copyright (c) 2025 ACME Inc.
```
{{ note(msg='"this is so _last year_"') }}
</div>
<div>

```txt
Copyright (c) 2026 ACME Inc.
```
{{ note(msg="with `^A`, Vim jumps to `2025` and increments it") }}
</div>
</div>

Neat already, but it gets yet niftier when you have **{ multiple numbers on a
line }**:

Get to that line, press `^X` to drop Brazil's score to `0`, then nudge your
cursor just a smidgen to the right with `l`, and use `^A` to bump France's score
to `3`:

<div class="grid-1-2">
<div>

```txt
Brazil: 1, France: 2
```
{{ note(msg="assuming cursor on `Brazil`") }}
</div>
<div>

```txt
Brazil: 0, France: 3
```
{{ note(msg="after `^X`, `l`, `^A`") }}
</div>
</div>

Voilà, the final score of the [1998 FIFA World
Cup](https://en.wikipedia.org/wiki/1998_FIFA_World_Cup#Bracket), in all its
glorious splendour.

### Also with `count`

Like most Vim commands, you can prefix with a `count` ([`:help
count`](https://vimdoc.sourceforge.net/htmldoc/intro.html#count)), and these
bindings will behave as you'd expect.  Consider the following line:

```txt
HTTP 200
```

With your cursor anywhere on this line, use `4^A`:

```txt
HTTP 204
```

This becomes particularly useful when you need to adjust multiple values quickly
without doing arithmetic in your head.

### Also dot-repeatable

It's dot-repeatable, as well; which may be pretty neat.  Consider this command
spawning a Docker container with up to `128M` memory:

```sh
docker run -it -d           \
  --name     html2pdf       \
  --restart  unless-stopped \
  --publish  3000:3000      \
  --env-file html2pdf.conf  \
  --memory   256M           \
  ghcr.io/ccjmne/puppeteer-html2pdf:latest
```

Is `128` not enough?  Modern tools do require "modern" amounts of resources,
after all; let's say that `400`-something might be about right.

Jump to the `--memory 128M` line with `/mem`, then apply one savvy `32^A`
to have `256` turn into `288` (that's `32` more: I don't know that, I
just applied this very procedure I'm describing).  Press `.` ([`:help
.`](https://vimdoc.sourceforge.net/htmldoc/repeat.html#single-repeat)) and it
goes `320`; once more and you get `352`, then `384`, and `416`.  Too far?  Just
`u`ndo ([`:help u`](https://vimhelp.org/undo.txt.html#undo)) back and forth!

## Choose what and how to increment

By default, Vim recognizes different number formats
controlled by the `nrformats` option ([`:help
'nrformats'`](https://vimdoc.sourceforge.net/htmldoc/options.html#'nrformats')).
This can lead to _surprising_ behaviour if you're not aware of it; thankfully,
there are plenty of remedies, all baked into the system.

### The octal trap

With default settings, **numbers with leading zeros are treated as octal**:

```txt
007
```
{{ note(msg="`007` in octal would be `7` in decimal") }}

After `^A`:

```txt
010
```
{{ note(msg="that's **octal** for `8`, not what most people expect!") }}

To disable octal interpretation:

> [!NOTE]
>
> In Vim, the `bin`, `octal` and `hex` flags of `nrformats` are on by default.
> However, **Neovim does away with the `octal` one** being on _by default_,
> which alleviates that puzzlement.  You can of course still _choose_ to use it.
>
> I am partial to `:set nf=bin,hex,blank` and won't shy away from a quick
> `:set nf+=alpha` once in a while, which can trivially be undone with `:set
> nf-=alpha`.

### Binary and hexadecimal support

Vim and Neovim also handle binary and hexadecimal numbers when `nrformats`
includes `bin` and `hex`, respectively, which both editors do by default.
Consider the following example in some configuration file:

On the `ASCII` line, use `32^A`[^ascii-upper-lower] to switch to lower case; on
the `flags` line, use `4^X` to unset flag `4`:

[^ascii-upper-lower]: The `ASCII` codes for upper- and lower-case are
precisely `32` (`0x20`) apart!  In fact, the entire `ASCII` table, and its
"extensions", like `UTF`, are quite savvily laid out.  Here's one quite tidy
[video from Computerphile](https://www.youtube.com/watch?v=MijmeoH9LT4)
on the subject: UTF-8 came from a mere [literal
back-of-a-napkin](https://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt)
creation from the beautiful mind of [Kenneth Lane
Thompson](https://en.wikipedia.org/wiki/Ken_Thompson).

<div class="grid-1-2">
<div>

```ini
ascii = 0x41    ; the letter 'A'
flags = 0b0101  ; flags 1 and 4
```
</div>
<div>

```ini
ascii = 0x61    ; the letter 'a'
flags = 0b0001  ; flag 1 only
```
{{ note(msg="use `32^A` on the first line, then `4^X` on the second") }}
</div>
</div>

### Alphabetic support, too

If `nrformats` includes `alpha`, even **letters** can be incremented:

<div class="grid-1-2">
<div>

```txt
Option A
```
{{ note(msg="have your cursor on `A`") }}
</div>

<div>

```txt
Option B
```
{{ note(msg="after `^A`") }}
</div>
</div>

This neither "overflows" nor wraps around: decrementing `a` or `A` has no
effect, neither does incrementing `z` or `Z`.  A corollary to that would be that
the `[a-z]` and `[A-Z]` sets work independently of each other: you cannot hop
from `z` to `A` nor from `Z` to `a`.

### The visual mode(s) power multiplier

It may go without saying, but you may affect several lines at once with the
various visual modes.  For example, consider a _catalogue of Web server
addresses_.  We use the character- or line-wise visual modes, `v` or `V`, to
more adequately label our hosts:

<div class="grid-1-2">
<div>

```ini
server0 = 192.168.1.10:8000
server0 = 192.168.1.10:8000
server0 = 192.168.1.10:8000
```
{{ note(msg="highlight with `vip`, increase with `g^A`") }}
</div>
<div>

```ini
server1 = 192.168.1.10:8000
server2 = 192.168.1.10:8000
server3 = 192.168.1.10:8000
```
{{ note(msg="after `vip` and `^A`") }}
</div>
</div>

You want the last octet of the IP to increment, but not the port.  Position
cursor on the first `10`, then `^Vjjk` (or `2jiw`, `2jt:`, ...) to visually
select the final octet of all IP addresses:

```ini
server1 = 192.168.1.10:8000
server2 = 192.168.1.10:8000
server3 = 192.168.1.10:8000
;                   ^^
;    selected across all three lines
```
{{ note(msg="select the last octet of that IP address (`10`) across all three lines, in block-wise visual mode (`^V`)") }}

Then `g^A` to affect each line of **the selection**, rather than the first
adequate target **in the selection**, rather than the first overall, on each
line (as a mere `V` would).

```ini
server1 = 192.168.1.11:8000
server2 = 192.168.1.12:8000
server3 = 192.168.1.13:8000
```
{{ note(msg="note the last octet of each IP address now reading `11`, `12`, and `13`, respectively") }}

## The main course: `g^A` and `g^X`

Just in time, as I chose to use it for the note on best leveraging the visual
modes, here's where things get genuinely scrumptious.  The `g^A` ([`:help
v_g_CTRL-A`](https://vimhelp.org/change.txt.html#v_g_CTRL-A)) command applies
**sequential** increments: the first selected line is incremented by `1`, the
second by `2`, the third by `3`, and so on.  It also works as you imagine it
would with `g^X`.  For illustration, start with this:

<div class="grid-1-2">
<div>

```txt
0
0
0
0
0
```
{{ note(msg="500 milliseconds before") }}
</div>
<div>

```txt
1
2
3
4
5
```
{{ note(msg="after `vip` and `g^A`") }}
</div>
</div>

Note that even the **first line** is incremented: if you want to go from a block
of `1`, `1`, `1`, `1`, `1`, to a series of `1`, `2`, `3`, `4`, `5`, you'll want
to start off (or punctuate with) a complementary `^X`.

<div class="grid-1-3">
<div>

```txt
1
1
1
1
1
```
{{ note(msg="1 second before") }}
</div>
<div>

```txt
2
3
4
5
6
```
{{ note(msg="after `vip` and `g^A`") }}
</div>
<div>

```txt
1
2
3
4
5
```
{{ note(msg="after `gv` (reselect last) and `^X`") }}
</div>
</div>

Well, either that, or you could better select your target and skip the first
line...

<div class="grid-1-2">
<div>

```txt
1
1     < select only these lines
1     < select only these lines
1     < select only these lines
1     < select only these lines
```
{{ note(msg="500 milliseconds before") }}
</div>
<div>

```txt
1
2
3
4
5
```
{{ note(msg="after `vip`, `oj` ([`:help v_o`](https://vimdoc.sourceforge.net/htmldoc/visual.html#v_o)) and `g^A`") }}
</div>
</div>

Two by two?  Five by five?  No problem, `count` now specifies the step.

<div class="grid-1-2">
<div>

```txt
0
0
0
0
0
```
{{ note(msg="500 milliseconds before") }}
</div>
<div>

```txt
5
10
15
20
25
```
{{ note(msg="after `vip` and `5g^A`") }}
</div>
</div>

Let's appreciate how well all these simple tips articulate together into a
greater whole.  The following example supposes some sort of _hex dump_ you'd
want to annotate with addresses:

```txt
4c6f 7265 6d20 6970 7375  Lorem ipsu
6d20 646f 6c6f 7220 7369  m dolor si
7420 616d 6574 2c20 636f  t amet, co
6e73 6563 7465 7475 7220  nsectetur 
6164 6970 6973 6369 6e67  adipiscing
2065 6c69 742c 2073 6564   elit, sed
2064 6f20 6569 7573 6d6f   do eiusmo
6420 7465 6d70 6f72 2069  d tempor i
```

Start by laying out your intended output with `vip` and `:norm I0x00000000: `

```txt
0x00000000: 4c6f 7265 6d20 6970 7375  Lorem ipsu
0x00000000: 6d20 646f 6c6f 7220 7369  m dolor si
0x00000000: 7420 616d 6574 2c20 636f  t amet, co
0x00000000: 6e73 6563 7465 7475 7220  nsectetur 
0x00000000: 6164 6970 6973 6369 6e67  adipiscing
0x00000000: 2065 6c69 742c 2073 6564   elit, sed
0x00000000: 2064 6f20 6569 7573 6d6f   do eiusmo
0x00000000: 6420 7465 6d70 6f72 2069  d tempor i
```

Then `gv` (or `vip` again), `oj` to skip the first line, and `10g^A` to
increment each address a further 10, for each byte of the preceding line:

```txt
0x00000000: 4c6f 7265 6d20 6970 7375  Lorem ipsu
0x0000000a: 6d20 646f 6c6f 7220 7369  m dolor si
0x00000014: 7420 616d 6574 2c20 636f  t amet, co
0x0000001e: 6e73 6563 7465 7475 7220  nsectetur 
0x00000028: 6164 6970 6973 6369 6e67  adipiscing
0x00000032: 2065 6c69 742c 2073 6564   elit, sed
0x0000003c: 2064 6f20 6569 7573 6d6f   do eiusmo
0x00000046: 6420 7465 6d70 6f72 2069  d tempor i
```
{{ note(msg="I won't ever get _that_ algebraically nimble across all bases I ever encounter—but I don't need to") }}

## More practical examples

Piloting Vim's not just about some _quirky commands in isolation_ or some ideal
scenario where doing it some other way would actually give you some pause: the
ideal would be to **compose your mastery**, handle simple tasks _without any
struggle_, and ultimately have their presumed complexity be disintegrating as
you joyfully hack through your text.

In the following configuration snippet, say that you want to bump the `duration`
of some (or all?) animations by `100ms`.  Start by searching for `/duration`,
then simply use `100^A`: **that's `window-open` taken care of**.  Then press `n`
again to jump to each other available `duration` entry, interspersed with `.`
whenever one is due for a bump.  Done!

<div class="grid-1-2">
<div>

```kdl
animations {
    window-open {
        duration-ms 150
        curve "ease-out-expo"
    }
    window-close {
        duration-ms 200
        curve "ease-out-quad"
    }
    window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
    screenshot-ui-open {
        duration-ms 150
        curve "ease-out-quad"
    }
}
```
{{ note(msg="before you even really know what you want to do") }}
</div>
<div>

```kdl
animations {
    window-open {
        duration-ms 250
        curve "ease-out-expo"
    }
    window-close {
        duration-ms 300
        curve "ease-out-quad"
    }
    window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
    }
    screenshot-ui-open {
        duration-ms 250
        curve "ease-out-quad"
    }
}
```
{{ note(msg="by the time you've figured out what you want to do") }}
</div>
</div>

And hey, if you've worked out precisely what your end goal is, don't
shy away from the good old `:g` magic, `:g/duration/norm 100^A`!
Though you don't have to, [Vim will let you edit at the speed of
through](https://www.amazon.com/Practical-Vim-Edit-Speed-Thought/dp/1680501275),
no matter how much forethought, if any, went into your text-wrangling.

Don't really care for that padding? `vi{` to select inside the `{`...`}` block,
then `10^X` to nullify them all:

<div class="grid-1-2">
<div>

```kdl
padding {
    left 10
    right 10
    top 10
    bottom 10
}
```
{{ note(msg="1 second before") }}
</div>
<div>

```kdl
padding {
    left 0
    right 0
    top 0
    bottom 0
}
```
{{ note(msg="after `vi{10^X`") }}
</div>
</div>

And, just as a reminder: **you're in a terminal**.  You have access to
**everything else**, no plug-ins required!  Another way to "count from 4 to
52, 3 by 3" may very well be `:r!seq 4 3 52`.  Numbering stuff may sometimes
be best delegated to tools like `nl`—over which I go length in [that
article](@/flight-manual/numbering-lines.md).

<div class="grid-1-2">
<div>

```sh
seq 1 3 25
```
```txt
1
4
7
10
13
16
19
22
25
```
{{ note(msg="`seq` is worth a mention for sequence generation") }}
</div>
<div>

```sh
nl -s.\  -w1 <<EOF
Acquire food
Prepare food
Consume food
Process food
Sleep it off
Repeat
EOF
```
```txt
1. Acquire food
2. Prepare food
3. Consume food
4. Process food
5. Sleep it off
6. Repeat
```
{{ note(msg="You can just `!nl` in visual mode; `!ipnl` numbers your current paragraph, `:%!nl` your entire file") }}
</div>
</div>

## Expanding further with plug-ins

In spite of my (learned) distaste for plug-ins in general, a few here and
there do help a bit.  I'm sure you won't have any trouble finding tools
that extend Vim's `^A` and `^X`, but I'll bring your attention notably to
[`tpope/vim-speeddating`](https://github.com/tpope/vim-speeddating).  This
specific plug-in has two major advantages over many alternatives, in:

- dealing with the one case I actually do want manipulate with `^A`, `^X` (I
  don't need to bump semantic versions, hex colour codes, _et cet_...)
- being **done**: if you're sheepish about downloading and running code you
  don't know, you'll want to actually **review** the changes brought by
  each update of each of your plug-ins: `speeddating.vim` is **done—not
  _unmaintained_!**, which means that updates are few and far between.  What
  do you know, figuring out which date comes after `2026-03-10` is actually a
  solved problem[^programming-time].

[^programming-time]: Well, anything that has to do with programming time
manipulation is [certain to be
problematic](https://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time),
but for your general intents and purposes, we do know what comes after New
Year's Eve or what lurks right behind Sunday night.

That is indeed what it does: `speeddating.vim`, as its name playfully suggests,
lets you turn `1999-12-31` into `2000-01-01` with a single `^A`!  But you can
also just bump it down by months, or years, rather than days, and it'll do it
just right.

For instance, with your cursor on the **month** segment of `2026-03-31`, `^X`
will yield `2026-02-28`—there are only 28 days in February in 2028.  What's
100 days from any arbitrary date?  As easy as `100^A`.  Oh and, it understands
other formats...  Such as date and time in **`RFC 5322` format**, which `GNU`'s
`date` utility outputs with the `-R`/`--rfc-email` flag.

<div class="grid-1-2">
<div>

```sh
date --rfc-email --date 'next saturday 1500'
date -Rd'sat 3pm'
```
```txt
Sat, 14 Mar 2026 15:00:00 +0100
```
{{ note(msg="by the way, that's [`π` day](https://en.wikipedia.org/wiki/Pi_Day)! `3-14` at `15`") }}
</div>
<div>

```sh
date --iso-8601=seconds --date 'next saturday 1500'
date -Is -d'sat 3pm'
```
```txt
2026-03-14T15:00:00+01:00
```
{{ note(msg="works just as well with the `ISO 8601` formats") }}
</div>
</div>

With your cursor on `2026`, press `2^X` to get `π` day `2028`:

<div class="grid-1-2">
<div>

```txt
Tue, 14 Mar 2028 15:00:00 +0100
```
{{ note(msg="note the weekday changing from `Sat` to `Tue`!") }}
</div>
<div>

```txt
2028-03-14 15:00
2028-03-14
March 14th, 2028
```
{{ note(msg="and also these formats") }}
</div>
</div>

Then `B`-shimmy your way to `Mar` and let your partner believe you meant
[Valentine's Day](https://en.wikipedia.org/wiki/Valentine%27s_Day) all along, with a mere `^X`:

<div class="grid-1-2">
<div>

```txt
Mon, 14 Feb 2028 15:00:00 +0100
```
{{ note(msg="the weekday changed this time from `Tue` to `Mon`") }}
</div>
<div>

```txt
14-Feb-2028
2028 Feb 14
Feb 14, 2028
```
{{ note(msg="and also these") }}
</div>
</div>

[127 hours](https://en.wikipedia.org/wiki/127_Hours) later?  `/15`, `127^A`,
done:

<div class="grid-1-2">
<div>

```txt
Sat, 19 Feb 2028 22:00:00 +0100
```
{{ note(msg="by the same science, you could cram some 600-hour university course in precisely 25 days") }}
</div>
<div>

```txt
22:00:00AM
22:00AM
22AM
```
{{ note(msg="and even more, such as `MMXXVIII`") }}
</div>
</div>

> [!NOTE]
>
> To clarify, `speeddating.vim` supports a whopping **22 date and time formats
> of various sorts, built-in**, and lets you further define your own.  And quite
> many more ingenuous plug-ins are out there also building upon Vim's `^A` and
> `^X`'s semantics.  I go in depth and cover (about) everything pertaining
> to the Vim core incrementation prowess, but intend to do nothing more than
> scratch the surface of what exists out there.

I'd like to take this time to mention again: **extreme proficiency with the
"basic" tools routinely trumps familiarity with more extravagant, well-meaning,
specialised toys**; either way, it turns out we can still wrangle text faster
than the `LLM`s, and more precisely!

The main limiting factor is how dedicated you'll be to master your craft.  My
more certain advice to you goes as follows: whatever philosophies you'll dabble
in or embrace, make sure to **keep doing what you find to be fun**.  Cheers!
