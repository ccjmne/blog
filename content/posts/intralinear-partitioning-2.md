+++
title = 'Intralinear partitioning (part 2 of 3)'
date = 2025-08-08
description = 'Laying text out horizontally from the CLI'
+++

## The few forms of horizontal alignment

### The list in a grid

   If your items are begging to fit on a single screenful of text, you can lay
them out in a grid with `column`[^column]:

[^column]: {{ cmd(name="column", repo="https://github.com/util-linux/util-linux/", package="core/x86_64/util-linux", manual="https://man.archlinux.org/man/column.1.en") }}

```sh
echo $PATH | tr : '\n' | column
```
```txt
/home/ccjmne/bin	/usr/local/sbin		/usr/bin/core_perl
/usr/local/bin		/usr/bin/site_perl	/usr/lib/rustup/bin
/usr/bin		/usr/bin/vendor_perl	/home/ccjmne/share/pnpm
```

   Note that `column` wants to print out columns of unique width, regardless of
their individual content.<br>
   By default, it uses tabulations, but you may have it use spaces with the
`--use-spaces`/`-S` flag, which takes the minimum number of whitespaces to
separate columns by:

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
```txt
100  104  108  112  116  120  124  128  132  136  140  144  148
101  105  109  113  117  121  125  129  133  137  141  145  149
102  106  110  114  118  122  126  130  134  138  142  146  150
103  107  111  115  119  123  127  131  135  139  143  147
```

   Unless instructed otherwise, it will fill its grid column-first, but you can
also have it go row by row with `--fillrows`/`-x`:

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

   Avoiding the `--fillrows` flag yields grids that are generally more evenly
packed, provided that your display is wide enough to accommodate more of your
items as you'd need rows to contain them all.  Either case will use exactly as
many rows as necessary.

### The tabular data

   If you find yourself wanting to create such table, `column`[^column] again
has got you covered: use its `--table`/`-t` flag to have it create or manipulate
tabular data.<br>
   Have a look at <abbr font="mono" title="User account
information">`/etc/passwd`</abbr>:

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
{% note(type="comment") %} Note the startling absence of a [UUOC](@/posts/first.md) {% end %}

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
a myriad of ways.  Name columns, shuffle them around, truncate or wrap their
content, hide them...  Have at it!

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

   However, the above is rather extreme: I generally limit
myself the <abbr font="mono" title="--table">-t</abbr>, <abbr
font="mono" title="--separator">-s</abbr> and <abbr font="mono"
title="--output-separator">-o</abbr> flags, preferably preparing data upstream
with composable tools that I use often enough to need not [browse the trusty
manual](@/posts/man):

```sh
{ echo 'User:UID:Home:Shell'; head -7 /etc/passwd | cut -d: -f1,3,6,7 } | column -ts:
```

### The adjoined fragments

   Finally, there's data that's not quite tabular enough to be called that...
yet!  This final section of the article is where you finally get some bang
for your buck: we'll try our hands at putting chunks of text next to one
another.<br>
   The `paste`[^paste] utility lets you join lines from multiple files:

[^paste]: {{ cmd(name="paste", repo="https://github.com/coreutils/coreutils", package="core/x86_64/coreutils", manual="https://man.archlinux.org/man/paste.1.en") }}

<div class="grid-1-3">
<div>

```sh
cat a.txt
```
```txt
a
b
c
d
e
```
</div>
<div>

```sh
cat b.txt
```
```txt
1
2
3
4
```
</div>
<div>

```sh
paste b.txt a.txt
```
```txt
a	1
b	2
c	3
d	4
e
```
{% note(type="comment") %} these are *tabulations* {% end %}
</div>
</div>

How often do you need to do that?  Precisely *never*, were it not for [(pretty
much) everything being a file (descriptor)](@/posts/everything-is-a-file.md):
you can also `paste` the output of commands together:

```sh
paste <(printf "%s\n" {a..e}) <(seq 1 4) <(man git | sed '/The commit/,/^$/!d')
```
```txt
a	1	The commit, equivalent to what other systems call a "changeset" or
b	2	"version", represents a step in the project’s history, and each parent
c	3	represents an immediately preceding step. Commits with more than one
d	4	parent represent merges of independent lines of development.
e		
```
{% note(type="comment") %} these are still *tabulations* {% end %}

