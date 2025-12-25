+++
title = 'How to number lines from the `CLI` (read: Vim)'
date = 2025-12-25
description = "Of seemingly little use, `coreutils`'s `nl` handles tasks that, however mundane, are indeed quite frequent"
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'posix']

[[extra.cited_tools]]
   name    = "nl"
   repo    = "https://github.com/coreutils/coreutils"
   package = "core/x86_64/coreutils"
   manual  = "https://man.archlinux.org/man/nl.1.en"
[[extra.cited_tools]]
   name    = "column"
   repo    = "https://github.com/util-linux/util-linux/"
   package = "core/x86_64/util-linux"
   manual  = "https://man.archlinux.org/man/column.1.en"
[[extra.cited_tools]]
   name    = "vim"
   repo    = "https://github.com/vim/vim"
   package = "extra/x86_64/vim"
   manual  = "https://vimhelp.org/"
+++

Sure, there's a tool that numbers lines of text; so what?  The feline
worshippers among us would even promptly jump on the occasion to mention the
`--number`/`-n` flag of `cat`.  Although in practice they probably wouldn't,
because there is no intersection between those that read the manual and [those
that use `cat` all over](@/flight-manual/useless-use-of-cat.md) the place.
Nonetheless, the idea remains: this doesn't sound like something you need.

Maybe you don't do enough!  It does come in handy on some occasion, and when
that need arise, I'm happy to be faster, cheaper and more accurate than your
tenured corporate developer's solution of having some `LLM` do it.

