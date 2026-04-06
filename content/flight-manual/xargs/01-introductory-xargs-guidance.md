+++
title = 'Some introductory `xargs` guidance'
date = 2026-03-13
description = 'Just enough to get the ball rolling for most of your `CLI` wizardry needs'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'posix']
extra.cited_tools = ['fd', 'find', 'xargs']
+++

An either well-established or soon-to-be staple of your <abbr title="Command
Line Interface, where I dwell">`CLI`</abbr> vocabulary, `xargs` lets you
fluently bridge the gap left by simple Unix pipes, `|`, in the unidirectional,
fleeting <abbr title="Inter-Process Communication">`IPC`</abbr> protocol their
provide: with it, you can **transform output data into flags and arguments for
other utilities**.  Before we get to the power-user's notes, however, a few
introductory hints are <abbr title="prescribed by etiquette">de rigueur</abbr>.

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

`xargs` is a `POSIX` tool that lets you build and execute command lines from
standard input:

```sh
touch a b c               # natural approach
touch $(echo a b c)       # subshell approach
echo a b c | xargs touch  # pipeline approach
```
{{ note(msg="these are all functionally equivalent") }}

You will find `xargs` to be quite handy in a couple of occasions:

- the _"natural approach"_ only works when you know in advance the arguments
  you'll want to use.  I presume it obvious, but it is the only commendable way
  to approach invoking some utility; let's move on;
- the _"subshell"_ approach runs a command in a sub-shell, then uses its
  output to pass arguments to another tool.  Note that the two are run
  **sequentially**, and this approach prevents you to **start getting some
  responses** from the second utility until the first one has completed its
  task;
