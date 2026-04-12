+++
title = 'The ultimate omni-`<Tab>` Zsh widget'
date = 2026-04-06
description = 'One key to bring them all, and in the completion bind them'
taxonomies.section = ['flashcards']
taxonomies.tags = ['all', 'cli', 'zsh']
extra.cited_tools = ['zsh']
+++

I use the **[Z shell, _Zsh_](https://www.zsh.org/)**.  Before using it,
I'd acquired some reasonable familiarity with the <abbr title="Portable
Operating System Interface">`POSIX`</abbr> shell specification, and the
**Bourne-Again Shell, _Bash_**.  By that, I mean that it's been a couple
of years since I last pair-programmed extensively with a colleague that
wasn't wooed by the "tricks" I have up my sleeve.  Yet, certainly not due to
more, newer or better tools—you and I do wield (though perhaps not quite
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

As a result, I use _Zsh_, without any shred of [_Oh My
Zsh_](https://ohmyz.sh/)—though this shouldn't be taken as an indictment: it
is a great project, one I've simply "outgrown".  I'm not alone in this, but we
are few; this article is for those of us that get intimate with their tools (and
perhaps even <abbr title="Read The F... riendly Manual">`RTFM`</abbr>), and for
those of you who look forward to doing just that.

<!-- [RTFM](@/flight-manual/read-the-friendly-manual). TODO: LINKME -->

## Complete and expand all the things

I found it.  The Grail, the **one key to bring them all and in the completion
system bind them**[^one-ring].  I present to you the **omni-`<Tab>`**!

[^one-ring]: It's a reference to the [One
Ring](https://en.wikipedia.org/wiki/One_Ring), from the (somewhat) [eponymous,
inevitable trilogy](https://en.wikipedia.org/wiki/The_Lord_of_the_Rings)
(it's not really a _trilogy_) from the venerable
[J. R. R. Tolkien](https://en.wikipedia.org/wiki/J._R._R._Tolkien).  Its English
translation originally goes:

    > One ring to rule them all,&nbsp;&nbsp;&nbsp;&nbsp;one ring to find them,<br>
    > One ring to bring them all&nbsp;&nbsp;&nbsp;&nbsp;and in the darkness bind them.

    Note that it's translated from [_Black
    Speech_](https://en.wikipedia.org/wiki/Black_Speech), which looks quite a
    lot more poignant in Tengwar, which my preferred font system for this blog
    sadly doesn't have glyphs for.

```sh
zmodload zsh/complist
autoload -U compinit && compinit
autoload -U _generic
zle -C zle-expand-omni expand-or-complete _generic

zstyle ':completion:zle-expand-omni:*' completer _expand_alias _complete _approximate
zstyle ':completion:*' menu select

bindkey '^I' zle-expand-omni
```
{{ note(msg="so little, to get you so far already") }}

### Use the familiar completion system

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> █
</code></pre>{{ note(msg="`1.` begin entering a `cd` command") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> █
<span class="term-0">home/ scripts/</span>
</code></pre>{{ note(msg="`2.` press `<Tab>` once for the completion menu") }}
</div>
</div>

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> scr█
<span class="term-0">home/ scripts/</span>
</code></pre>{{ note(msg="`3.` start typing away, here `scr`") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> scripts/█
<span class="term-0">home/ scripts/</span>
</code></pre>{{ note(msg="`4.` press `<Tab>` again to complete") }}
</div>
</div>

### Interact with the menu selection

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> █
</code></pre>{{ note(msg="`1.` begin entering a `cd` command") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> █
<span class="term-0">home/ scripts/</span>
</code></pre>{{ note(msg="`2.` press `<Tab>` once for the completion menu") }}
</div>
</div>

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> <span class="term-fg32">home/█</span>
<span class="term-inv">home/</span><span class="term-fg0"> scripts/</span>
</code></pre>{{ note(msg="`3.` press `<Tab>` again for the interactive menu") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34"><span class="term-fg31">cd</span></span> <span class="term-fg32">scripts/█</span>
<span class="term-fg0">home/</span> <span class="term-inv">scripts/</span>
</code></pre>{{ note(msg="`4.` navigate the menu—using other bindings") }}
</div>
</div>

> [!TIP]
>
> You'll want to set some bindings to most comfortably navigate the menu in
> selection mode.  You can go up, down, left, right, and even enter a practical
> dynamic search, all "for free", in your base _Zsh_ shell.
>
> I went with <abbr title="The ubiquitous text editor">Vim</abbr>-like bindings,
> `h`-`j`-`k`-`l`, while holding the `<Meta>` button—that's `Alt` on a
> keyboard labelled for [Windows](https://www.microsoft.com/en-us/windows).
> I enjoy the same bindings across several 2-dimensional interfaces; such
> as Vim's [quickfix](https://vimhelp.org/quickfix.txt.html#quickfix)-lists
> stack[^quickfix-2d], `fzf`'s search results interface[^fzf-2d], `tmux`'s pane
> resizing, _et cet_.
>
> I'll be sure to put together some more quick-yet-insightful articles to help
> you making you feel most at home; until then, `man zshzle` is a good and
> plentiful resource.

[^quickfix-2d]: A Vim `quickfix` list is one-dimensional, but **such lists are
organised in stacks**! `:cold`, `:cnew`, `:cprev`, `:cnext`, four cardinal
directions, `hjkl`.

[^fzf-2d]: The same goes for `fzf`: with `--multi`, the **selected state
constitutes the second dimension**

### Expand [glob patterns](https://en.wikipedia.org/wiki/Glob_(programming))

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34">ls</span> <span class="term-fg33">*█</span>
</code></pre>{{ note(msg="`1.` begin entering an `ls` command") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34">ls</span> <span class="term-fg32">LICENSE README home/ scripts/</span> █
</code></pre>{{ note(msg="`2.` press `<Tab>` to expand the matching items") }}
</div>
</div>

### Expand your `alias`es

<div class="grid-1-3">
<div>
<pre class="giallo z-code">
<code><span class="term-fg31">alias</span> <span class="term-fg33">git</span>=<span class="term-fg32">'noglob git'</span>
</code></pre>{{ note(msg="`1.` set up some `alias`") }}
</div>
<div>
<pre class="giallo z-code">
<span class="term-fg33">git█</span>
</code></pre>{{ note(msg="`2.` prepare to use it") }}
</div>
<div>
<pre class="giallo z-code">
<span class="term-fg34">noglob git</span> █
</code></pre>{{ note(msg="`3.` press `<Tab>` to expand it") }}
</div>
</div>

Fairly neat!  I figure it's about universal, hence my dubbing it the
**omni-`<Tab>`**.  But there is more.

## Some extra niceties for the journey

Note that it is quite intelligent in understanding your intent:

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg33">ll█</span>
<span class="term-fg34">ls</span> <span class="term-fg32">-l --almost-all --human-readable</span> █
</code></pre>{{ note(msg="**expand `alias`es** with your cursor adjacent") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg33">ll</span> █
LICENSE README home/ scripts/
</code></pre>{{ note(msg="**complete commands** with a cursor disjoined") }}
</div>
</div>

You may also complete the **beginning of an `alias`** to its full name, then
**expand it**, then **complete its arguments** if you so choose.  Unexpanded
`alias`es still get the correct completion options, by the way; how I love this
entire system.

### You can even "take it back"

If you started typing `mv -t new-destination **/*.sh` and expanded it, only to
find that it put an ungodly amount of entries in your command line, you can
still _"oops"_ right out of here without losing your hard-earned pre-expansion
command:

```sh
bindkey ^_ undo
```
{{ note(msg="this is `Ctrl-/`, I believe I adopted that one from the _Zsh-grandmaster_ [Roman Perepelitsa](https://github.com/romkatv) himself") }}

> [!TIP]
>
> Can't tell that `^_` is `Ctrl`+`/`, or that `^[[Z`
> means `Shift`+`Tab`?  You may find out what [escape
> sequence](https://en.wikipedia.org/wiki/Escape_sequence) your key combination
> triggers in a simple interactive `cat`!
>
> Just run `cat`, and type away, quit with `Ctrl`+`C` or `Ctrl`+`D`.  It
> won't handle every case, such a `Tab`, `Ctrl`+`D`, backspace...  But at
> least it's handy, available, and not too hard to remember: a ubiquitous
> utility[^useless-use-of-cat], no arguments.

[^useless-use-of-cat]: Is `cat` even perhaps _too ubiquitous_?  I
talk in some other article of the now infamous [useless use of
`cat`](@/flashcards/useless-use-of-cat.md), which you may enjoy going over.

That is it: `bindkey <mapping> undo`.  Let's see it in action:

<pre class="giallo z-code">
<code><span class="term-fg34">mv</span> <span class="term-fg32">-t scripts/</span> <span class="term-fg33">**</span>/<span class="term-fg33">*</span>.sh</span>█
</code></pre>{{ note(msg="preparing to move your scripts to the `scripts/` directory") }}

Press `<Tab>` before executing it, just to be sure...

<pre class="giallo z-code">
<code><span class="term-fg34">mv</span> <span class="term-fg32">-t scripts/</span> <span class="term-fg32">bin/startup.sh bin/check_env.sh bin/deploy.sh bin/cleanup.sh bin/update.sh bin/monitor.sh
bin/restart_services.sh tools/sysinfo.sh tools/network_check.sh tools/randomizer.sh tools/service_restart.sh
tools/optimize.sh tools/package.sh tools/install_dependencies.sh tools/benchmark.sh utils/parse_logs.sh
utils/backup_files.sh utils/monitor.sh utils/send_alert.sh utils/archive_data.sh utils/rotate_logs.sh
utils/sync_files.sh utils/cleanup_temp.sh tools/analyze_performance.sh tools/check_disk.sh bin/health_check.sh
bin/cache_clear.sh bin/update_configs.sh utils/email_report.sh utils/generate_report.sh tools/security_scan.sh
tools/update_packages.sh tools/reindex.sh utils/migrate_files.sh utils/cleanup_old.sh utils/check_integrity.sh</span>
</code></pre>{{ note(msg="oh, no, good grief, **ABORT!** is there one such button?") }}

<div class="grid-1-2">
<div>
<pre class="giallo z-code">
<code><span class="term-fg34">mv</span> <span class="term-fg32">-t scripts/</span> <span class="term-fg33">**</span>/<span class="term-fg33">*</span>.sh</span>█
</code></pre>{{ note(msg="roll it back with the binding of your choice") }}
</div>
<div>
<pre class="giallo z-code">
<code><span class="term-fg34">mv</span> <span class="term-fg32">-t scripts/</span> <span class="term-fg33">{utils,bin}</span>/<span class="term-fg33">*</span>.sh</span>█
</code></pre>{{ note(msg="adjust and correct your command") }}
</div>
</div>

<pre class="giallo z-code">
<code><span class="term-fg34">mv</span> <span class="term-fg32">-t scripts/</span> <span class="term-fg32">bin/startup.sh bin/check_env.sh bin/restart_services.sh bin/update_configs.sh utils/migrate_files.sh
utils/cleanup_old.sh utils/check_integrity.sh</span>
</code></pre>{{ note(msg="that's more like it! though I had no idea of these other forsaken piles... future-me can sort it out") }}

> [!NOTE]
>
> This approach is arguably not the most appropriate if your only intention was
> to "peek" as what the glob would expand to, but hey, when you have it, and it
> works for "everything", and it can always be undone at the press of a button,
> why not!  I will circle back on that in another article that I hope to put out
> soon.

<!-- [](@/flight-manual/bash-history-expansion). TODO: LINKME -->

### Going forward

I am barely scratching the surface of what a neat _Zsh_ set-up can bring, but I
believe that, in isolation, **these few lines putting together an omni-`<Tab>`
make for a complete unit of information**, small and focused enough to be
digestible—though maybe stopping to explain what each does would be of some
benefit, too.

Good luck, and have fun!
