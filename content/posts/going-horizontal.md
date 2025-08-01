+++
title = 'Laying text out horizontally'
date = 2025-07-25
description = 'Putting chunks of text side by side'
+++

   Professionally, I put code together. Intimately, I am compelled to make
it neat: I get closer to that goal by wielding non-printable characters like
monochrome photography uses light, with *purpose* and finesse.

   In my line of work, the current status quo regarding whitespace limits our
stylistic expression:

- vertically to the linefeed[^esoteric-vertical-whitespace] (coalescing into
  blank lines), to pack together logical blocks of data or instructions, and
- horizontally to the beginning of the line (in the form of
  indentation), to delineate the hierarchy of our otherwise
  strictly vertically-topologically-laid-out content.

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
a practical ally.

   For illustration, here's the output of `ls`, a specimen I'm sure you've come
across before:

```sh
ls -F
ls --classify
```
```txt
node_modules/  compose.sh*  eslint.config.mjs  package.json    README.md
src/           Dockerfile   LICENSE            pnpm-lock.yaml  TODO
```

   If your items are begging to fit on a single screenful of text, you can lay
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

   Note that `column` wants to print out columns of unique width, regardless of
their individual content.<br>
   By default, it uses tabulations, but you may have it use spaces with the
<abbr font="mono" title="-S">--use-spaces</abbr> flag, which takes the minimum
number of whitespaces to separate columns by:

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

   Unless instructed otherwise, it will fill its grid column by column,
but you can also have it go row-first by using <abbr font="mono"
title="-x">--fillrows</abbr>

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

   Avoiding the <abbr font="mono" title="-x">--fillrows</abbr> flag yields
grids that are generally more evenly packed, provided that your display is wide
enough to accommodate more of your items as you'd need rows to contain them all.
Either case will use exactly as many rows as necessary.

### The tabular data

   This one needs no introduction, yet the only example that came to mind is
that of probing `uni`[^uni] for whatever fantastical sigil I last came across:

[^uni]: {{ cmd(name="uni", repo = "https://github.com/util-linux/util-linux", package="core/x86_64/util-linux") }}

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
Ah, so that's why I appear twice in `git shortlog` <abbr font="mono" title="-s">--summary</abbr>...

   If you find yourself wanting to create such table, `column`[^column] again
has got you covered: use its <abbr font="mono" title="-t">--table</abbr> flag to
have it create or manipulate tabular data.<br>
   Have a look at `/etc/passwd`:

```sh
head -7 /etc/passwd
head --lines 7 /etc/passwd
```
```txt
root:x:0:0::/root:/bin/bash
bin:x:1:1::/:/usr/bin/nologin
daemon:x:2:2::/:/usr/bin/nologin
mail:x:8:12::/var/spool/mail:/usr/bin/nologin
ftp:x:14:11::/srv/ftp:/usr/bin/nologin
http:x:33:33::/srv/http:/usr/bin/nologin
nobody:x:65534:65534:Kernel Overflow User:/:/usr/bin/nologin
```

   (You may nod in approval of the startling absence of an
overwhelmingly mundane <abbr font="mono" title="Useless Use Of
Cat">[UUOC](@/posts/first.md)</abbr>)

Watch it now blossom into its intended form, fit for human consumption:

```sh
head -7 /etc/passwd | column -ts:
head --lines 7 /etc/passwd | column --table --separator :
```
```txt
root    x  0      0                            /root            /bin/bash
bin     x  1      1                            /                /usr/bin/nologin
daemon  x  2      2                            /                /usr/bin/nologin
mail    x  8      12                           /var/spool/mail  /usr/bin/nologin
ftp     x  14     11                           /srv/ftp         /usr/bin/nologin
http    x  33     33                           /srv/http        /usr/bin/nologin
nobody  x  65534  65534  Kernel Overflow User  /                /usr/bin/nologin
```

   But that's not all: `column` really lets you manipulate that data table in
a myriad of ways.  Name columns, shuffle them around, wrap them, hide them...
Have at it!

```sh
column --table                                                      \
       --separator     :                                            \
       --table-columns User,Password,UID,GID,Description,Home,Shell \
       --table-hide    Password,GID,Description                     \
       --table-right   UID                                          \
       <(head -7 /etc/passwd)
```
```txt
User      UID  Home             Shell
root        0  /root            /bin/bash
bin         1  /                /usr/bin/nologin
daemon      2  /                /usr/bin/nologin
mail        8  /var/spool/mail  /usr/bin/nologin
ftp        14  /srv/ftp         /usr/bin/nologin
http       33  /srv/http        /usr/bin/nologin
nobody  65534  /                /usr/bin/nologin
```

   Although, the above is rather extreme: I generally limit
myself the <abbr font="mono" title="--table">-t</abbr>, <abbr
font="mono" title="--separator">-s</abbr> and <abbr font="mono"
title="--output-separator">-o</abbr> flags, preferably preparing data upstream
with composable tools that I use often enough to need not browse the trusty
`man`ual:

```sh
{ echo 'User:UID:Home:Shell'; head -7 /etc/passwd | cut -d: -f1,3,6,7 } | column -ts:
```
```txt
User    UID    Home             Shell
root    0      /root            /bin/bash
bin     1      /                /usr/bin/nologin
daemon  2      /                /usr/bin/nologin
mail    8      /var/spool/mail  /usr/bin/nologin
ftp     14     /srv/ftp         /usr/bin/nologin
http    33     /srv/http        /usr/bin/nologin
nobody  65534  /                /usr/bin/nologin
```
