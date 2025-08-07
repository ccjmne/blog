+++
title = 'Intralinear partitioning (part 1 of 3)'
date = 2025-07-25
description = 'Laying text out horizontally'
+++

<div style="background: #ccc; margin: 0 -2em; padding: .1px 2em;">

### Preamble

This 3-part article concerns itself with putting chunks of text side by side.

1. This first, rambly piece addresses the *what* and *why*,
2. the second goes over the practical use of some <abbr font="mono"
   title="Command Line Interface, where I dwell">CLI</abbr> tools indispensable
   to the task, and
3. the third and final chapter will share some quite nifty <abbr font="mono"
   title="The ubiquitous text editor">`Vim`</abbr>[^vim] tricks to the same end.
</div>

[^vim]: {{ cmd(name="vim", repo="https://github.com/vim/vim", package="extra/x86_64/vim", manual="https://vimhelp.org/") }}
        {{ cmd(name="neovim", repo="https://github.com/neovim/neovim", package="extra/x86_64/neovim", manual="https://neovim.io/doc/user/") }}

## Introduction

   Professionally, I put code together. Intimately, I am compelled to make
it neat: I get closer to that goal by wielding non-printable characters like
monochrome photography uses light, with *purpose*.

   The current status quo regarding whitespace, in my line of work, limits our
stylistic expression:

- vertically to the linefeed[^esoteric-vertical-whitespace] (coalescing into
  blank lines), to pack together logical blocks of data or instructions, and
- horizontally to the beginning of the line (in the form of
  indentation), to delineate the hierarchy of our otherwise strictly
  vertically-topologically-laid-out content.

 But here's the thing: the taxonomy of text shouldn't be limited to paragraphs
and lines.<br>
   Let's go bidimensional!

[^esoteric-vertical-whitespace]: Let's not talk of
the [CR](https://www.compart.com/en/unicode/U+000D),
[VT](https://www.compart.com/en/unicode/U+000B) or
[FF](https://www.compart.com/en/unicode/U+000C) here.

## The few forms of horizontal alignment

   In the wild, I identified four classes of occurrences itching for what I
shall refer to as *intralinear partitioning* (I promise, it's the last time I
call it that).  In this article, we'll appreciate and learn to reproduce the
first three.

### The list in a grid

   Collections of items are quite happily organised in a grid, unless you're a
stock exchange ticker tape designer, of course.  As such, so long as you want to
*present* your data rather than have it seemingly scroll forever, the matrix is
a practical ally, Neo.

   For illustration, here's the output of <abbr font="mono" title="List
directory contents">`ls`</abbr>, a specimen I'm sure you've come across before:

```sh
ls -F
ls --classify
```
```txt
node_modules/  compose.sh*  eslint.config.mjs  package.json    README.md
src/           Dockerfile   LICENSE            pnpm-lock.yaml  TODO
```
{% note(type="comment") %} I use `--classify`/`-F` to annotate various file types, like executables and directories {% end %}

### The tabular data

   This one needs no introduction, yet the only example that came to mind is
that of probing `uni`[^uni] for whatever fantastical sigil I last came across:

[^uni]: {{ cmd(name="uni", repo="https://github.com/arp242/uni", package="aur/uni", manual="https://github.com/arp242/uni/#usage") }}

```sh
uni i ÉÉ🧉
uni identify É É 🧉
```
```txt
             Dec    UTF8        HTML       Name
'E'  U+0045  69     45          &#x45;     LATIN CAPITAL LETTER E
'◌́'  U+0301  769    cc 81       &#x301;    COMBINING ACUTE ACCENT
'É'  U+00C9  201    c3 89       &Eacute;   LATIN CAPITAL LETTER E WITH ACUTE
'🧉' U+1F9C9 129481 f0 9f a7 89 &#x1f9c9;  MATE DRINK
```
{% note(type="comment") %} Ah, so that's why I appear twice in <abbr font='mono' title-font='reset' title='Summarize &apos;git log&apos; output'>git shortlog</abbr>` --summary`... {% end %}

### The adjoined fragments

   Finally, there's data that's not quite tabular enough to be called that...
yet!  This final section of the article is where you finally get some bang
for your buck: we'll try our hands at putting chunks of text next to one
another.<br>
   The `paste`[^paste] utility lets you join lines from multiple files:

[^paste]: {{ cmd(name="paste", repo="https://github.com/coreutils/coreutils", package="core/x86_64/coreutils", manual="https://man.archlinux.org/man/paste.1.en") }}
