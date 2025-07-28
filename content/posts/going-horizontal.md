+++
title = 'Laying text out horizontally'
date = 2025-07-25
description = 'Putting chunks of text side by side'
+++

Professionally, I put code together. Intimately, I am compelled to make it neat:
one of the ways I achieve this is by wielding non-printable characters like
monochrome photography uses light, with *purpose* and finesse.

The current status quo regarding white-space limits our stylistic devices:

- vertically to the linefeed [^esoteric-vertical-whitespace]—coalescing into
  blank lines, to pack together logical blocks of data or instructions, and
- horizontally to the beginning of the line—in the form of
  indentation, to delineate the hierarchy of our otherwise strictly
  vertically-topologically-laid-out content.

But here's the thing: the taxonomy of text shouldn't be limited to paragraphs
and lines.  
Let's go bidimensional!

[^esoteric-vertical-whitespace]: Let's not talk of
the [CR](https://www.compart.com/en/unicode/U+000D),
[VT](https://www.compart.com/en/unicode/U+000B) or
[FF](https://www.compart.com/en/unicode/U+000C) here.

## The few forms of horizontal alignment

In the wild, I identified four classes of occurrences begging for what I shall
call *intralinear partitioning*—though you don't need to worry, I won't call
it that again... Surely.  Let's recognise, appreciate, celebrate and reproduce
them!

### Lists in a grid

Collections of items may very well be one-dimensional, but it turns out that
organising them in a grid is quite natural, unless you're a stock exchange
banner designer, of course, but then I believe that the idea is indeed to have
the list forever scrolling: I suppose keeping it linear lets you conceal the
finiteness of your data.

Here's the output of `ls`, a specimen I'm sure you've come across before:

```sh
ls -F
ls --classify
```

```txt
node_modules/  compose.sh*  eslint.config.mjs  package.json    README.md
src/           Dockerfile   LICENSE            pnpm-lock.yaml  TODO
```

I've you've got a list of items begging to fit on a single page, you can lay
them out in a grid with `column`[^column]:

[^column]: {{ cmd(name="column", repo = "https://github.com/util-linux/util-linux", package="core/x86_64/util-linux") }}

```sh
echo $PATH | tr : $'\n' | column
```

```txt
/home/ccjmne/bin	/usr/local/sbin		/usr/bin/core_perl
/usr/local/bin		/usr/bin/site_perl	/usr/lib/rustup/bin
/usr/bin		/usr/bin/vendor_perl	/home/ccjmne/share/pnpm
```

Note that `column` wants to output columns of unique width, regardless of their
individual content.  
By default, it uses tabulations, but you may have it use spaces with the
`-S|--use-spaces` flag, which takes the minimum number of whitespaces that
separate two columns:


```sh
seq 100 150 | column
```

```txt
100	106	112	118	124	130	136	142	148
101	107	113	119	125	131	137	143	149
102	108	114	120	126	132	138	144	150
103	109	115	121	127	133	139	145
104	110	116	122	128	134	140	146
105	111	117	123	129	135	141	147
```

```sh
seq 100 150 | column -S2
seq 100 150 | column --use-spaces 2
```

```txt,name=column -S2
100  104  108  112  116  120  124  128  132  136  140  144  148
101  105  109  113  117  121  125  129  133  137  141  145  149
102  106  110  114  118  122  126  130  134  138  142  146  150
103  107  111  115  119  123  127  131  135  139  143  147
```

Unless instructed otherwise, it will fill its grid column by column, but you can
also have it go row-first by using `-x|--fillrows`:

```sh
seq 100 150 | column -xS2
seq 100 150 | column --fillrows --use-spaces 2
```

```txt
100  101  102  103  104  105  106  107  108  109  110  111  112  113  114  115
116  117  118  119  120  121  122  123  124  125  126  127  128  129  130  131
132  133  134  135  136  137  138  139  140  141  142  143  144  145  146  147
148  149  150
```

Avoiding the `-x` flag yields grids that are generally more evenly packed, if
your display is wide enough to accommodate more of your items as you'd need rows
to fit them all.  Either case will use exactly as many rows as necessary.
