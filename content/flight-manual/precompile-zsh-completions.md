+++
title = 'Pre-compile your Zsh completions'
date = 2026-04-12
description = 'Shave off `10ms` here and there, and you will soon arrive at a responsive shell experience'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'quibblery', 'zsh']
extra.cited_tools = ['zsh']
+++

I live in the terminal, and I'm quite a fine of my multiplexer of choice,
`tmux`.  As a result, I spawn _Zsh_ sessions, both interactive and
non-interactive, a great many times per day: I want to **request a shell and
start typing in the same breath**, before my puny <abbr title="the human element
of my set-up">mammalian system</abbr> has even had time to confirm the system is
ready.

If my session is interactive, I want access to all my tools, with all the
bells and whistles, with the comprehensive completion system for every single
tool I use—and then some; with all my custom bindings and what-have-yous.
**And I shall tolerate no perceptible hiccup or hesitation from the machine
that does my bidding: `32ms` is its budget** to be fully responsive,
including having a prompt showing me the current status of my gigantic Git
[monorepo](https://en.wikipedia.org/wiki/Monorepo) that takes well over 10 times
that long to report on its status.

Is that remotely realistic?  It sure is!  Let's look into loading up absolutely
all the completions that are available, **in less than 16ms**, to satisfy even
those of us that dwell on the `CLI` with enough agility to perceive—and be
bothered by—the machine stuttering when readying to bend over backwards for
our most acrobatic antics.

> [!NOTE]
>
> A vastly more digestible [introduction to providing completions for the _Z
> Shell_](@/flashcards/provide-zsh-completions.md) is available, would you need
> to whet your appetite for this exercise.

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

Run the following asynchronously, once in a while, and/or when you install new
software:

```sh
#! /usr/bin/env zsh

readonly dumpfile=$ZDOTDIR/.zcompdump
readonly compdir=$XDG_DATA_HOME/zsh/site-functions

mkdir -p $compdir
rm -- $compdir/*

niri completions zsh    > $compdir/_niri
opencode completion zsh > $compdir/_opencode  # have even that one, if you want!

fpath+=($compdir)
[ -f $dumpfile ] && rm -- $dumpfile
autoload -U compinit && compinit -d $dumpfile
```
{{ note(msg="I automatically run this script once a day, with a `systemd` timer") }}

Retain only this in your in your `.zshrc`.

```sh
typeset -U fpath
fpath+=($XDG_DATA_HOME/zsh/site-functions)
autoload -U compinit && compinit -C
```
{{ note(msg="`typeset -U` ensures that there may be no duplicate in your `$fpath`") }}

> [!IMPORTANT]
>
> I assume here that you've set `ZDOTDIR` and `XDG_DATA_HOME` explicitly and
> aptly—that is, in your `.zshenv` or _"earlier"_.  Not having provided
> fall-backs here isn't for any lack of skill or consideration on my end; the
> same observation goes for the absence of double-quotes surrounding expanding
> bits.
>
> Consider this: be deliberate, vigilant and sure of yourself, and you get to
> write `rm -- $compdir/*` instead of the poorer `rm "$compdir"/*`.

With the above set-up, you'll get a new interactive _Zsh_ session, **with all
the completions available for all your tools**, ready, willing and able to
serve, **well within `16ms` of having requested it**.

</div>

<div style="display: none"> <!-- TODO: make into series introduction? -->

I use the **[Z shell, _Zsh_](https://www.zsh.org/)**.  Before using it, I'd
acquired some reasonable familiarity with the <abbr title="Portable Operating
System Interface">`POSIX`</abbr> shell specification, and the **Bourne-Again
Shell, _Bash_**.  It’s been years since I last pair-programmed extensively
with someone who wasn't surprised that many of these agile _"tricks"_ are built
right into the plain (albeit _Bourne-Again_) shell.  Yet, certainly not due
to more, newer or better tools—you and I do wield (though perhaps not quite
_use_) the same ones after all—**my best wizardry is mostly the product
of a unique balance of <abbr title="self-discipline">asceticism</abbr> and
aestheticism**[^ascetic-and-aesthetic].

<!-- [bash history expansion](@/flight-manual/bash-history-expansion). TODO: LINKME -->
<!-- [ascetic-and-aesthetic](@/flight-manual/ascetic-and-aesthetic). TODO: LINKME -->

[^ascetic-and-aesthetic]:  **Asceticism** is the self-discipline and avoidance
of indulgence, typically for religious reasons.  According to Wikipedia,

    > Ascetics maintain that self-imposed constraints bring them greater freedom
    > in various areas of their lives, such as increased clarity of thought and
    > the ability to resist potentially destructive temptations.

    **Aestheticism**, on the other hand, I would best distil in the creed:
    _"L'Art pour l'Art"_, which translates from French to _"Art for art's
    sake"_.

    I embrace the paradox and consider myself an **ascetic aesthete**.

**The most competent of us already built some most competent tools**, it is
now up to the most punctilious of us to <abbr title="Read The F... riendly
Manual">`RTFM`</abbr> justify having _Zsh_ in our toolbox with arguments more
elaborate than _"idk, i liked the colours"_.<br>

<!-- [RTFM](@/flight-manual/read-the-friendly-manual). TODO: LINKME -->
</div>

## Loading completions modules

We use quite a few tools.  We master them, of course; but on the way to such
mastery (and on the recurring occasions you feel like `<Tab>`-ing away the rest
of your word), having access to the completion system integrated to _Zsh_ is
quite nifty.

The tools best bundled for your operating system would likely drop **the
adequate configuration in all the adequate places**, but those whose
packagers are less articulate (that is, generally anything on the infamous
[`AUR`](https://aur.archlinux.org/), and then some!)

> [!TIP]
>
> The _"adequate places"_ would likely be `/usr/share/zsh/site-functions`, but
> you'll be best served by `man zshmodules`, specifically its _`THE ZSH`/`NEWUSER
> MODULE`_ section, for a most accurate, comprehensive and up-to-date description.
>
> For example, the packagers of `yazi-git` on the `AUR`
>
> ```sh
> package() {
>   # ...
>   cd "$srcdir/$_pkgsrc/yazi-cli/completions"
>   install -Dm644 "ya.bash"    "$pkgdir/usr/share/bash-completion/completions/ya"
>   install -Dm644 "ya.fish" -t "$pkgdir/usr/share/fish/vendor_completions.d/"
>   install -Dm644 "_ya"     -t "$pkgdir/usr/share/zsh/site-functions/"
> }
> ```
> {{ note(msg="an excerpt from `yazi-git`'s [`PKGBUILD`](https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yazi-git), installing completion functions for `Bash`, `Fish` and `Zsh`") }}

However, some others are less well-packaged, and I've been increasingly coming across
instructions comparable to that one:

```sh
source <(niri completions zsh)
```
{{ note(msg="now the most excellent [`niri`](https://github.com/niri-wm/niri) suggests to load completion for its `CLI`") }}

That'll work!  But it'll make your shell (in the case of `niri`'s) _an extra
`~10` millisecond slower_ to become interactive.  Add a couple more of these,
and **you're looking at `100ms` simply for the completions**; and just like
that, you can actually _feel_ the little bit of delay when you go about your
most acrobatic <abbr title="Command Line Interface, where I dwell">`CLI`</abbr>
life, such as binding, say, some `tmux` binding that opens a new interactive
shell, starts typing up some command, and switches to `vi` mode to put your
cursor where you want it, right bang in the middle of the said "template".

Yes, I do do that—and then some; and yes, seeing the whole shebang stutter for
`~150ms` did use to be quite unnerving.

Especially when you know that you could have your cake and eat it too: **loading
completions doesn't have to take that long.**

## The anatomy of a `compdef` file

To put it in a nutshell, _Zsh_ is entirely capable of invoking the completions
you need **at the time you use the corresponding commands**!  It just needs to
know that such completions are available, and where to find them.

Let's conjure up `gerp` (`grep` + <abbr title="A foolish or ignorant
person">_derp_</abbr>!), a lovely virtual companion that never fails to greet
you enthusiastically:

```sh,name=gerp
#! /bin/sh

case "$1" in
	hello)       echo 'Henlo, fren!' ;;
	completions) cat                 ;;
	*)           echo '?'            ;;
esac <<'EOF'
#compdef gerp
_gerp() {
    _values 'commands' hello completions
}
if [[ "$funcstack[1]" = "_gerp" ]]; then
    _gerp "$@"
else
    compdef _gerp gerp
fi
EOF
```

> [!TIP]
>
> If you want to follow along, just put that script on your `$PATH` (or, in a
> more _Zsh_-literate way, your `$path`), and `chmod u+x` it.

It exposes two commands: `gerp hello` will echo `Henlo, fren!`, and `gerp
completions` will output a completion script suitable for _Zsh_.

Here's its precise output, duly highlighted for our convenience:

```sh
#compdef gerp
_gerp() {
    _values 'commands' hello completions
}
if [[ "$funcstack[1]" = "_gerp" ]]; then
    _gerp "$@"
else
    compdef _gerp gerp
fi
```

### And exhaustive walk-through

Let's go over what it does, in an order that makes sense to me:

1.  ```sh
    compdef _gerp gerp`
    ```

    `compdef` is a registration function built into _Zsh_'s completion system,
    oft abbreviated `compsys`—on that note, you might find its manual at
    `zshcompsys` to be quite handy!  Here, we're merely instructing the system
    to call the Zsh function named `_gerp` to generate completion arguments
    whenever the user is requesting them (typically, by pressing `<Tab>` in a
    `gerp` command).

2.  ```sh
    #compdef gerp`
    ```

    This _"magic comment"_ at the top essentially some flag that the `compsys`
    will, when found at the beginning of a script, interpret as: _"use this here
    script to get completion arguments for the `gerp` utility"_.

    In essence, when you run `compinit` to kick-start the completion system
    (which you likely already do in `.zshrc` or through some plug-ins, like _Oh
    My Zsh_), the `compsys` scans every file in your `$fpath` directories and
    looks specifically for this marker.

    Virtually, it's a way to organise your files in such a way to automatically
    wire all sorts of `compdef _gerp gerp`!

3.  ```sh
    _gerp() {
        _values 'commands' hello completions
    }
    ```

    This function is invoked when you ask for completions, and needs to be
    wired by the `compsys` so as to reply when `gerp` completions are required.
    Here is the absolute simplest usage of it, but know that you can **group
    entries**, document them, _et cet_.  For instance, here's how to add some
    some description of what each subcommand does:

    ```sh
    _values 'commands'              \
            'hello[greet the user]' \
            'completions[generate shell completions]'
    ```

    It can work asynchronously, of course...  Oh yeah, I saw that sparkle in
    your eyes: yep, it is **that simple** and yep, the world is your oyster!

4.  ```sh
    if [[ "$funcstack[1]" = "_gerp" ]]; then
        _gerp "$@"
    else
        compdef _gerp gerp
    fi
    ```

    And to tie it all up, the final bit.  That one looks quite shifty, I have to
    admit...  But it's actually **the standard dual-mode pattern for modern CLI
    tools that generate Zsh completion**.

    - Case `A`: When this script is found on your `$fpath` and loaded via
    `compinit` (the normal `#compdef` path), **none of this script is
    executed**, that file is merely scanned for its first line, which is
    interpreted and wired for later use.

    - Case `B`: When you `source` the file directory, using the lovely `source
    <(gerp completions)` Bashism[^process-substitution], **`funcstack[1]` is not
    `_gerp` and we fall to the branch that merely runs `compdef _gerp gerp`**.
    It's manually doing the equivalent to the auto-discovery mechanism that
    placing `_gerp` file in the right place with its _"magic comment"_ would.

    In both cases, the end goal of the "first pass" is merely to hook in `_gerp`
    as the provider for completions to the `gerp` utility.

    At a later time, whenever you request completions for `gerp`, _Zsh_ will
    either:

    - following the case `A`, end up sourcing `_gerp` **in the context of an
    internal function we don't see that's also called `_gerp`**, `funcstack[1]`
    is exactly `_gerp`, we pass the test and enter the positive branch,
    invoking: `_gerp "$@"`.

    - or, following the case `B`, directly invoke the `_gerp` function we
    defined and _"manually"_ targeted with `compdef _gerp gerp`.

    In both cases, it's that final "inner" `_gerp` function that **executes the
    completion logic**.

    > [!NOTE]
    >
    > It seems (and possibly is) quite complicated, but if you disregard
    > going through the mental gymnastics of how the sausage is made, and
    > consider that **we're here attempting to support two completely different
    > set-ups**, these very short final `if`-block really isn't too bad.
    >
    > I still admit that its main quality is likely that of being well
    > established and recognisable: you needn't think too much to know what it
    > does, when you expect it where you find it.

[^process-substitution]: The lovely Bashism `source <(gerp completions)` could
    be changed into the `POSIX`-compliant equivalent `eval "$(gerp
    completions)"`.  In short, these three are functionally equivalent, the
    first one is most portable, the last one is most elegant: be sure to read
    the following tip to help you decide for the case in point!

    ```sh
    eval "$(gerp completions)"    # full POSIX
    . <(gerp completions)         # <(...) is a Bashism
    source <(gerp completions)    # <(...) and source are Bashisms
    ```
    {{ note(msg="note that `.` is the only `POSIX`-defined `source`-ing mechanism!") }}

    > [!TIP]
    >
    > I generally maximise `POSIX` compliance where it matters, and sometimes
    > even where it doesn't; but **in the context of loading completions for
    > your _Z Shell_ specifically**, then it makes absolutely no sense to be
    > wary of how portable that procedure would be: **it only needs to work for
    > _Zsh_**.

    Embrace the process substitution!

## See for yourself

So, really, this simple file not only could serve as some fairly basic
[Tamagotchi](https://en.wikipedia.org/wiki/Tamagotchi), but it also serves up
instructions to be most conveniently served to you dynamically through your
completion system?!  And you can either pre-compile and auto-discover, or
manually and punctually source them?!  **_Yes sirree_, that's what ~15 lines of
shell script do for you.**

```sh,name=gerp
#! /bin/sh

case "$1" in
	hello)       echo 'Henlo, fren!' ;;
	completions) cat                 ;;
	*)           echo '?'            ;;
esac <<'EOF'
#compdef gerp
_gerp() {
    _values 'commands' hello completions
}
if [[ "$funcstack[1]" = "_gerp" ]]; then
    _gerp "$@"
else
    compdef _gerp gerp
fi
EOF
```

Save this file somewhere on your `$PATH`, make it executable (`chmod u+x
gerp`), and enter a new, fresh _Zsh_ session unburdened by whatever your
`.zshrc` usually contains (I do love a [reproducible, minimal, isolated
demonstration](@/flashcards/reproducible-isolated-demonstration.md)):

```sh
mkdir -p  $HOME/bin/
mv gerp   $HOME/bin/
chmod u+x $HOME/bin/gerp
```
{{ note(msg="install `gerp`") }}

In the above, I assume that you have somehow created `gerp` in your <abbr
title="Current Work Directory">`CWD`</abbr>.

```sh
path+=($HOME/bin/)
gerp hello
```
```txt
Henlo, fren!
```
```sh
gerp completions
```
```txt
#compdef gerp
_gerp() {
    _values 'commands' hello completions
}
if [[ "$funcstack[1]" = "_gerp" ]]; then
    _gerp "$@"
else
    compdef _gerp gerp
fi

```
{{ note(msg="for an isolated, reproducible configurations, run this inside `zsh -f`") }}

Alright, that's step one: the tool does work.  How about completions?

```sh
source <(gerp completions)
gerp   # press <Tab> here to request completion items
```
```txt
completions hello
```
{{ note(msg="it's **that simple**") }}

Well, I'll be damned, looks like we're done!  Except that, in principle,
invoking `gerp completions` every time you open up any shell is somewhat
wasteful.

## Pre-compile all the things

The _"problem"_ with `source <(gerp completions)` is that it takes a while.
Well, it doesn't take that much of a while, but still, it takes somewhat of a
while.  In reality, more complex tools (I believe they exist) may even take
longer to finish yielding that completion configuration.

In my experience, we're talking ~6 to 10 milliseconds per utility, which isn't
that all bad; but we can do away with essentially **all of it**, which may
somewhat add up.

Oh, and also, there are abhorrent monstrosities, such as:

```sh
source <(opencode completion)
```
{{ note(msg="looks quite innocuous, doesn't it?  avert your eyes, ye faint of heart, for we're about to run it") }}

> [!CAUTION]
>
> This looks just like my `gerp completions`, but functions quite differently
> by at least one metric: **IT TAKES 1.2 SECONDS!!** to yield the completion
> configuration.  And no, their completion system isn't meaningfully more
> complex than this: they simply spin up an abominable machinery to yield the
> most mundane of output. than that of `gerp`.  **Only ONE THOUSAND TIMES
> slower**.  Ah, the advent of `LLM`-driven programming.
>
> The punctilious among us do notice a difference.

Anyhow, I digress.  From here, we have four options:

1. stop using software built by people of questionable scrutiny and excellence,
   or
2. fix their software for them, or
3. just suffer through it, or give in and stop building and
   using software altogether; maximise [_platform decay_ (a.k.a.
   _"enshittification"_)](https://en.wikipedia.org/wiki/Enshittification) and
   vibe-code your way to 10k GitHub stars (but none from my side), or
4. pre-compile their completion system asynchronously and live your best life.

**I'll only consider option `#4` in this article**, although I'm also known to
have put `#2` in practice.

> [!NOTE]
>
> I was wildly exaggerating by suggesting than every competent tool maintainer
> is to be most comfortable with the _less-than-obvious features_ of the several
> environments their utility will integrate with.  Moreover, how do we suppose
> those that did acquire such refinement arrived there?  It wasn't innate,
> I can tell you that much.  Help out, contribute; this is [the way of the
> bazaar](https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar).
>
> In fact, while writing this article, I paused to submit a [Pull Request to
> `kong-completion`](https://github.com/jotaen/kong-completion/pull/15) to
> implement support for the _"pre-compiled"_/_"dual-mode"_ pattern we went over
> just before.

So, here we go, the proof is in the pudding, isn't it?  You can follow along and
try out that auto-discovery set-up mechanism on your end as well:

```sh
mv gerp $HOME/bin/                  # install gerp
path+=($HOME/bin/)                  # make gerp discoverable

gerp completions > $HOME/bin/_gerp  # pre-compile completions for gerp
fpath+=($HOME/bin/)                 # make gerp completions discoverable

autoload -U compinit                # make the compsys system available
compinit -i                         # and kick it off
````
{{ note(msg="just like before, for an isolated, reproducible configuration, run this inside `zsh -f`") }}

Note that you may want to use the `-i` flag if you picked a dubious directory or
did anything else somewhat curious with that file we just generated.

> For security reasons, `compinit` also checks if the completion system would
> use files not owned by root or by the current user, or files in directories
> that are world- or group-writable or that are not owned by `root` or by the
> current user. [...] ignore all insecure files and directories use the option
> `-i`.
>
> {% attribution() %} `man zshcompsys`, _Use of compinit_ {% end %}

The point would be to actually do this in two separate steps:

<div class="grid-1-2">
<div>

```sh
gerp completions > $HOME/bin/_gerp
fpath+=($HOME/bin/)
```
{{ note(msg="generate your completions **once** (or once in a while)") }}
</div>
<div>

```sh
fpath+=($HOME/bin/)
autoload -U compinit
compinit -i
```
{{ note(msg="load the pre-compiled completion definitions in your interactive sessions!") }}
</div>
</div>

And... voilà, just like that, _Zsh_ will be able to help you pilot `gerp`!

But we can get faster yet...  By quite a margin.

### Pre-compile the pre-compilation

So now, we're only scanning a bunch of directories, and looking at the first
line of a bunch of files every time we do `compinit`.  Well, **we were doing
that all along**, but now we're still doing it.  Doesn't that seem like it could
be somewhat streamlined?

It turns out that you can do just that!  By default, `compinit` will use a
`.zcompdump` _"cache"_ of **where to find the completions for what**.  It
goes into your `$ZDOTDIR`, which is likely your `$HOME` if you haven't set it
otherwise.

Among a few other things it sets up, the simplest one that we can wrap our minds
around is a simple mapping of utility to completion providers:

```sh
_comps=(
'-' '_precommand'
'.' '_source'
'5g' '_go'
'5l' '_go'
'6g' '_go'
'6l' '_go'
'8g' '_go'
'8l' '_go'
'a2ps' '_a2ps'
'aaaa' '_hosts'
'aac2mp4' '_bento4'
//...
)
```
{{ note(msg="there's more that goes into this file, I choose to focus only on the gift of the topic of the day") }}

If I were to `rm` it, my computer takes just shy of `200ms` doing all that needs
to be done in order to arrive to that _"completion dump"_ (`compdump`) the next
time I would invoke `compinit`.  In general, subsequent `compinit` runs will
use it, of course, but they will also **scour your `$fpath` for possible new
completion modules**: if you install new software that provides completions,
they will be taken into account.

Hm...  Makes you wonder... How much is that, then?  On my machine it's about
`15ms`.  Again, nothing to write home about, but:

> Drop by drop is the water pot filled.
>
> {% attribution() %} Buddha, _the Dhammapada_ {% end %}

Besides, won't you want to possibly effect a full rebuild once in a while
anyway?  Here's what `man zshcompsys` has to say on the matter:

> If the number of completion files changes, `compinit` will recognise this and
> produce a new dump file.  However, if the name of a function or the arguments
> in the first line of a `#compdef` function (as described below) change, **it
> is easiest to delete the dump file by hand** so that `compinit` will re-create
> it the next time it is run.

   Ah-ha!  We were supposed to have been doing that all along?  Oops.<br>
   It goes on to instruct us further:

> The check performed to see if there are new functions can be omitted by giving
> the option `-C`.  In this case the dump file will only be created if there
> isn't one already.

Ah, there it is.  The final piece of that puzzle on the quest to setting up your
shell choke-full of tricks and gadgets, while having it load **fast enough to
feel responsive**.

### Fast enough to feel responsive

To those that may think that this is one hell of a subjective metric, _while I
agree_, I would like to mention that I have a particular framework by which I
just responsiveness.

I base it off a fairly credible
publication[^system-latency-guidelines-then-and-now]: [_System
latency guidelines then and now—Is zero latency really considered
necessary?_](https://www.researchgate.net/publication/317801643)

[^system-latency-guidelines-then-and-now]: Attig, C.,  Rauh, N.,  Franke,
    T., & Krems, J.  F.  (2017). System latency guidelines then and now
    – Is zero latency really considered necessary?  In D. Harris (Ed.),
    Engineering Psychology and Cognitive Ergonomics 2017, Part II, LNAI 10276
    (pp. 2-14). Cham, Switzerland:  Springer International Publishing AG.
    doi:10.1007/978-3-319-58475-1_1

    Available at [https://www.researchgate.net/publication/317801643](https://www.researchgate.net/publication/317801643)

Although I heartily recommend poring over the table on page 7, for the purpose
of this article, we can distil the information down to the following substrate:

> [...] performance in zero-order and more demanding second-order **tasks
> already gets impaired by latencies between `16`-`60ms`**.  Therefore, the
> lower boundary of `100ms` as mentioned in several design guidelines appears
> outdated.

There you have it, a basic number.  My personal observation had been that if
you type some 100 words per minute, I'd guesstimate that your key presses occur
at the approximate rate of one per `100ms`—when writing prose.  I consider
that the more mechanical `CLI` habits that made themselves at home in you muscle
memory (think `git status` or `cd ~/the-ultimate-monorepo`) are certain to come
out with a significantly greater alacrity: **I want to be able to spawn a new
shell and start typing away, without having to suffer from any stutter**.

In summary, here's the whole solution:

```sh
#! /usr/bin/env zsh

readonly dumpfile=$ZDOTDIR/.zcompdump
readonly compdir=$XDG_DATA_HOME/zsh/site-functions

mkdir -p $compdir
rm -- $compdir/*

niri completions zsh    > $compdir/_niri
opencode completion zsh > $compdir/_opencode  # have even that one, if you want!

fpath+=($compdir)
[ -f $dumpfile ] && rm -- $dumpfile
autoload -U compinit && compinit -d $dumpfile
```
{{ note(msg="I automatically run this script once a day, with a `systemd` timer") }}

Run the above asynchronously, once in a while (perhaps on a `systemd` timer?),
and/or when you install new software; retain only the below in your `.zshrc`.

```sh
typeset -U fpath
fpath+=($XDG_DATA_HOME/zsh/site-functions)
autoload -U compinit && compinit -C
```
{{ note(msg="`typeset -U` ensures that there may be no duplicate in your `$fpath`") }}

> [!IMPORTANT]
>
> I assume here that you've set `ZDOTDIR` and `XDG_DATA_HOME` explicitly and
> aptly—that is, in your `.zshenv` or _"earlier"_.  Not having provided
> fall-backs here isn't for any lack of skill or consideration on my end; the
> same observation goes for the absence of double-quotes surrounding expanding
> bits.
>
> Consider this: be deliberate, vigilant and sure of yourself, and you get to
> write `rm -- $compdir/*` instead of the poorer `rm "$compdir"/*`.

In my current entire set-up, I get a new interactive _Zsh_ session, complete
with all the bells and whistles one could dream of **well within `32ms` of
having requested it**—where about half that time is allotted to `compinit -C`.

I could do without, but I don't, because I don't want to.  If you're in the same
boat, have fun; if you aren't: have fun as well—cheers!
