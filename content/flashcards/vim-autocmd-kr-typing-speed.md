+++
title = 'An `autocmd` to track my 두벌식 typing progress'
date = 2026-07-12
description = """Using **a single line in my `vimrc`**, I get to merely type in my time and have Vim compute the corresponding <abbr title="Words Per Minute">`wpm`</abbr>, annotate that with the current date and align with the rest of the table"""
taxonomies.section = ['flashcards']
taxonomies.tags = ['all', 'vim', '한국어']
extra.cited_tools = ['column', 'vim']
+++

I started learning 한국어 (the Korean language) some weeks ago, and have
set out to get comfortable with typing as well.  I settled on using the
standard 두벌식 (literally: _"two-set style"_) layout; it's the standard,
the `QWERTY` of Korean layouts.  In my relentless quality of data-driven
engineer, I figured I'd like to track my progress, and set out to maintain a
table of the speed at which I complete a run of 100 simple Korean words using
[_Monkeytype_](https://monkeytype.com/).

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

I record my times for typing 100 Korean words in a plain text file that looks like:

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  10.9
2026-07-07  08:27  11.8
2026-07-08  08:40  11.5
2026-07-10  08:39  11.6
2026-07-11  07:49  12.8
2026-07-11  08:32  11.7
2026-07-11  06:14  16.0
```

But I wish not to compute the <abbr title="Words Per Minute">`wpm`</abbr> in my
head, and I find typing the date to be tedious as well: I want to put in my
time and have Vim do the rest.  Within minutes, my `vimrc` acquired a new line:

```vim
au InsertLeave kr100 norm! ^"=strftime("%F  ")^MPw"ayiwE"byiw"=printf("  %.1f", 100/(^Ra+^Rb/60.0))^Mp
```
{{ note(msg="however arcane this looks, it really isn't any more intricate than your average `Reg`ular `Exp`ression") }}

> [!IMPORTANT]
>
> I write here `^R` and `^M`, but these aren't a literal caret,
> followed by a literal `R` or `M`: these are the bytes that correspond
> to `Ctrl`+`R` and `Ctrl`+`M` (Enter), respectively.  They're
> entered in Vim by pressing `Ctrl`+`V` beforehand, see [`:help
> i_CTRL-V`](https://vimhelp.org/insert.txt.html#i_CTRL-V).

And now, whenever I open that one file, I simply type in my time, and Vim does
the rest!

Let's go over that incantation above, and demystify its sigils together.

<div class="grid-1-2">
<div>

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  10.9
2026-07-07  08:27  11.8
2026-07-08  08:40  11.5
2026-07-10  08:39  11.6
2026-07-11  07:49  12.8
2026-07-11  08:32  11.7
2026-07-11  06:14  16.0
07:19
```
{{ note(msg="adding a new time on the last line...") }}

</div>
<div>

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  10.9
2026-07-07  08:27  11.8
2026-07-08  08:40  11.5
2026-07-10  08:39  11.6
2026-07-11  07:49  12.8
2026-07-11  08:32  11.7
2026-07-11  06:14  16.0
2026-07-12  07:19  13.7
```
{{ note(msg="it gets automatically adopted!") }}

</div>
</div>
</div>

> [!TIP]
>
> My current _Monkeytype_ configuration is reproducible as follows:
>
> On _Monkeytype_, press `Esc`ape and type `korean` to switch to a simple Korean
> dictionary, then repeat with `100 words` to set the target to be a word count
> of 100, and finally, use the `typo both` query to turn on the most complete
> typo highlighting mechanism—of great value when you aren't yet able to
> recognise all the fairly mundane words it'll use.

## In the beginning, there was a table

I created a file in my `$XDG_DATA_HOME`[^xdg-directories-spec], which I
unceremoniously called `kr100`, and recorded my first entry:

[^xdg-directories-spec]: Oh, I do very much like the [`XDG` Base Directories
Specification](https://specifications.freedesktop.org/basedir/latest/).  Remind
me to make a blog post about it!
<!-- [XDG Base Directories specification](@/flashbards/xdg-base-directories). TODO: LINKME -->

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  12
```
{{ note(msg="Yeah, that's not fast alright") }}

> [!TIP]
>
> For the record, I only typed:
>
> ```txt,name=kr100
> date time wpm
> ---- ---- ---
> 2026-07-07 09:11 12
> ```
>
> Then I used `!ipcolumn -t` to automagically align it all in a neat table,
> using the `column` utility—find its `man`ual at the bottom of this blog
> post, as usual.

  But then, I realised that _Monkeytype_ would actually round up the <abbr
title="Words Per Minute">`wpm`</abbr>.  That's generally not much of an issue,
since we generally type at over 100 `wpm`, but for this current case, I thought
it too imprecise.<br>
  Moreover, I am indeed so slow that it considered many seconds to constitute
<abbr title="Away From Keyboard">`AFK`</abbr> (idle) time and **computed my
`wpm` as if I hadn't been painstakingly scratching my head** all throughout the
session, resulting in a largely inflated statistic: that simply won't do.

## The expression register: `"=`

So, I'll have to have Vim calculate it.  Thankfully, that's
trivially resolved through the use of [**the expression register,
`"=`**](https://vimhelp.org/change.txt.html#quote%3D).  With this handy tool, use
`=100/(9+11/60.0)` to calculate your accurate `wpm`, considering that the time
there (`9` minutes and `11` seconds) was indeed for `100` words, and voilà:

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  10.889292
```
{{ note(msg="A most accurate `wpm`—though perhaps <abbr title="the adverbial form, not a typo">unwieldily</abbr>[^unwieldily] so?") }}

Well, that's a bit too precise, now.  Run it through `printf("%.1f", ...)` to
format it to **one decimal place**:

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  10.9
```
{{ note(msg='`10.9` here is the result of evaluating `printf("%.1f", 100/(9+11/60.0))` through `"=`') }}

> [!TIP]
>
> You can search available functions using [`:help
> function-list`](https://vimhelp.org/usr_41.txt.html#function-list)!  As far
> as I can tell, those that correspond to the `POSIX` or `C` built-ins are also
> implemented similarly (that is, they likely end up actually calling the `C`
> ones under the hood): you may therefore consult the *third section of the
> `man`ual to get familiar with their most intricate idiosyncrasies!
>
> That is, how to pilot Vim's `strftime`? [`:help
> strftime`](https://vimhelp.org/builtin.txt.html#strftime%28%29) gets you
> started, `man 3 strftime` gives you the whole _minutiae_.

Yep.  I know what you're thinking, and I agree: _"ain't nobody got time for
that"_.  Let's just script it!  And while we're at it, how about having it type
out the date as well?

## Automating anything with `autocmd`

Let's get started:

```vim
autocmd InsertLeave <buffer> normal! B"ayiwE"byiw"=printf("  %.1f", 100/(^Ra+^Rb/60.0))^Mp
```
{{ note(msg="I like to start off with what essentially amounts to a finished product `:-)`") }}

> [!IMPORTANT]
>
> I write here `^R` and `^M`, but these aren't a literal caret,
> followed by a literal `R` or `M`: these are the bytes that correspond
> to `Ctrl`+`R` and `Ctrl`+`M` (Enter), respectively.  They're
> entered in Vim by pressing `Ctrl`+`V` beforehand, see [`:help
> i_CTRL-V`](https://vimhelp.org/insert.txt.html#i_CTRL-V).

This creates an
[`autocommand`](https://vimhelp.org/autocmd.txt.html#autocommand)
whenever we are done `i`nserting text (see [`:help
InsertLeave`](https://vimhelp.org/autocmd.txt.html#InsertLeave)) in the current
buffer, and executes the following:

```vim
  autocmd InsertLeave <buffer> normal! B"ayiwE"byiw"=printf("  %.1f", 100/(^Ra+^Rb/60.0))^Mp
" ├─────┘ ├─────────┘ ├──────┘ ├────────────────────────────────────────────────────────────┘
" │       │           │        └─ execute these normal-mode keystrokes literally
" │       │           └─ only in the current buffer
" │       └─ when leaving insert mode
" └─ define an autocommand
```
{{ note(msg="the anatomy of our `autcommand`") }}

Ah, I've got some time on my end, I'll even give you the detail of what the
`normal` statement does:

```txt
B  "ayiw  E  "byiw  $  "=  printf("  %.1f", 100/(^Ra+^Rb/60.0))  ^M  p
│  ├───┘  │  ├───┘  │  ├┘  │       register [a] ─┴─┘ ├─┘      │  ├┘  │
│  │      │  │      │  │   │           register [b] ─┘        │  │   └─ [p]ut result at cursor location
│  │      │  │      │  │   ├──────────────────────────────────┘  └─ press Enter to complete
│  │      │  │      │  │   └─ statement in expression register
│  │      │  │      │  └─ start expression register (`"=`)
│  │      │  │      └─ jump to end of line
│  │      │  └─ [y]ank [i]nner [w]ord into ["b] (register b)
│  │      └─ jump to [E]nd of WORD
│  └─ [y]ank [i]nner [w]ord into ["a] (register a)
└─ jump [B]ackwards to start of WORD
```
{{ note(msg="Vim artistry at its finest—and they say `Reg`ular `Exp`ressions are inscrutable?!") }}

> [!TIP]
>
> It may seem daunting, but it should become second nature to any seasoned
> Vim user.  Besides, **you do not really have to even write it in the first
> place**: you could simply **record it** as a macro, then paste the content of
> that macro ([`:help q`](https://vimhelp.org/repeat.txt.html#recording)) right
> there in your file!
>
> However, being able to understand and amend it certainly does help.

For good measure, let's add `^"=strftime("%F  ")^MP` to that `autocommand`, so
as to automatically print the date in the desired format as well.

So, here's what we're currently working with:

```vim
autocmd InsertLeave <buffer> normal! ^"=strftime("%F  ")^MPw"aywE"byw$"=printf("  %.1f", 100/(^Ra+^Rb/60.0))^Mp
```
{{ note(msg="I did replace what was previously a `B` with a `w` to instead go forward to the next `w`ord") }}

Execute that, then enter `i`nsert mode and add a new time on a new line...

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  12
08:40
```
{{ note(msg="currently typing `08:40`, in `i`nsert mode") }}

Then, return to `n`ormal mode, with `Esc`ape (or `Ctrl`+`[`, or however else you
do that), and see your buffer magically turn into:

```txt,name=kr100
date        time   wpm
----        ----   ---
2026-07-07  09:11  10.9
2026-07-08  08:40  11.5
```
{{ note(msg="and just as you're done typing... gasp!") }}

Just like that, our measly `08:40` was prefaced with today's date,
`2026-07-08`, then annotated with the corresponding <abbr title="Words Per
Minute">`wpm`</abbr> value, duly computed and rounded to one decimal place.  The
whole line is aligned so as to fit with the rest of the table, too!

And this doesn't work just once; it works for any data entered in the current
buffer.

## Always run for that specific file

We've got something perfectly serviceable: we only have to type our new time,
and the file formats itself...  **So long as that `autocommand` is registered**.
To enable it every time you open this file, just drop it in your `vimrc` and
change its target from `<buffer>` to the actual file in question; in our case:
`kr100`:

```vim
au InsertLeave kr100 norm! ^"=strftime("%F  ")^MPw"ayiwE"byiw"=printf("  %.1f", 100/(^Ra+^Rb/60.0))^Mp
```
{{ note(msg="I took the liberty of contracting `au[tocmd]` and `norm[al]`: these became natural to me") }}

And there you have it.  As soon as, and as long as this simple one-liner
is executed anytime you start Vim, this specific `kr100` file will know to
automatically transform your new time entries into that tabular format we
settled on.

> [!NOTE]
>
> This isn't exactly a [golfed](https://en.wikipedia.org/wiki/Code_golf)
> solution: I could, for instance, not use `i` in the first `yiw` and save
> myself one character, but I merely have my habits and don't mind consistently
> using `yiw` when I mean to copy one word.  Be sharp, but by all means: **use
> what works for you**.

## Going further

That's all there is to it.

Really, with the help of some savvy macro recording and macro-register
inspection, putting this together is a breeze.  Well, it does suppose that
you've acquired some mastery of the underlying tools and system, have a good
idea of what's feasible and how to do it: perhaps this is where a most capable
`CLI` dweller distinguishes themselves most from your run-of-the-mill "senior"
software developer?

As always, good luck, and have fun!
