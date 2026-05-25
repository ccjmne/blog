+++
title = 'The ancestry of `OSC` `133`: semantic prompts'
date = 2026-05-06
description = "From `ECMA-48`'s _Operating System Command_ to _Final Term_'s semantic prompt markers and the terminal emulation that interpret them"
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'ansi', 'zsh']
extra.cited_tools = ['tmux']
+++

Terminal emulators are nowadays making a habit of catering to the
litany of React-born posers, by bundling hundreds (really) of popular
colour schemes, touting `GPU` acceleration (ha!), support for
[ligatures](https://en.wikipedia.org/wiki/Ligature_(writing)), and more
such trifling frivolities that self-proclaimed _"technical bloggers"_ swoon
over[^the-coating].

[^the-coating]: Not that I refuse any sort of sugar on top!  But I rather like
such coating to come second to an impressively competent core.

However, there also are crafty people, communities and corporation coalescing
around some **solutions providing meaningful, savvy functionality**!  Today, I
want to talk of one such lovely affair: the semantic prompts <abbr title="Final
Term Control Sequence">`FTCS`</abbr> semantic prompts, which shall forever live
on in the `OSC` `133` namespace.

<!-- more -->

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

A set of escape sequences that your shell and terminal emulator recognise to
semantically annotate your interactive sessions to possibly implement additional
controls or contextual information:

<div class="grid-1-2">
<div>
<pre class="giallo z-code"><code data-lang="plain">ccjmne% <span class="term-fg32">seq</span> 1 5
1
2
3
4
5
</code></pre>
{{ note(msg="a plain old shell output, running `seq 1 5`") }}
</div>
<div>
<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">[PROMPT]</span>ccjmne% <span class="term-fg1">[COMMAND_START]</span><span class="term-fg32">seq</span> 1 5
<span class="term-fg1">[COMMAND_EXECUTED]</span>1
2
3
4
5
<span class="term-fg1">[COMMAND_FINISHED]</span></code></pre>
{{ note(msg="its annotated counterpart using `OSC` `133`") }}
</div>
</div>

> [!IMPORTANT]
>
> Note of course that the bits between square brackets correspond to `OSC`
> `133` sequences `A` through `D` and are **not actually visibly printed
> out**: they're only used—if at all—by your terminal emulator to leverage
> that insight into the semantics of its output and possibly offer additional
> functionality.

One may imagine having some hint as to the command corresponding to any output,
maybe some key bindings to jump from a prompt to the next, an _"execute again"_
button where it could make sense, some visual separation...  **The sky, your
imagination, and some good taste are the limits!**

Where `PROMPT`, `COMMAND_START`, `COMMAND_EXECUTED`, `COMMAND_FINISHED` all were
originally prefixed with `FTCS_`, for their lineage shall forever trace back to
the giant that is _Final Term_.

Under the hood, they're `OSC` escape sequences, implemented under the family
`133`: effectively, in the literature, we refer to these four as follows:

- `OSC 133 A BEL` is `FTCS_PROMPT`
- `OSC 133 B BEL` is `FTCS_COMMAND_START`
- `OSC 133 C BEL` is `FTCS_COMMAND_EXECUTED`
- `OSC 133 D BEL` is `FTCS_COMMAND_FINISHED`

With the `OSC` prefix being `ESC ]`, emitting them in your shell is therefore
as simple as:

```sh
echo "\e]133;A\a"
```
{{ note(msg="you may want to integrate that bit to your `$PS1`! but I won't cover that in this current article.") }}

Voilà!  Yes, it's a bit hand-wavy, but you were looking for a `TL;DR`, weren't
you?

<!-- Be sure to check out how to [Semantically annotate your shell prompt with `OSC` -->
<!-- `133` extensions](@/flashcards/osc133-aware-prompt.md), for some practical (and -->
<!-- digestible) use-case to these signals. -->
<!-- TODO: LINKME -->

</div>

## Semantic prompts

Terminal emulators have long been in the business of pretending to not know what
they very much should.  They show you a shell prompt, then your command, then
its output, then another prompt; yet, without a bit of help, they are liable to
**treat the whole affair as an undifferentiated soup of bytes with line breaks
in more or less fortunate places**.

That is where some _Final Term_ Control Sequences (abbreviated `FTCS` in [its
code base](https://github.com/p-e-w/finalterm/blob/f46ffd03e9b1ad5d7ce4b18b429f6e0a4bc15f3e/src/TerminalStream.vala#L541-L549)) enter the stage:
among other things, what shall pique our interest today is the family of control
sequences through which a shell may **inform a supporting terminal emulator
where a prompt begins, where the editable command line begins, where execution
begins, and where a command ends**.

> [!IMPORTANT]
>
> _Final Term_ was a popular terminal emulator
> that brought about some great ideas.  [It it now
> discontinued](https://worldwidemann.com/finally-terminated/), but its
> legacy lives on in, informally, _iTerm2_[^iterm-not-apple] heralding its
> "continuation", and in some ways everywhere that integrates their idea in
> what's effectively an ever-growing de-facto specification.

[^iterm-not-apple]: Unlike what its name might suggest to you nowadays, `iTerm2`
is not affiliated with Apple.  It is using that naming scheme only because, a
while ago in the 2000s, the success of Apple products (`iMac`, `iPod`, `iTunes`,
_et cet._) was such that embracing their naming scheme may reasonably give a
most desirable extra flair of modernity and tech-savviness to one's offerings.

As you would gather from the source code shared above or from _iTerm2_'s
documentation on the matter, these sequences that I will bundle under the
_"semantic prompt"_ umbrella **are implemented as extensions to the <abbr
title="Operating System Command">`OSC`</abbr> family**, most specifically under
the code `133`.

The result is that a terminal may stop guessing and start **knowing** where the
bits and pieces that comprise its displaying output begin and end: that protocol
is generally referred to as `OSC` `133`.

## What `OSC` is in the first place

Colloquially, people say _"escape code"_ for the whole lot.  Strictly speaking,
we are usually dealing with **escape sequences** or, more broadly, terminal
control sequences.  They are called that because they often begin with the `ESC`
byte (`0x1B` in hexadecimal, `033` in octal or `27` in decimal), which tells the
terminal that **what follows is not plain text to display**.

<!-- [all about escape codes](@/flight-manual/all-about-escape-codes.md). TODO: LINKME -->

> [!NOTE]
>
> The formal (and original) home for this world is
> [`ECMA-48`](https://ecma-international.org/wp-content/uploads/ECMA-48_5th_edition_june_1991.pdf):
> <abbr title="European Computer Manufacturers Association">`ECMA`</abbr>
> but it was also adopted by <abbr title="International
> Organization for Standardization">`ISO`</abbr> at
> [`ISO-6429`](https://www.iso.org/obp/ui/en/#iso:std:iso-iec:6429:ed-3:v1:en),
> by <abbr title="American National Standards Institute">`ANSI`</abbr> at
> [`ANSI x3.64`](https://shuford.invisible-island.net/ansi_x3_64.txt)...  And
> surely other places; good luck keeping track of all the appendices: I haven't
> attempted to.

Among the things `ECMA-48` standardises are several families of control
functions:

- `CSI`, the **Control Sequence Introducer**, introduced by `ESC [`
- `OSC`, the **Operating System Command**, introduced by `ESC ]`
- `DCS`, the **Device Control String**, introduced by `ESC P`
- ... and then some: I am being somewhat less exhaustive than is usually _de
  rigueur_ for me, in the interest of keeping our eyes on the ball for once.

The standard definition of `OSC` is intentionally general: it opens a string
for an _operating system command_, terminated by `ST`, while the meaning of the
string's payload is left to the implementation.

> [!TIP]
>
> **`ST` itself just stands for _"String Terminator"_ and is specified to
> correspond to the escape sequence `ESC \`**: that is, the two bytes `0x1B` and
> `0x9C`.  However, for historical reasons, within `OSC` specifically, `BEL`
> (`ASCII` `0x07`) is also a valid termination signal.
>
> Well, the historical reasons aren't all that complicated: `XTerm` is the
> terminal that incepted, implemented support for, and consequently popularised
> most of these sequences a while back, and they simply chose to use `BEL` as
> that signal then.
>
> I haven't found—nor looked for—any corroborating evidence to the following
> hypothesis, but I like to imagine that **it lovingly may have had to do with
> the [mechanical typewriters](https://en.wikipedia.org/wiki/Typewriter) ringing
> a physical bell when the carriage (just about) reaches the end of its track**.

### Notation, notation notation

The [real estate
cliché](https://en.wikipedia.org/wiki/Location,_Location,_Location) is almost
right!  We need to take a short detour to establish some common interpretation
baseline for the grammar we'll use in describing escape sequences going
forward—because yes, _it gets much murkier skill_.

The lot of us use many, very many, vastly different notations for all
sort of sequences; I promise to come back and write something up on the
matter, but for now, I'll settle on the one that is most easy to communicate
about[^escape-sequence-notation].

[^escape-sequence-notation]: The escape sequence notation I use here **is very
readable in prose**, but I still find it wildly inappropriate for technical
communication and possibly instructional content, for being too informal, vague,
and assuming on perhaps too much underlying understanding on the part of the
reader.

Consider this example: I just mentioned that `CSI`, `OSC` and `DCS` are
introduced by `ESC [`, `ESC ]` and `ESP P`, respectively.

When I write `ESC [`, I mean two bytes: `0x1B` (`ESC`) and `0x5B`, a literal `[`
in `ASCII`—see `man 7 ascii`.

> [!IMPORTANT]
>
> These are assuming a **7-bit C1** control schemes, historically most
> prominent, and still the standard today; though with the **notable limitations
> of possibly representing several key combinations as the same encoding, not
> being able to represent `Ctrl`-`Shift`-`<Anything>`**, and perhaps more
> capricious behaviours we all generally internalise and stick with nonetheless,
> for **compatibility with the whole software stack to back when bytes were
> 7-bit long**—you read that right[^7-bit-bytes].
>
> If the topic comes up again, I will be sure to write an article here; in the
> meantime, you will find a lot of adequate information on Wikipedia's [`C0` and
> `C1` control codes](https://en.wikipedia.org/wiki/C0_and_C1_control_codes)
> page.

[^7-bit-bytes]: **Yep, bytes used to be generally 7-bit long**.  And 6-bit,
    too!  Software bytes, that is; hardware ones used to be of variable
    length.  How quaint!  Well, you might be might be quite surprised to know
    we haven't entirely moved on; at least not in a way that wouldn't be
    backwards-compatible.

    There is much to say about how shrewdly we packed things there then, and
    how intelligently we built upon and integrated that venerable space to the
    loftier 8-bit that seems impossible to dethrone circa 2026.  The whole
    `ASCII`, then `ANSI`, then `UTF-8` stack is a marvel of savviness and
    simplistic design that fully, efficiently and seamlessly extends the most
    picturesque and primeval data encodings of our forefathers.

Note also that several of the most ubiquitous the `ASCII` non-printable
characters have their own backslash-code in `C`—and, due to the overwhelming
prevalence of that language, virtually everywhere else:

- `\0` is the "null" character, `0x00`, `0` in decimal,
- `\n` is the linefeed, "new line", `0x0A`, `10` in decimal,
- `\a` is the bell, `0x07`, `7` in decimal; making your terminal "print it"
  would play an audible beep;
- `\e` is escape, "`ESC`", `0x1B`, `27` in decimal—though I do not find it
  in the ASCII manual, I have been around enough to certify that it is fairly
  widely recognised and interpreted in such manner)

As such, you may come across any and all of the following reasonable notations
to describe, for instance, `OSC` `133` `A`:

- `ESC ] 133 ; A BEL`, the most popular still, and most technically accurate;
- `OSC 133 ; A BEL`, using the well-established `OSC` family prefix for those in
  the loop;
- `ESC ] 133 ; A ST`, the (would-be?) "standard" notation; and
- `OSC 133 ; A ST`, my least favourite, despite being possibly the one most _by
  the book_.

However, **these above are only for prose**, when people talk to each other to
discuss these specifications.  In reality, in `C` (and consequently, a
staggering number of places), you're bound to rather run into the following forms:

                     ESC   ]  133  ;  A  ST-or-BEL
    =======================================================
          octal      \033  ]  133  ;  A  \033\\         ST
          octal      \033  ]  133  ;  A  \07            BEL
    hexadecimal      \x1B  ]  133  ;  A  \x1B\\         ST
    hexadecimal      \x1B  ]  133  ;  A  \x07           BEL
        C-style      \e    ]  133  ;  A  \e\\           ST
        C-style      \e    ]  133  ;  A  \a             BEL

> [!NOTE]
>
> These of course won't present all the whitespace I used for that table above,
> they'll instead be: `\033]133;A\07`, `\x1B]133;A\x07`, `\e]133;A\a`...

Well, I have also seen the abominable mismatch between the notation style of
`ESC` and `ST`, which means that **you could run into any of no less than 18
(EIGHTEEN!) effective notations** in shell scripts, `C` code, _et cet._

I am sure there are other ways—certainly through the use of variables if
nothing else; but **these are the reasonable, `C`-style ones that every piece of
technical implementation out there is more or less certain to eventually distil
down to**.

> [!TIP]
>
> There's also one additional popular and reasonable notation, the **caret
> notation**, which is most notably found delectable by Emacs and Vim users.
> Ah, how quaint: you'd think both would cover the entire software developer
> population; but alas, not any longer.
>
> That notation shall deserve a lot more care; so I'll defer to writing at a
> later time about its origins, and its **direct translation into most practical
> application in sending all sorts of signals to your terminal while holding
> `Ctrl`**.  Hold me to it!
>
> In the meantime, know that `^[` also represents `ESC`, making `CSI`
> effectively `^[[` and `OSC` be `^[]`.

<!-- [caret-notation-ctrl-bindings-ascii-equivalence](@/flight-manual/caret-notation-ctrl-bindings-ascii-equivalence.md). TODO: LINKME -->

### Why not `CSI`, `DCS`, or something else?

Rather than exhaust all the other existing families of escape sequences,
documented and otherwise, ubiquitous, popular and obscure alike, I'll take
this opportunity to **only give you some (learned) intuition for the effective
purpose of the two main "buckets", `CSI` and `OSC`**.

Beyond these practicalities, the actual, theoretical distinction between the two
`CSI` and `OSC` classes of escape sequences generally is that **`CSI` presumes
to control the shell itself**, what it should draw, where, and in what manner,
**whereas `OSC` is intended to rather integrate with the outer system**, in
providing contextual information such as the name of the foreground utility,
the current work directory, possibly some progress report...

The pragmatism is that `OSC` sequences are in principle **never a unilateral
implementation: the shell provides some data, which the terminal emulator may or
may not interpret** so as to augment to end-user experience.

> [!NOTE]
>
> A criticism that [HashiCorp's very Mitchell
> Hashimoto](https://en.wikipedia.org/wiki/HashiCorp) notably makes of the most
> savvy [`tmux`](https://en.wikipedia.org/wiki/Tmux) in sharing his vision
> for the future of [Ghostty](https://ghostty.org/), is that the multiplexer
> effectively presents an extra layer of "terminal emulation", requiring the
> `OSC`-like features to be implemented and perhaps configured in tandem at no
> less than three operational levels at once.
>
> It's not wrong, but for me, the buck currently stops at `tmux` itself!

<!-- [tmux-or-not-tmux](@/flight-manual/tmux-or-not-tmux.md). TODO: LINKME -->

Note that **it may also go the other way around**, there the terminal emulator
may, for instance, push some escape sequences into the shell to report, say,
that the application focus was gained or lost, that the desktop theme was
toggled between light and dark, _et cet._

**That difference is what makes `OSC` most apt for semantically annotating the
prompts**: the shell itself needn't concern itself with this, but the terminal
emulator very well might—as we'll exemplify soon after.

### The disinterested layperson's rule of thumb

**These two also generally look quite different in their payload**.  What
follows doesn't answer the question, whose most adequate answer I just laid out,
but various sources lead me to believe that, however laughably moot, this more
or less constitutes the layman's rule of thumb: I shall not ignore it.

`CSI` sequences, introduced with `ESC [`, are the terse, parametrised commands
most of us first meet through colour and cursor movement:

- `ESC [ 31 m` will start using a red foreground for printing text,
- `ESC [ ? 25 l` will hide the cursor and `CSI ? 25 h` will restore it,
- `ESC [ 0 J` will clear from the cursor **_down_ to the _end_** of the screen,
  `1 J` from the cursor **_up_ to the _beginning_** of the screen, `2 J` to
  clear the entire screen, `3 J` to clear the entire screen _as well as the
  entirety of the scroll-back buffer_...

They end with a final command byte, such as `m`, `J`, or `H`: `ESC [ 31 m` is
essentially read as `CSI 31 m`; where `31` means "red foreground"—you will
find much information about all the terminal colour gymnastics by searching for
`SGR`, _"Select Graphic Rendition"_; the more palatable name for the `CSI <x> m`
control sequence.

By contrast, `OSC` sequences are generally more _"string-like"_.  They open with
`ESC ]`, carry a piece of text-like payload, and run until `ST` or, as we'll
explore later, most commonly yet-least-authoritatively-documented, `BEL`.  For
example,

- `OSC 0` can set your window title,
- `OSC 8` will indicate hyperlinks,
- `OSC 52` can manipulate your clipboard...

These originally were mostly the creation of `XTerm`, but have been adopted and
extended time and again.

## Whence `133`

`OSC` `133` did not come from `ECMA-48`, from `XTerm`, nor from `DEC`'s
old terminal manuals.  The family was introduced by [Philipp Emanuel
Weidmann](https://worldwidemann.com/about/) for _Final Term_, the ambitious
emulator that pioneered making the terminal understand what was going on instead
of merely drawing it.

Neither I, **nor any of the indexed Web as to mid-2026 has any clue as to the
significance (if any) of `133`** being the command number that _Final Term_
mapped their "semantic prompt" control sequences to within the `OSC` domain.
Not that it's of any concern to anybody: it just needs not to conflict with any
other reasonably popular sequence.

## A glimpse into the `OSC` `133` family

But the source code is still available, and there in the
[Vala](https://vala.dev/)[^vala] source lies the plainest surviving statement of
the thing:

[^vala]: Programming language bringing object-oriented syntax to `C`, which it
"simply" transpiles down to.

```vala
// Final Term control sequences (note that these are actually OSC sequences)
add_final_term_sequence_pattern(ControlSequenceType.FTCS_PROMPT,           "A");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_COMMAND_START,    "B");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_COMMAND_EXECUTED, "C");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_COMMAND_FINISHED, "D");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_TEXT_MENU_START,  "E");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_TEXT_MENU_END,    "F");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_PROGRESS,         "G");
add_final_term_sequence_pattern(ControlSequenceType.FTCS_EXECUTE_COMMANDS, "H");
```
{{ note(msg="from [`TerminalStream.vala`, lines `541` through `549`](https://github.com/p-e-w/finalterm/blob/master/src/TerminalStream.vala#L541-L549); though the vertical alignment is mine") }}

> [!NOTE]
>
> This whole document is rather lovingly curated, this is homely and savvy, I'm
> grateful for such pieces.

If you want the names' semantics corroborated by behaviour rather than by
names alone, `FinalTerm`'s output handling makes that explicit, too, at
[`TerminalOutput.vala`, lines `375` through
`461`](https://github.com/p-e-w/finalterm/blob/master/src/TerminalOutput.vala#L375-L461)

The spirit of the project did not vanish entirely with the terminal itself.  As
far as prompt markers are concerned, a small and excellent piece of _Final Term_'s
legacy lives on in _iTerm2_, whose documentation explicitly preserves and
attributes the `A`-through-`D` scheme to _Final Term_:

> The goal of the _Final Term_ escape sequences is to mark up a shell's
> output with semantic information about where the prompt begins, where the
> user-entered command begins, and where the command's output begins and ends.
>
> {% attribution() %} _iTerm2_, on its supported [Proprietary Escape Codes](https://iterm2.com/documentation-escape-codes.html) {% end %}

This documentation puts together quite well some visual `TL;DR` of "what goes
where":

<pre class="giallo z-code"><code data-lang="plain"><span class="term-fg1">[PROMPT]</span>ccjmne% <span class="term-fg1">[COMMAND_START]</span><span class="term-fg34">ls</span> <span class="term-fg32">-l</span>
<span class="term-fg1">[COMMAND_EXECUTED]</span>-rw-r--r-- 1 ccjmne ccjmne 111 May 10 02:47 file
<span class="term-fg1">[COMMAND_FINISHED]</span></code></pre>
{{ note(msg="the bits between square brackets correspond to `OSC` `133` `A` through `D` and are not actually visible") }}

In practice, the enduring part of the scheme is overwhelmingly these first four.
They are those I meant to write about; this article is the result of a mere
introductory distraction to that (surely forthcoming) other.

As for prestidigitation, I believe that the ingenuity in how the machinery is
put together is just as marvellous as the resulting theatrics: I'm sure that
even this will have some value for posterity.  Cheers!