- the _"pipeline"_ approach, relying on `xargs`, for some tasks that may take a
  while, such as, typically, finding and listing files to run some operations
  on, you really may **draw benefits from a more parallel approach** where both
  utilities are working together [as the
  finest systems folks intended](https://adamdrake.com/command-line-tools-can-be-235x-faster-than-your-hadoop-cluster.html).

 There are yet other alternatives, however, among which the most glaring would
be **`find`'s courtly (albeit somewhat limited) `-exec` mechanism**—and its
"operative siblings", like `-execdir`, `-delete`, `-ok` (as well as further
non-`POSIX` [_"in-laws"_](https://en.wikipedia.org/wiki/Sibling-in-law),
`-link`, `-copy`, `-rename`...).<br>
  Whenever possible, I argue that **using the capacity built in your primary
tool would be most fluid and elegant[^elegance]**.

[^elegance]: I really insist, the most elegant way to use a tool is with the
great proficiency that only comes from knowing it inside out.  Think of it this
way: **if you're reading a book, you will hold it open**, and you'll bounce
light off its pages and into your eyes; **would you rather hold something that
holds the book**, and reach for your smart phone to digitalise its pages through
its camera, only to watch _that_ live feed on its screen?  In some cases (when
you'd get the added benefit of live software-enabled translation, for example),
it's the way to go; **typically, that'd be preposterous**.

Lastly, **know of `-t`, for _"trace"_, and `-p`, for _"prompt"_**, which allow
you to output to <abbr title="The standard error output">`stderr`</abbr> the
commands to be invoked, and, with respect to `-p`, to await explicit affirmative
answer before proceeding with each.  In the case of `GNU`'s implementation,
**any answer starting with `y` or `Y` is affirmative**.

</div>

## Some goodies to get started

I'll assume you already have a vague idea what `xargs` does; I'll go straight to
a couple of tips that will come up later and should therefore be introduced at
some point.

The `-t` flag, for _"trace"_, will have `xargs` output to its _standard error_
output each command that it will execute, which is quite useful for debugging or
general logging:

```sh
git ls-files '*.[c,h]' | xargs -t wc
```
```txt
wc arg.h config.def.h st.c st.h win.h x.c
    50    145   1036 arg.h
   474   2548  20850 config.def.h
  2705   8808  58906 st.c
   126    452   2923 st.h
    41    163   1163 win.h
  2108   6367  48343 x.c
  5504  18483 133221 total
```
{{ note(msg="with `-t`, we can see that `xargs` here called: `wc arg.h config.def.h st.c st.h win.h x.c`") }}

The `-p` flag, for _"prompt"_, builds upon that mechanism and will stop before
each invocation, asking interactively for confirmation before executing any
command:

<div class="grid-1-2">
<div>

```txt,name=files-to-delete.txt
./data/export/users.csv
./build/output/main.js.map
-rf /
```
{{ note(msg="some curious file name you've got there") }}
</div>
<div>

```sh
cat files-to-delete.txt | xargs -p rm
xargs -p rm < files-to-delete.txt
```
```txt
rm ./data/export/users.csv?...y
rm ./build/output/main.js.map?...y
rm -rf /?...n
```
{{ note(msg="`-p` here let us avoid a disaster") }}
</div>
</div>

> [!NOTE]
>
> This `cat <file> | xargs <cmdline>` isn't the most egregious an [useless use
> of `cat`](@/flashcards/useless-use-of-cat.md), since `-a`/`--arg-file`, the
> `GNU` flag that would let `xargs` consume its input from a file descriptor
> directly, isn't part of the `POSIX` specification.

Be careful however, for being repeatedly prompted for confirmation tends to have
you mechanically agree before you actually do the _"wait wha—"_ double-take...

> [!TIP]
>
> `GNU`'s implementation offers the `--verbose` and `--interactive` long-form
> alternatives to `-t` and `-p`, respectively.  Also, while **the `POSIX`
> specification doesn't quite describe what constitutes an _"affirmative
> answer"_** in _prompt_ mode, `GNU`'s implementation interprets any answer
> starting with a `y` or `Y` as such.

### Make the most of initial arguments

The full syntax for `xargs` is as follows:

```txt
xargs [options] [command [initial-arguments]]
```
{{ note(msg="well, the `POSIX` one is more comprehensive, but this shall do for our purpose") }}

As such, a few things are worthy of mention:

1. omitting the `command` will have `xargs` invoke `echo`;
2. you may specify some `initial-arguments` in addition to the utility to
   invoke;
3. I like to use, for perennial scripts that shall be read and operated by many
   (or for myself, too, sometimes), the `--` convention, also part of [the
   `POSIX` guidelines](https://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html),
   whereby we may separate `xargs`'s _operands_ (the command line to build up)
   from its _options_.  Consider for example:

   ```sh
   find -type f -executable | xargs -n1 ln -s -t ~/bin
   find -type f -executable | xargs -n1 -- ln -s -t ~/bin
   ```
   {{ note(msg="I find the second version to be more easily parsed") }}

Do take note that some utilities, such as `mv`, `cp`, `ln`, _et cet._, who
usually interpret their arguments as `command [source...] destination`, can
**make use of the (non-`POSIX`) `-t`/`--target-directory` flag to accept the
`DESTINATION` earlier** than with the last argument, which pairs well with
`xargs`:

<div class="grid-1-2">
<div>

```sh
find -type f -executable \
    | xargs -t -- mv -t ~/bin
```
```txt
mv -t ~/bin FILE_1 FILE_2 FILE_3
```
{{ note(msg="`mv -t [dest] [src...]` is `xargs`-savvy") }}

</div>
<div>

```sh
find -type f -executable \
    | xargs -tn1 -- ln -st ~/bin
```
```txt
ln -st ~/bin FILE_1
ln -st ~/bin FILE_2
ln -st ~/bin FILE_3
```
{{ note(msg="`mv` isn't the sole recipient of this `-t` blessing") }}

</div>
</div>

> [!NOTE]
>
>    Note that I used two `-t` flags here: the first one for `xargs`, as a
> shorthand for `--trace`, and later, the one standing for `--target-directory`,
> to be passed to `ln`.  Both are `GNU` additions on top of the strictly `POSIX`
> specification.<br>
>    Keep in mind the `--` demarcation that assists in keeping things
> intelligible:  I suspect you might grow fond of it as well.

## Beware [Maslow's hammer](https://en.wikipedia.org/wiki/Law_of_the_instrument)

I'd like to start with a disclaimer: `xargs` is a fine tool, adding it to your
arsenal and being confident in its usage will get you far: you may still want
to **use alternatives possibly built into your original tool**, for several
reasons, ranging from mere convenience to possible hiccup prevention.

The unequivocally most obvious "offender" occurs with file-finding utilities,
most prominently `find` and its `fd`[^find-vs-fd] cousin: their authors know
you'll want to do things with these files, they have the _"pipe into `xargs`"_
functionally built-in, in the form of `-exec`.

[^find-vs-fd]: Both tools let you search for files in your system. **`find` is
    part of the `POSIX` specification, is older, more complex, more powerful and
    complete; `fd` is (largely) more modern in its interface, its implementation
    generally is stunningly faster at working with large collections of files,
    defaults to considering various <abbr title="Version Control System, such
    as Git">VCS</abbr>'s "ignore lists", and favours Regular Expressions rather
    than _globbing_.**  I'd naturally not advocate for `fd`, since it is a mere,
    far smaller subset of `find`, but the convenience in handling the mundane
    tasks, which comprise the overwhelming majority of tasks I met, makes, in my
    opinion, a **strong enough case to justify dual-wielding both tools**.

    > [!TIP]
    >
    > `TL;DR`: **`find` will forever be more powerful**, by philosophy, in
    > offering more savvy integration with the file system.  For example, it
    > allows querying for files' **accessed** at certain times, recognise hard
    > links, filter according to permission flags, possibly avoid crossing
    > _mounted filesystems_, etc.
    >
    > On the other hand, **`fd` is more obvious and natural to pilots, as well
    > as being ignificantly faster**, in part because it embraces "sane modern
    > defaults" and has the luxury of positioning itself as a tool of much
    > humbler scope.
    >
    > **Both are excellent**, the overlap in the solutions they offer is large,
    > but each presents unique qualities of enough value to warrant being
    > advocated for here.

    Know that you won't have it available as soon as you jump into any server or
    any colleague's machine, however.

The following two commands are functionally equivalent—`find -exec ... +`
batches arguments much like `xargs` does:

```sh
find -name '*.tmp' -exec rm {} +          # built-in approach
find -name '*.tmp'         | xargs    rm  # pipeline approach
find -name '*.tmp' -print0 | xargs -0 rm  # most robust, will justify later
```
{{ note(msg="my heart aches knowing full well that `-print0` and `-0` aren't quite `POSIX`") }}

There's also the option to use **command substitution**, but that is **subject
to word-splitting (or _"arguments parsing"_) concerns**, and doesn't quite let
you consider batching and parallelism whatsoever:

```sh
rm $(find -name '*.tmp')  # subshell approach, brittle in the face of white-spaces
```
{{ note(msg="command substitution is expressive, but doesn't quite fill the same niche as `xargs` generally") }}

For simple cases like deleting files, `-exec` or `-delete` is more
elegant[^elegance], but **when you need to filter `find`'s output through other
commands, `xargs` is inevitable**:

<!-- [make ample use of discernment](@/ramblings/make-ample-use-of-discernment.md) TODO: LINKME -->

```sh
find -name '*.log' -exec grep -v trace {} | xargs zip archive.zip +     # nonsense
find -name '*.log'         | grep  -v trace | xargs    zip archive.zip  # works
find -name '*.log' -print0 | grep -zv trace | xargs -0 zip archive.zip  # best, but non-POSIX
```
{{ note(msg="the first line is nonsensical: the pipe, `|`, **cannot be part of the `-exec` arguments** ") }}

> [!NOTE]
>
> It's actually several layers of nonsense: **`grep` cannot receive its input
> content to filter as a list of arguments**.  For the purpose of the example,
> let's pretend that `grep -v archive {}` would work, but know that it doesn't
> actually.

<!-- REALLY NEED TO TALK OF -Z -0 -NULL -PRINT0 RIGHT HERE IN PARTICULAR!!! -->
<!-- [-0-null-print0-z](@/ramblings/-0-null-print0-z.md) TODO: LINKME -->

You may be tempted to go for the following, but `find` actually expects
`{}` to stand **on its own** as an operand; it won't serve as some sort of
_"placeholder"_ within any arbitrary argument;

```sh
find -name '*.log' -exec sh -c 'grep -v archive {} | xargs -0 gzip' +  # nice try; won't work
```
{{ note(msg="attempting to `sh -c '...'` in `-exec` won't quite work either: `{}` won't be interpreted there") }}

There's no one-size-fits-all here, though it may be tempting to
make `xargs` for that.  After all, **idiomaticity and elegance are
subjective**[^subjectiveness-of-idiomaticity]: the latter for its vague,
personal and artistic virtues, the former for the rarefying occasions that
corporate software developers find themselves in where they'd peruse scripts
authored by—or directly work with—some sharp `CLI` user.

[^subjectiveness-of-idiomaticity]: However subjective these may be, let's
    put it this way: if you don't immediately understand the benefits of
    [`sponge`](https://man.archlinux.org/man/extra/moreutils/sponge.1.en),
    have never ended up using [`stdbuf`](https://linux.die.net/man/1/stdbuf),
    nor have a clear and precise idea of the scheduling each process of your
    pipeline is spawned in accordance with, you may not take offence to the
    constant and systematic interjection of many such useless processes; but
    **have [`top`](https://linux.die.net/man/1/top) running in your head while
    you type in the terminal, and your perspective may shift somewhat**.

    > [!NOTE]
    >
    > Of these futile processes or practices, I wrote a while ago about the most
    > venerable [useless use of `cat`](@/flashcards/useless-use-of-cat.md): it's
    > a far more digestible article hearkening back to my less disabused days.
    > What's that, it was just last year?  Oh my.

## Going forward

In any case, **what you're most comfortable with still shall ultimately be the
better choice**.  If you happen however to essentially find yourself in a tie,
you get to make use of discernment and parsimony!

Now that we've got the pleasantries out of the way, I invite
you to dive into the more proper and [practical `xargs`
fundamentals](@/flight-manual/xargs/02-posix-xargs-fundamentals.md) in the next
article of this series.
