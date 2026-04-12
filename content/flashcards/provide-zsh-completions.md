+++
title = 'Whet your appetite for providing Zsh completions'
date = 2026-04-13
description = "What if I told you it's not that hard—nay, what if I proved to you it's outright easy?"
taxonomies.section = ['flashcards']
taxonomies.tags = ['all', 'cli', 'zsh']
extra.cited_tools = ['zsh']
+++

While putting together [Pre-compile your _Zsh_
completions](@/flight-manual/precompile-zsh-completions.md), I came up with
`gerp` (`grep` + <abbr title="A foolish or ignorant person">_derp_</abbr>!), a
lovely virtual companion that never fails to greet you enthusiastically—well,
I like naming my _"foo"_-like utilities that, I don't reserve that name for this
one.

Nevertheless, **here's the topical `gerp`-of the day**, in all its
splendour[^a-longer-version]:

[^a-longer-version]: Well, I came up with slightly more comprehensive one, since
the object of that other article is a lot more intricate, but the gist remains
the same.

```sh,name=gerp
#! /bin/sh

case "$1" in
    hello)       echo 'Henlo, fren!' ;;
    completions) cat                 ;;
    *)           echo '?'            ;;
esac <<'EOF'
_gerp() {
    _values 'commands'              \
            'hello[greet the user]' \
            'completions[generate shell completions]'
}
compdef _gerp gerp
EOF
```

`gerp` it a piece of shell script that will reply to you when you invoke it as
such:

```sh
gerp hello
```
```txt
Henlo, fren!
```

But the nifty thing about is it that it can instruct _Zsh_ as to how its
commands can be completed!

Its `completions` subcommand will have it yield some instructions for you
_Z Shell_ `compsys` (short for _"completion system"_) to know what may come
after `gerp` on your command line: have at it, simply execute the following
Bashism[^process-substitution]:

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

```sh
source <(gerp completions)
```
{{ note(msg="this assumes that you're already also doing somewhere `compinit` in some form or another") }}

And voilà, an `API` that's **discoverable**, without jumping through all the
[`HATEOAS`](https://en.wikipedia.org/wiki/HATEOAS) loops:

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">gerp</span></span> █
</code></pre>{{ note(msg="`1.` begin entering a `gerp` command") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">gerp</span></span> █
<span class="term-0">completions  -- generate shell completions</span>
<span class="term-0">hello        -- greet the user</span>
</code></pre>{{ note(msg="`2.` press `<Tab>` once for the completion menu") }}
</div>
</div>

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">gerp</span></span> hel█
<span class="term-0">completions  -- generate shell completions</span>
<span class="term-0">hello        -- greet the user</span>
</code></pre>{{ note(msg="`3.` start typing away, here `hel`") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">gerp</span></span> hello █
<span class="term-0">completions  -- generate shell completions</span>
<span class="term-0">hello        -- greet the user</span>
</code></pre>{{ note(msg="`4.` press `<Tab>` again to complete") }}
</div>
</div>

There's a lot more to _everything-completion_, but I share it here in the hopes
that this surface-level introduction put a sparkle in your eye: be unafraid, go
and build things, if only for yourself.

Good luck, and have fun!