You can just about feel that there's something usable there, but we'll have to
address some tab-related limitations before unearthing this treasure:

```sh
paste <(echo 'NAME\nccjmne\nninoshka\nozymandias\nhe-who-must-not-be-named') \
      <(echo 'JOB\nsoftware engineer\nfaithful companion\ngreek pharaoh\nrogue wizard')
```
```txt
NAME	JOB
ccjmne	software engineer
ninoshka	faithful companion
ozymandias	greek pharaoh
he-who-must-not-be-named	rogue wizard

```
{% note(type="comment") %} data may overflow past the tabulations stops {% end %}

<br>

```sh
paste <(recall 2.days.ago) <(recall yesterday) <(recall today)
```
```txt
Sat, 17 July	Sun, 18 July	Mon, 19 July
------------	------------	------------
#edu 5h48m	#edu 2h09m	#edu 1h32m
#foss 1h06m	#foss 3h04m	#foss 31m
	#run 39m	#work 8h12m
		#commute 49m
```
{% note(type="comment") %} imbalanced datasets also create problems (the `recall` command is made up) {% end %}

The remedy is the `--delimiters`/`-d` flag, which pairs delightfully well
with `column -ts` in a real ah-ha moment:

<div class="grid-1-2">
<div>

```sh
paste <(recall 2.days.ago) \
      <(recall yesterday)  \
      <(recall today)      \
      --delimiters ':'
```
```txt
Sat, 17 July:Sun, 18 July:Mon, 19 July
------------:------------:------------
#edu 5h48m:#edu 2h09m:#edu 1h32m
#foss 1h06m:#foss 3h04m:#foss 31m
:#run 39m:#work 8h12m
::#commute 49m
```
{% note(type="comment") %} circling back to the `/etc/passwd` format {% end %}
</div>
<div>

```sh
paste <(recall 2.days.ago) \
      <(recall yesterday)  \
      <(recall today)      \
      -d: | column -ts:
```
```txt
Sat, 17 July  Sun, 18 July  Mon, 19 July
------------  ------------  ------------
#edu 5h48m    #edu 2h09m    #edu 1h32m
#foss 1h06m   #foss 3h04m   #foss 31m
              #run 39m      #work 8h12m
                            #commute 49m
```
</div>
</div>

   However, this treatment is only curative if you can identify a symbol that
your data doesn't contain.  We could almost make it a panacea, were it not for
what I consider a quirk of `paste`.<br>

   As you'll have noted, the `--delimiters` flag is *plural*: it can cycle
through a list of <abbr font="mono" title="American Standard Code for
Information Interchange">ASCII</abbr> characters to use instead of tabulations.
Regardless of the practicality of this feature, its implementation has `paste`
consider each *byte* as a distinct delimiter: committing to an esoteric Unicode
character that spans several bytes will therefore not do you any good.

   Here are a few examples for illustration, which are most probably best
consumed with the questions likely raised by the above paragraph still on your
mind:

<div class="grid-1-2">
<div>

```sh
xxd <<< 🦉
```
```txt
f09f a689	....
```
```sh
yes | head -5 | paste -d🦉 - - - - -
```
```txt
yyyyy
```
```sh
yes | head -5 | paste -d🦉 - - - - - | xxd
```
```txt
79f0 799f 79a6 7989 79	y.y.y.y.y

```
</div>
<div>

```sh
cat /dev/null                              \
    | paste -d🦉 <(echo [) - - - <(echo ]) \
    | xxd
```
```txt
5bf0 9fa6 89f0 5d	[....]
```
```sh
cat /dev/null \
    | paste -d🦉 <(echo [) - - - <(echo ])
```
```txt
[🦉]
```
{% note(type="comment") %} I allowed myself `cat /dev/null |` here for `- - -` {% end %}
</div>
</div>

   I did alter `xxd`'s output for simplicity, though I recognise that adequate
highlighting would be the ideal resolution.
