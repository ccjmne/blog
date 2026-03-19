+++
title = "Juggle context with `sed`'s pattern and hold spaces"
date = 2026-01-08
description = "Master the use of `sed`'s secondary buffer to carry some state across lines"
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'posix', 'sed']
extra.cited_tools = ["fzf", "keepassxc", "sed", "vim"]
+++

As `sed` processes its input line by line, it works primarily with its **pattern
space**: a buffer that generally holds the current line being processed.
Generally?  Let's look into it.

> [!IMPORTANT]
>
> There's virtually no point in getting into this article if `sed '2!d'`
> leaves you perplexed.  If that is the case, you may find better value
> in a detour through some thorough (or quick, there's a `TL;DR`)
> introduction to the one core, digestible, unequivocally practical facet
> of `sed` that you may be lacking, in [_Scope `sed` commands to specific
> lines_](@/flight-manual/scope-sed-commands-target-lines.md).

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR) {#tldr}

Most `sed` operations are executed against the content in the **pattern space**,
the current input line.  The **hold** space is a second buffer that is at your
disposal, and with which you can carry state across lines, compare with previous
content, or assemble output that spans multiple lines.

These few commands are the substrate of what using the hold space distils down
to:

- `h`/`H` to copy/append **from pattern to hold** space (`h` for "hold")
- `g`/`G` to copy/append **from hold to pattern** space (`g` possibly for
  "get"?)
- `x` to **e`x`change** the contents of hold and pattern spaces.

> [!NOTE]
>
> I feel like `g` nicely mirrors and follows `h` (on a touch-typist's
> `QWERTY` keyboard and in the alphabet, respectively); I have used them
> for connection and disconnection signals in hand-rolled communication
> protocols, mnemonics for "hello" and "goodbye"; we often use `g`
> and `h` as companions to `f` in describing functions in [abstract
> algebra](https://en.wikipedia.org/wiki/Abstract_algebra)...  Surely they're
> well-understood to work as a pair, and `g` makes sense to un-`h` something?

For example, consider the following document:

```toml,name=my-awesome-crate.toml
[package]
name = "my-awesome-crate"
version = "1.2.3-final.rc.99+g55dd287"
readme = "README.md"

[dependencies]
async-io = { version = "2.6.0", optional = true }
clap = { workspace = true, features = ["string"] }
libc = "0.2.176"
```
{{ note(msg="a semi-legible version number that nonetheless conforms to the [SemVer](https://semver.org/) specification") }}

Sprinkle in some impossibly dense, `POSIX`-compliant `sed` magic to **in-line
the section names** (which also constitutes valid `toml` syntax):

```sh
sed '/^\[/ {s/[][]//g;h;d}
     /./   {G;s/\(.*\)\n\(.*\)/\2.\1/}' my-awesome-crate.toml
```
```txt
package.name = "my-awesome-crate"
package.version = "1.2.3-final.rc.99+g55dd287"
package.readme = "README.md"

dependencies.async-io = { version = "2.6.0", optional = true }
dependencies.clap = { workspace = true, features = ["string"] }
dependencies.libc = "0.2.176"
```
{{ note(msg="horrifying?  possibly—beauty is in the eye of the beholder; `POSIX` compliance, however, is indisputable") }}

Note the delightfully quirky `BRE` substitution `s/[][]//g` employing the most
savvy `[][]` character class to match either literal square bracket.  Who says I
don't know how to have fun?

</div>

This example above in the `TL;DR` doesn't look too pretty (although, it'd be
nicer with some extended <abbr title="Regular Expressions">`RegExp`</abbr>
syntax).  I would say in general that my articles on `sed` or Vim won't quite
be for the faint of heart: you have to pace yourself reading it, but I assure
you: **these incantations are so very simple to come up with**, once familiarity
overcomes the dreadful arcane.

In any case, despite routinely lovingly calling these _"write-only"_, there's
something about contorting `POSIX` tools to get the job done that I find serves
me well in the long run.

## The processing cycle

In brief, `sed` reads a line (without its trailing linefeed)[^trailing-linefeed]
into what it calls the **pattern space**, applies all commands whose addresses
match, in order[^may-bail-out], then prints out the resulting buffer, and
repeats.  The **hold** space is a companion to that main "work" buffer, which
persists across cycles and is effectively entirely inert unless you manipulate
it with `h`/`H`, `g`/`G`, or `x`.

[^trailing-linefeed]: Some notorious text wranglers, whose ranks I am
bolstering, define a line of text as ending with a `\n` character.
Consequently, there shall be a trailing `\n` at the end of a file, lest it
doesn't end with a line, but that constitutes in no way an "empty line", and
yes, a file containing text without a linefeed contains no line.  Numerous
tools, such as `wc` (`echo -n 'some text' | wc -l`), concur; but let not
popularity dictate your tastes, consider the elegance of the consequences.

[^may-bail-out]: Some commands may cut short the further processing of a loop
    and advance to the next iteration—that is, typically, process the next
    line.  For instance, `d` **`d`eletes** the pattern space and continues to
    the next cycle. `b` **`b`ranches** to a _label_, or the next cycle if no
    label is provided: I intimately call it _"bail"_ and use in such manner.

    > [!TIP]
    >
    > I often come across an alternative to explicitly continuing to the next
    > cycle: by default, `sed` prints the pattern space at the end of each
    > cycle.  Some routinely reach for `-n` to suppress that behaviour, together
    > with the `p` instruction to selectively output only the desired bits.
    > `POSIX` only defines `-n`, but at least `GNU`'s implementation also
    > synonymously supports `--quiet` and `--silent`.

    Do note that, without the `-n` flag, `b` would **still print out the pattern
    space** before the next loop, whereas `d` wouldn't.

    There is more to the labelling and branching system, such as the `t` and `T`
    operations, but these are quite the head-scratcher and may be better left to
    the discretion of the reader whose resolve is most unwavering, rather than
    to a hand-wavy footnote in any of my already generally hardly digestible
    articles.

> [!NOTE]
>
> Use addresses to scope where your logic runs: `<address>{<commands>}`.
> I wrote in great length about `sed` addresses in [this previous
> article](@/flight-manual/scope-sed-commands-target-lines.md), which is likely
> far more approachable and useful than this current one.

So how do you manipulate it?  **Frankly, it's simple.**  In my opinion, perhaps
simpler than whichever degree of simplicity would maximise elegance and
practicality (I would _very much_ like a way to clear the hold, for instance,
without having to clear the pattern and push _that_ into the hold: `s/.*//;x`),
but at least it's simple: I'll give it to you (essentially) straight from the
scripture, `man 1p sed`:

- `g` **replaces** the contents of the **pattern** space with the contents of
  the hold space,
- `G` **appends** to the pattern space a linefeed and the contents of the hold
  space,
- `h` **replaces** the contents of the **hold** space with the contents of the
  pattern space,
- `H` **appends** to the hold space a linefeed and the contents of the pattern
  space, and
- `x` **exchanges** the contents of the pattern and hold spaces.

> [!TIP]
>
> Appending with `H` and `G` always involves a linefeed: plan your substitutions
> (`s///` commands) accordingly.

## Exempli gratia

There really isn't that much to the hold space in `sed`.  All that's possibly
quite noteworthy is that many seemingly go through their entire `CLI` dwelling
life without using it: do we simply never need anything like that, or **is
it a case of not considering the options that require tools we haven't yet
mastered?**

Without much ceremony, here come some examples that may lack systematic
practicality, but truly do come in handy when the servers are on fire and we
wouldn't mind somebody navigating the system like they would the back of their
hand—or, as the French would say, the bottom of their pocket.

### Reverse lines

Let's whet our appetite with some **fantasy recipe**, merely to get the
_braingine_ going: reversing lines.  Well, `sed`'s not built for that, it
processes _streams_ of data, and while this would indeed be guaranteed to work
for files up to 8kb in size[^8kb], `tac` (`cat` in reverse!) from `GNU`'s
excellent `coreutils` is a much more appropriate tool for that job.

```sh
sed '1!G;h;$!d' file
sed '1!G; h; $!d' file
sed '
  1!G
  h         # [h]old on to it
  $!d
' file
```
{{ note(msg="don't hesitate to format your `sed` scripts with newlines and comments for readability") }}

[^8kb]: The `POSIX` specification (`man 1p sed`) guarantees that both pattern
and hold spaces can hold at least 8192 bytes.  `GNU sed` removes practical
limits for most uses.

- `1!G`, unless at line `1` (the first), append the accumulated hold to the
  pattern;
- `h`, save the aggregate into the hold;
- `$!d`, unless at line `$` (the last), discard the pattern; `sed` will
  implicitly print out the only non-discarded pattern, the ultimate one
  coalescing the entire accumulated reversed collection of lines.

You could do away with specifying `1!`, in which case the original (empty) hold
space, **as well as an extra linefeed**, would be appended to the end of the
output.  Non-printable characters may very well not be most obvious, but we
should strive to keep things tight.  Restricting `G` to `1!` avoids having to
`$s/\n$//` at the end of the script.

### Practical use case: distribute context

At work, we've got a few teams contributing to a sizeable
number of modules.  We make use of a [`CODEOWNERS`
file](https://docs.gitlab.com/user/project/codeowners/reference/) that looks
something like:

```ini,name=CODEOWNERS
# --- Legacy Wranglers ---
[Legacy Wranglers] @team-legacy-wranglers
monolith/
cron-scripts/
soap-adapter/
ancient-batch-jobs/
v1-api/

# --- Everything Breaks Here ---
[Chaos & Incidents] @team-chaos
pagerduty-hooks/
incident-simulator/
fire-drills/
rollback-scripts/
midnight-alerts/

# --- Frontend Pain Relief ---
[Frontend Pain Relief] @team-frontend
css-specificity-war/
ie11-polyfills/
npm-dependency-hell/
storybook/
component-library-v2/
```

When something's looking iffy, I would like to spin up `fzf` to find who the
responsible team for a particular module is: it'd be neat to have the `@team`
tag **on the same line** as the component—this is trivially achieved using
`sed`'s _hold space_.

> [!TIP]
>
> `fzf` is a **command-line fuzzy finder**[^fzf-alternatives]: sift through
> whatever comes through its standard input in many practical ways.  It's a
> stupendous one at that, especially when paired with tools that can catalogue
> files fast (I mean `fd`), and even more so when you realise that quite a few
> things in your `CLI` life could use some fuzzy goodness.

[^fzf-alternatives]: There are other quite excellent command-line fuzzy
    finders, such as `fzy` and `skim`.  In comparing the three,
    any one may boast slightly different matching algorithms,
    somewhat faster processing speed for gazillions of records,
    somewhat lighter memory footprint, _et cet_.  **The people being
    each of these three projects are proper world-class software
    [whizzes](https://dictionary.cambridge.org/dictionary/english/whiz)** and
    these **are constantly improving in several of the above directions**, while
    offering more features (asynchronous data fetching, for example).

    Each and **every one of them is truly and unequivocally orders of
    magnitude faster than whatever your `IDE` ships to find text—no,
    _seriously_**.  Pick any, **you can't go wrong**; although as the
    [Rifleman's Creed](https://en.wikipedia.org/wiki/Rifleman%27s_Creed)
    goes: _"There are [a few] like it, but this one is mine"_.

```sh
sed '/^\[/h;/^[a-z]/!d;G;s/\n/\t/' CODEOWNERS | fzf
sed '
  /^\[/h         # hold title section: [Team Name] @team-id  
  /^[a-z]/!d     # drop empty, comment and section lines     
  G;s/\n/\t/     # join with hold space using a "\t" for separator 
' CODEOWNERS | fzf
```
```txt
monolith/	[Legacy Wranglers] @team-legacy-wranglers
cron-scripts/	[Legacy Wranglers] @team-legacy-wranglers
soap-adapter/	[Legacy Wranglers] @team-legacy-wranglers
ancient-batch-jobs/	[Legacy Wranglers] @team-legacy-wranglers
v1-api/	[Legacy Wranglers] @team-legacy-wranglers
pagerduty-hooks/	[Chaos & Incidents] @team-chaos
incident-simulator/	[Chaos & Incidents] @team-chaos
fire-drills/	[Chaos & Incidents] @team-chaos
rollback-scripts/	[Chaos & Incidents] @team-chaos
midnight-alerts/	[Chaos & Incidents] @team-chaos
css-specificity-war/	[Frontend Pain Relief] @team-frontend
ie11-polyfills/	[Frontend Pain Relief] @team-frontend
npm-dependency-hell/	[Frontend Pain Relief] @team-frontend
storybook/	[Frontend Pain Relief] @team-frontend
component-library-v2/	[Frontend Pain Relief] @team-frontend
```

As a bonus, you can even get the "owner" column neatly aligned,
trivially, using `column`.  I go in depth into mastering
`column` and a couple of other tools in the [Intralinear
Partitioning](@/flight-manual/intralinear-partitioning/_index.md) series, if you
want to stomach more of my thoughts on that topic.

```sh
sed '/^\[/h;/^[a-z]/!d;G;s/\n/:/' CODEOWNERS | column -ts: | fzf
```
```txt
monolith/              [Legacy Wranglers] @team-legacy-wranglers
cron-scripts/          [Legacy Wranglers] @team-legacy-wranglers
soap-adapter/          [Legacy Wranglers] @team-legacy-wranglers
ancient-batch-jobs/    [Legacy Wranglers] @team-legacy-wranglers
v1-api/                [Legacy Wranglers] @team-legacy-wranglers
pagerduty-hooks/       [Chaos & Incidents] @team-chaos
incident-simulator/    [Chaos & Incidents] @team-chaos
fire-drills/           [Chaos & Incidents] @team-chaos
rollback-scripts/      [Chaos & Incidents] @team-chaos
midnight-alerts/       [Chaos & Incidents] @team-chaos
css-specificity-war/   [Frontend Pain Relief] @team-frontend
ie11-polyfills/        [Frontend Pain Relief] @team-frontend
npm-dependency-hell/   [Frontend Pain Relief] @team-frontend
storybook/             [Frontend Pain Relief] @team-frontend
component-library-v2/  [Frontend Pain Relief] @team-frontend
```

Pipe the whole thing into `fzf`, query for `cron`, and be served _just what the
doctor ordered_:

```txt
cron-scripts/          [Legacy Wranglers] @team-legacy-wranglers
> cron█ < 1/15
```
{{ note(msg="our real `CODEOWNERS` is considerably more impenetrable, and my one-line script does come in handy") }}

### Practical use case: pull an entry to the top

I store my passwords in [`KeePassXC`](https://keepassxc.org/), and I often
need to copy some attribute of an entry, such as the password itself, or the
username, or the URL.  I have a menu that lists available attributes for a
given entry, and would just like the convenience of having the password as the
first, most accessible option: 32 bytes of `sed` ~gibberish~ goodness later,
and voilà, the password comes first, and the rest knows how to best organise
itself.

```sh
sed -n '/^Password:/{p;b};H;${g;s/\n//p}'
sed -n '
  /^Password:/ {p;b}  # when the "Password" option is shown, print it and "bail" out
  H                   # accumulate other fields
  $ {                 # once at the end of the document,
    g                 #   bring the hold into pattern
    s/\n//            #   trim leading linefeed (from first "H" into a then-empty hold space)
    p                 #   print the other options in their natural order
  }'
```
{{ note(msg="`keepassxc-cli` actually displays that attribute as `Password: PROTECTED`, of course") }}

> [!NOTE]
>
> For completeness' sake, I could explain that **each entry's attributes
> ranking is otherwise weighted through some access <abbr title="frequency +
> recency">_"frecency"_</abbr> heuristic**, but that, for these old accounts I
> haven't accessed in a while (or to start off the system), I know that **the
> password** is most likely the attribute I want available through my clipboard
> for the next 5 seconds.

It certainly could have been done otherwise, possibly, but I did it like that,
and therefore I, **and you too now**, have seen it done like that.  I actually
don't recall having seen it done any other way.

## Wrapping up

**I like that `sed` is there, in `POSIX`, the standard of standards, and by
extension in all noteworthy, non-recreational contemporary end-user operating
systems**, available and behaving in a way not susceptible to unilateral
`API` changes or anything of the murky sort.  You don't have to use it,
but you may well acknowledge the following: we're out there _"upgrading
stuff"_ because some transitive dependency is flagged for some nonsensical
[`CVE`](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures) that
the maintainer of our intermediary dependency is adamant doesn't affect their
product, **whereas my entire runtime... is already running on your system**.

The hold space isn't that mystical: the [`TL;DR`](#tldr) section at the top
actually covers **every command pertaining to it**, and it's just some 3 measly,
highly mnemonic 1-letter directives.  Now that I've seen its face, I see it
peering out at me, once in a while along my `CLI` journey; it is my hope that
this old friend may some day comfort you as well.

Good luck, and have fun.