<!-- [adopt skills you don't need yet](@/ramblings/adopt-stkills-you-dont-need-yet.md). TODO: LINKME -->

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

Your first question will likely be: _why bother_?  To which I shall raise the
[practical example](#a-practical-example) section.  And yeah, it supposes that
you dwell on the `CLI`, most specifically in <abbr title="The ubiquitous text
editor">Vim</abbr>.

> [!WARNING]
>
> As far as I can tell, the `GNU` implementation matches exactly the
> `POSIX` standard for `nl`.  However, only the short-form version of the
> flags is described in the `POSIX` specification: therefore `nl -w1` is
> `POSIX`-compliant, `nl --number-width=1` isn't.

Number lines from a file or the standard output with `nl`:

<div class="grid-1-2">

```txt,name=fruits.txt
Apricot
Apple

Banana

Cherry
Carrot?
```

<div>

```sh
nl fruits.txt
```
```txt
1  Apricot
2  Apple

3  Banana

4  Cherry
5  Carrot?
```
</div>
</div>

Target lines to be numbered with the `-bpBRE`
flag, matching against [basic regular
expressions](https://www.gnu.org/software/sed/manual/html_node/BRE-syntax.html):

<div class="grid-1-2">

```txt,name=ingredients.txt
Fruits:

- Apricot
- Banana
- Cherry

Others:

- Milk
- Egg
```
<div>

```sh
nl -bp: ingredients.txt
```
```txt
1  Fruits:

   - Apricot
   - Banana
   - Cherry

2  Others:

   - Milk
   - Egg
```
</div>
</div>

Get fancy with it! Specify a custom separator, starting number, increment value,
alignment, padding...

```sh
openssl rand --hex 128 | sed -r 's/.{4}/ \0/g;s/.{40}/\0\n/g' \
                       | nl -v0 -i10 -w8 -nrz -s:
```
```txt
00000000: 18be 2e82 3fc6 a77f da1a 7efa 26bc 1fa7
00000010: 7e51 c213 d975 957a 1446 1382 a7ca e346
00000020: 1b5d 3a37 b2cb 4319 ff98 5dae a93b 13e0
00000030: 6366 34e0 640d 5765 cbe7 51df 0780 d2a4
00000040: 3b41 2dfe 136a 372d 8278 1cdb cadc b598
00000050: a288 5621 04ce c6d9 3e9d 4c44 aadb 6c58
00000060: 39d5 ccf4 90aa e709 63a4 e2db 8ed0 4ea5
00000070: cdd6 5dd2 e555 24fd c3a8 d95b 38fb f8b6
```
{{ note(msg="my best effort at a one-line gibberish hex dump output") }}

<!-- TODO: use CAUTION rather than WARNING, here and everywhere else? -->

</div>

## Number lines with style

Let's start simple.  Just invoke `nl` with some filename, and it'll output its
contents, prefixed with some line-by-line numbering:

<div class="grid-1-2">

```txt,name=dailytasks.txt
Get up
Get coffee
Get to work
Get good
Get some sleep
```

<div>

```sh
nl dailytasks.txt
```
```txt
     1	Get up
     2	Get coffee
     3	Get to work
     4	Get good
     5	Get some sleep
```
</div>
</div>

Well, that's a bit awkward.  By default, it uses 6 characters for the line
number, right-aligned, and separates the rest of the content with a tabulation.

Less roomy? `--number-width`/`-w` allows you to specify the minimum number of
columns for the number, and `--separator`/`-s` allows you to specify the string
to separate the number from the content:

```sh
nl --number-width=1 --separator='.  ' dailytasks.txt
nl -w1 -s'.  ' dailytasks.txt
```
```txt
1.  Get up
2.  Get coffee
3.  Get to work
4.  Get good
5.  Get some sleep
```
{{ note(msg="would you look at that, a numbered list!") }}

> [!NOTE]
>
> **In no case will `nl` automatically adjust the width of the number column
> to fit the content**; it will always use at least as many as specified with
> `--number-width`/`-w`, but may use more if necessary.
>
> That limitation isn't a flaw of the tool, but a consequence of its operating
> mode: **it processes streams of data** and cannot apply any hindsight-based
> logic in its output.
>
> Knowing the minimum width of the number column would require a full pre-scan
> of the complete input, which would in turn break much more important features,
> such as the ability to process long-running tasks—not to mention the
> implications in terms of memory consumption.

### Dealing with alignment

The section above was the mere gist of it, the 90% of the use cases covered with
10% of the capabilities.  But since you're here, chances are you wouldn't mind
knowing the tools at your belt like the back of your hand.

We're going to want to see how it deals with numbers of varying width; let's try
with a more comprehensive file:

<div class="grid-1-2">
<div>

```sh
nl --number-width=1 --separator='.  ' dailytasks.txt
nl -w1 -s'.  ' dailytasks.txt
```
```txt
1.  Get up
2.  Make the bed
3.  Get coffee
4.  Make a plan
5.  Get to work
6.  Make an entrance
7.  Get good
8.  Make things happen
9.  Get some sleep
10.  Make ends meet
```
{{ note(msg="using a single column (`-w1`) makes `10` overflow") }}
</div>
<div>

```sh
nl --number-width=2 --separator='.  ' dailytasks.txt
nl -w2 -s'.  ' dailytasks.txt
```
```txt
 1.  Get up
 2.  Make the bed
 3.  Get coffee
 4.  Make a plan
 5.  Get to work
 6.  Make an entrance
 7.  Get good
 8.  Make things happen
 9.  Get some sleep
10.  Make ends meet
```
{{ note(msg="using `2` columns makes `10` fit comfortably") }}
</div>
</div>

<abbr title='interjection to mean: "look
here/there"'>Lookit</abbr>, a basic list of platitudes somewhat
[Oulipo](https://en.wikipedia.org/wiki/Oulipo)-worthy: however mundane a life I
lead, surely it isn't quite boring.

> [!IMPORTANT]
>
> Going forward, I'll be **implicitly** using `--separator`/`-s` with two spaces
> (`'  '`) for better readability, unless otherwise specified.

Having these numbers right-aligned with spaces are mere defaults that you may
override.  Use `--number-format`/`-n` to choose how the numbers are aligned:
`ln` for left-aligned, `rn` for right-aligned (the default), and `rz` for
right-aligned **padded with zeroes**.

<div class="grid-1-3">
<div>

```sh
nl --number-format=rn \
   --number-width=2   \
   dailytasks.txt
nl -w2 dailytasks.txt
```
```txt
 1  Get up
 2  Make the bed
 3  Get coffee
 4  Make a plan
 5  Get to work
 6  Make an entrance
 7  Get good
 8  Make things happen
 9  Get some sleep
10  Make ends meet
```
</div>
<div>

```sh
nl --number-format=ln \
   --number-width=2   \
   dailytasks.txt
nl -nln -w2 dailytasks.txt
```
```txt
1   Get up
2   Make the bed
3   Get coffee
4   Make a plan
5   Get to work
6   Make an entrance
7   Get good
8   Make things happen
9   Get some sleep
10  Make ends meet
```
</div>
<div>

```sh
nl --number-format=rz \
   --number-width=4   \
   dailytasks.txt
nl -nrz -w4 dailytasks.txt
```
```txt
0001  Get up
0002  Make the bed
0003  Get coffee
0004  Make a plan
0005  Get to work
0006  Make an entrance
0007  Get good
0008  Make things happen
0009  Get some sleep
0010  Make ends meet
```
</div>
</div>

> [!TIP]
>
> You may experience some awkward wincing when combining left-aligned
> justification with a separator that contains printable characters:
>
> ```sh
> nl -nln -w2 -s'.  ' numbers.txt
> ```
> ```txt
> ...
> 8 .  Eight
> 9 .  Nine
> 10.  Ten
> ```
>
> I would in general suggest that you **compose your mastery**, and consider
> tools that may be more suitable to the task.  For instance, in that case,
> `column` would work remarkably well!
>
> ```sh
> nl -w1 -s'.:' numbers.txt | column -ts:
> ```
> ```txt
> ...
> 8.   Eight
> 9.   Nine
> 10.  Ten
> ```
> {{ note(msg="[my article on `column`, `cut` and `paste`](@/flight-manual/intralinear-partitioning/02-column-cut-paste.md) may help make sense of that incantation, if necessary") }}

## Any [affine](https://en.wikipedia.org/wiki/Affine_transformation) function discretely defined over [ℕ](https://en.wikipedia.org/wiki/Natural_number)

Big words here, but the idea is simple: you needn't go from `1`, to `2`, to
`3`, _et cet._, all the way to your last line numbered "naturally".  You may
begin with any starting number and use any increment, (not strictly) positive or
negative, so long as they're integers.

Most typically, in the world of 2-dimensional graphs, we talk of **slope and
offsets**; in the world of software programming, we generally refer to these as
**start and step**.

> [!IMPORTANT]
>
> From now on, I'll be **implicitly** using `--separator`/`-s` with two spaces
> (`' '`), and the most adequate `--number-width`/`-w` for the output, unless
> otherwise specified.

Use `--starting-line-number`/`-v` to specify the starting number, and
`--line-increment`/`-i` to specify the increment (the step):

<div class="grid-1-2">
<div>

```sh
printf "%s\n" {a..f} | nl  \
  --starting-line-number=0 \
  --line-increment=2
printf "%s\n" {a..f} | nl -v0 -i2
```
```txt
 0  a
 2  b
 4  c
 6  d
 8  e
10  f
```
{{ note(msg="two by two, starting at `0`; the even numbers") }}
</div>
<div>

```sh
printf "%s\n" {a..f} | nl  \
  --starting-line-number=3 \
  --line-increment=-1
printf "%s\n" {a..f} | nl -v3 -i-1
```
```txt
 3  a
 2  b
 1  c
 0  d
-1  e
-2  f
```
{{ note(msg="why not also decrease?") }}
</div>
</div>

How about getting freaky?  We could make that daily routine from earlier look
like a proper timetable:

```sh
nl --starting-line-number=5 \
   --line-increment=2       \
   --number-width=2         \
   --number-format=rz       \
   --separator=':00 - '     \
   dailytasks.txt
nl -v5 -i2 -w2 -nrz -s':00 - ' dailytasks.txt
```
```txt
05:00 - Get up
07:00 - Make the bed
09:00 - Get coffee
11:00 - Make a plan
13:00 - Get to work
15:00 - Make an entrance
17:00 - Get good
19:00 - Make things happen
21:00 - Get some sleep
23:00 - Make ends meet
```

Or even have an inscrutable generator of some gibberish [hex
dump](https://en.wikipedia.org/wiki/Hex_dump):

```sh
openssl rand --hex 128 | sed -r 's/.{4}/ \0/g s/.{40}/\0\n/g' \
                       | nl -v0 -i10 -w8 -nrz -s:
```
```txt
00000000: 18be 2e82 3fc6 a77f da1a 7efa 26bc 1fa7
00000010: 7e51 c213 d975 957a 1446 1382 a7ca e346
00000020: 1b5d 3a37 b2cb 4319 ff98 5dae a93b 13e0
00000030: 6366 34e0 640d 5765 cbe7 51df 0780 d2a4
00000040: 3b41 2dfe 136a 372d 8278 1cdb cadc b598
00000050: a288 5621 04ce c6d9 3e9d 4c44 aadb 6c58
00000060: 39d5 ccf4 90aa e709 63a4 e2db 8ed0 4ea5
00000070: cdd6 5dd2 e555 24fd c3a8 d95b 38fb f8b6
```
{{ note(msg="look, ma! the `sed` addict couldn't keep it down for a single article!") }}

Keep your eyes on the ball, just the one `nl` call: the line numbering (the
leftmost block of `000000?0:`) is computed _somewhat soundly_—though it won't
hold up to much scrutiny, comes byte `160`, for which it'd show `00000100`
instead of `000000a0`.

Of these options, <abbr font="mono" title="--number-width">`-w`</abbr>,
<abbr font="mono" title="--separator">`-s`</abbr>, and <abbr font="mono"
title="--starting-line-number">`-v`</abbr> are definitely quite applicable,
while <abbr font="mono" title="--line-increment">`-i`</abbr> and <abbr
font="mono" title="--number-format">`-n`</abbr> see much less frequent use, to
me.

## Consider only the lines you want

> [!IMPORTANT]
>
> I'll continue to **implicitly** use `--separator`/`-s` with two spaces (`'
> '`), and the most adequate `--number-width`/`-w` for the output, unless
> otherwise specified.

There remains one entire class of flags that we haven't touched on yet: which
lines to number.  By default, **`nl` numbers all non-empty lines**.

```sh
printf "%s\n" {a..f} ''  hello world | nl -
```
```txt
1  a
2  b
3  c
4  d
5  e
6  f

7  hello
8  world
```
{{ note(msg="the empty line (`''`) isn't numbered and its following `hello` is only `1` greater than its preceding `f`") }}

### The concept of sections

Just before we get into the options to configure that, I feel compelled to
mention the _section_ mechanism of `nl`.  In short, it can distinguish between
the **header**, **body** and **footer** sections, but I find those somewhat too
esoteric[^too-esoteric] to be worth more than a mention and quick showcase:

   [^too-esoteric]: Sections are a nifty idea, but I find that in practice, I
massage my documents interactively and would systematically prefer invoking
tools on fragments of text rather than an entire document fitted into
arbitrarily sections.<br>
   Moreover, if I were to work like this, I'd still also much rather be able to
fully control the formatting, starting number, increment value, _et cet._ of
each section individually, which `nl` doesn't quite offer.

```sh
nl -fp'^\w*:$' <<EOF
\:\:\:
Mr. Austin Waugh                                  Birmingham, Christmas 1884

           An Accommodating Advertisement and an Awkward Accident
           ------------------------------------------------------
\:\:
Archibald Anderson, an able artist, and an acknowledged authority at all
artistic assemblies after adventuring abroad all about Australia and
America, and acquiring an admirable album artistically arranged, according
as an accomplished artist accounted apt and appropriate, and admired
amazingly among all artists as artistic and amusing, again, alleging as
actuation an assiduous and absorbing activity, and an ambition all athirst
after artistic accomplishments, and aiming at advantageous achievements,
arranged another adventure across Asia, and accordingly appointing an
accommodating and agreeable acquaintance, an affable Anglo-American, as
agent (active agents accurately advised and amptly authorised always
affording advantageous assistance, arranging affairs and adjusting articles,
and anticipating and arresting awkward and adverse annoyances [...]
\:
Reference:
https://en.wikisource.org/wiki/An_Accommodating_Advertisement_and_an_Awkward_Accident

Context:
Winning entry in Tit-Bits' magazine competition, Christmas 1884
EOF
```
```txt
    Mr. Austin Waugh                                  Birmingham, Christmas 1884

               An Accommodating Advertisement and an Awkward Accident
               ------------------------------------------------------

 1  Archibald Anderson, an able artist, and an acknowledged authority at all
 2  artistic assemblies after adventuring abroad all about Australia and
 3  America, and acquiring an admirable album artistically arranged, according
 4  as an accomplished artist accounted apt and appropriate, and admired
 5  amazingly among all artists as artistic and amusing, again, alleging as
 6  actuation an assiduous and absorbing activity, and an ambition all athirst
 7  after artistic accomplishments, and aiming at advantageous achievements,
 8  arranged another adventure across Asia, and accordingly appointing an
 9  accommodating and agreeable acquaintance, an affable Anglo-American, as
10  agent (active agents accurately advised and amptly authorised always
11  affording advantageous assistance, arranging affairs and adjusting articles,
12  and anticipating and arresting awkward and adverse annoyances [...]

 1  Reference:
    https://en.wikisource.org/wiki/An_Accommodating_Advertisement_and_an_Awkward_Accident

 2  Context:
    Winning entry in Tit-Bits' magazine competition, Christmas 1884
```
{{ note(msg="**don't number the _header_**, number **each line of the _body_** and **each item in the _footer_**") }}

Each section may use its own algorithm to determine **which lines to
number**, with <abbr font="mono" title="--body-numbering">`-b`</abbr>, <abbr
font="mono" title="--footer-numbering">`-f`</abbr>, and <abbr font="mono"
title="--header-numbering">`-h`</abbr>, for the **`b`ody**, **`f`ooter** and
**`h`eader**, respectively, and you may choose to reset (or not) the numbering
with each section.

### Targeting lines to number

By default, everything[^disable-section-matching] is considered part of the
_body_, thus `--body-numbering`/`-b` controls the general selection of lines to
number, unless you're using sections.

It, together with its `-h` and `-f` siblings, may take one of four forms:

- `a` to number **`a`ll lines**
- `t` to number only **non-empty lines** (`t` for **`t`ext**)
- `n` to number **`n`o lines**
- `pBRE` to number only lines matching the provided basic
  regular expression (abbreviated `BRE`, see [`GNU`'s excellent
  reference](https://www.gnu.org/software/sed/manual/html_node/BRE-syntax.html))

[^disable-section-matching]: By default, everything is the _body_, unless you
happen to have one line match the arcane sigils denoting a specific section,
either of `\:\:\:`, `\:\:`, or `\:` (again, by default) on a line of their
own.  Just to be sure, you may disable section shenanigans altogether by setting
`--section-delimiter`/`-d` to the empty string: `-d''`, or just `-d`.

By default, only the body shall be numbered, and it will use the `t` selection,
ignoring blank lines in the count.

```sh
{
  echo '\:\:\:'; seq 1 3 | xargs -n1 printf "header #%s\n"
  echo '\:\:';   seq 1 5 | xargs -n1 printf "body   #%s\n" | sed '3s/.*//'
  echo '\:';     seq 1 3 | xargs -n1 printf "footer #%s\n"
} | nl
```
```txt
   header #1
   header #2
   header #3

1  body   #1
2  body   #2
   
3  body   #4
4  body   #5

   footer #1
   footer #2
   footer #3
```
{{ note(msg="the line #3 of the body was made blank, and is therefore not numbered") }}

So, let's give these options a spin!

<div class="grid-1-3">
<div>

```sh
nl --body-numbering=t dailytasks.txt
nl -bt dailytasks.txt
nl dailytasks.txt
```
```txt
 1  Get up
 2  Make the bed

 3  Get coffee
 4  Make a plan

 5  Get to work
 6  Make an entrance

 7  Get good
 8  Make things happen

 9  Get some sleep
10  Make ends meet
```
{{ note(msg="number **lines with `t`ext**") }}
</div>
<div>

```sh
nl --body-numbering=a dailytasks.txt
nl -ba dailytasks.txt

```
```txt
 1  Get up
 2  Make the bed
 3  
 4  Get coffee
 5  Make a plan
 6  
 7  Get to work
 8  Make an entrance
 9  
10  Get good
11  Make things happen
12  
13  Get some sleep
14  Make ends meet
```
{{ note(msg="number **`a`ll lines**") }}
</div>
<div>

```sh
nl --body-numbering=n dailytasks.txt
nl -bn dailytasks.txt

```
```txt
   Get up
   Make the bed
   
   Get coffee
   Make a plan
   
   Get to work
   Make an entrance
   
   Get good
   Make things happen
   
   Get some sleep
   Make ends meet
```
{{ note(msg="number **`n`o lines**") }}
</div>
</div>

Most often, the default is fairly close to what I want.  I don't mind typing the
extra `-w1` or `-s:` here and there and generally further sanitise the output
interactively, either manually or in a pipeline; but you may choose to, say,
`alias` it with the defaults that suit you.

Now that the frivolities are out of the way, let's get to the final
piece, the one that actually feels more smooth to apply than some
combination of [`<C-V>I`](https://vimhelp.org/visual.txt.html#v_b_I) and
[`g<C-A>`](https://vimhelp.org/change.txt.html#v_g_CTRL-A), or some possibly
semi-awkward macro recording: discernment in line selection.

<!-- [vim increment and decrement](@/ramblings/vim-increment-decrement.md). TODO: LINKME -->

```sh
nl --body-numbering=p^Get --separator='. ' dailytasks.txt
nl -bp^Get -s.\  dailytasks.txt
```
```txt
1. Get up
   Make the bed

2. Get coffee
   Make a plan

3. Get to work
   Make an entrance

4. Get good
   Make things happen

5. Get some sleep
   Make ends meet
```
{{ note(msg="number lines that match the **`p`attern: `^Get`** (starting with `Get`)") }}

I'll admit that this doesn't sound like much just yet, but how else would you
intelligently number your bit and bobs?  Manually doing it isn't so bad, that's
true.  Installing a plug-in to your `IDE` certainly is[^why-not-a-plugin]
however, so why not open up your mind to more options in manipulating your data?
You have the tool, I say use it.

   [^why-not-a-plugin]: Here's why not "just install a plug-in": do you review
the code of said plug-ins, all of them, when you install them?  Do you at
least check out their repository, get a sense of the professionalism of its
maintainer(s) and the scrutiny of its community?  Do you make sure that the
product you found on that plug-in marketplace is indeed compiled from the
repository you found of the same name?<br><br>
   I do.  But you see, answering "yes" here doesn't actually mean "yes" to the
question of whether installing a plug-in to that effect is a good idea: it still
isn't.  Because the moment of installation isn't the only time a malicious piece
of code is susceptible to sneak in.  In fact, it's possibly the _least_ likely
time for that: the incessant upgrades are the worst offenders.  You wouldn't
have your `IDE` automagically update the third-party software that runs on your
precious files, do you?<br><br>
   So, either you can't be confident that the stuff you run isn't harmful, or
you commit each time to one more project to review, for perpetuity, with each
upgrade of each plug-in.  As somebody who chose the latter, I can confidently
tell you that my incentive to not adopt plug-ins I don't need is quite strong!

## A practical example {#a-practical-example}

Consider the following bit of text:

```txt
Philosophy -----------------------------------------------------------

- I don't want on my screen information that I don't need.
- I don't want to install more software:
I'd rather master and compose [6] the underlying tools.
- Corollary: I don't want to tweak software to best suit my tastes,
I'd rather adopt their defaults if they're sane.
- I don't mind symlinks.
- There's a difference between newbie-friendly and user-friendly;
the very best tools are user-friendly.
- A project that receives (little to) no new issues and commits isn't
abandoned, it is *done*.

References -----------------------------------------------------------

https://en.wikipedia.org/wiki/Less_is_more
https://git-scm.com/
https://www.gnu.org/software/stow/
https://specifications.freedesktop.org/basedir-spec/latest/
https://wiki.archlinux.org/title/PAM
https://en.wikipedia.org/wiki/Unix_philosophy
```

I'd like to spruce it up.  Let's start with the `References` section.  Place
your cursor anywhere in there, then `vip`, `:norm i[0]: `, `gvg<C-A>`:

<div class="grid-1-2">
<div>

```txt
https://en.wikipedia.org/wiki/Less_is_more
https://git-scm.com/
https://www.gnu.org/software/stow/
https://specifications.freedesktop.org/basedir-spec/latest/
https://wiki.archlinux.org/title/PAM
https://en.wikipedia.org/wiki/Unix_philosophy
```
{{ note(msg="4 seconds before") }}
</div>
<div>

```txt
[1]: https://en.wikipedia.org/wiki/Less_is_more
[2]: https://git-scm.com/
[3]: https://www.gnu.org/software/stow/
[4]: https://specifications.freedesktop.org/basedir-spec/latest/
[5]: https://wiki.archlinux.org/title/PAM
[6]: https://en.wikipedia.org/wiki/Unix_philosophy
```
{{ note(msg="after `vip:norm i[0]: <CR>gvg<C-A>`") }}
</div>
</div>

Onto the `Philosophy` section.  Here, it's a simple matter of `!ip`, `nl -bp^-
-w1 -s.\ `, then `gv:s/- /`:

<div class="grid-1-2">
<div>

```txt
- I don't want on my screen information that I don't need.
- I don't want to install more software:
I'd rather master and compose [6] the underlying tools.
- Corollary: I don't want to tweak software to best suit my tastes,
I'd rather adopt their defaults if they're sane.
- I don't mind symlinks.
- There's a difference between newbie-friendly and user-friendly;
the very best tools are user-friendly.
- A project that receives (little to) no new issues and commits isn't
abandoned, it is *done*.
```
{{ note(msg="8 seconds before") }}
</div>
<div>

```txt
1. I don't want on my screen information that I don't need.
2. I don't want to install more software:
   I'd rather master and compose [6] the underlying tools.
3. Corollary: I don't want to tweak software to best suit my tastes,
   I'd rather adopt their defaults if they're sane.
4. I don't mind symlinks.
5. There's a difference between newbie-friendly and user-friendly;
   the very best tools are user-friendly.
6. A project that receives (little to) no new issues and commits isn't
   abandoned, it is *done*.
```
{{ note(msg="after `!ipnl -bp^- -w1 -s.\ <CR>gv:s/- /`") }}
</div>
</div>

And for the [coup de grâce](https://en.wikipedia.org/wiki/Coup_de_gr%C3%A2ce),
just strike with a final `nl -w2 -nrz -bp---- -s.\ ` on the entire content,
`!%`:

<div class="grid-1-2">
<div>

```txt
Philosophy -----------------------------------------------------------

1. I don't want on my screen information that I don't need.
2. I don't want to install more software:
   I'd rather master and compose [6] the underlying tools.
3. Corollary: I don't want to tweak software to best suit my tastes,
   I'd rather adopt their defaults if they're sane.
4. I don't mind symlinks.
5. There's a difference between newbie-friendly and user-friendly;
   the very best tools are user-friendly.
6. A project that receives (little to) no new issues and commits isn't
   abandoned, it is *done*.

References -----------------------------------------------------------

[1]: https://en.wikipedia.org/wiki/Less_is_more
[2]: https://git-scm.com/
[3]: https://www.gnu.org/software/stow/
[4]: https://specifications.freedesktop.org/basedir-spec/latest/
[5]: https://wiki.archlinux.org/title/PAM
[6]: https://en.wikipedia.org/wiki/Unix_philosophy
```
{{ note(msg="4 seconds before") }}
</div>
<div>

```txt
01. Philosophy -----------------------------------------------------------
    
    1. I don't want on my screen information that I don't need.
    2. I don't want to install more software:
       I'd rather master and compose [6] the underlying tools.
    3. Corollary: I don't want to tweak software to best suit my tastes,
       I'd rather adopt their defaults if they're sane.
    4. I don't mind symlinks.
    5. There's a difference between newbie-friendly and user-friendly;
       the very best tools are user-friendly.
    6. A project that receives (little to) no new issues and commits isn't
       abandoned, it is *done*.
    
02. References -----------------------------------------------------------
    
    [1]: https://en.wikipedia.org/wiki/Less_is_more
    [2]: https://git-scm.com/
    [3]: https://www.gnu.org/software/stow/
    [4]: https://specifications.freedesktop.org/basedir-spec/latest/
    [5]: https://wiki.archlinux.org/title/PAM
    [6]: https://en.wikipedia.org/wiki/Unix_philosophy
```
{{ note(msg="after `!%nl -w2 -nrz -bp---- -s.\ `") }}
</div>
</div>

Not bad for 16 seconds of work that felt more like a delightful mini
puzzle-solving session!

If you doubt that's 16 seconds, you should sit closer to your most savvy
colleagues more often; and if you think this trick was worth writing home about,
wait until I tell you of [`par`](http://www.nicemice.net/par/)—in any case,
good luck, and **have fun**.

P.S. Merry Christmas!
