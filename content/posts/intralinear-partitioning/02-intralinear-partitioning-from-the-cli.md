+++
title = 'Laying text out horizontally from the `CLI`'
date = 2025-08-08
description = 'Getting to know `column`, `cut` and `paste`'
taxonomies.tags = ['all', 'cli', 'text-processing', 'productivity']
+++

[^cited-tools]: {{ cmd(name="vim", repo="https://github.com/vim/vim", package="extra/x86_64/vim", manual="https://vimhelp.org/") }}
                {{ cmd(name="neovim", repo="https://github.com/neovim/neovim", package="extra/x86_64/neovim", manual="https://neovim.io/doc/user/") }}
                {{ cmd(name="column", repo="https://github.com/util-linux/util-linux/", package="core/x86_64/util-linux", manual="https://man.archlinux.org/man/column.1.en") }}
                {{ cmd(name="paste", repo="https://github.com/coreutils/coreutils", package="core/x86_64/coreutils", manual="https://man.archlinux.org/man/paste.1.en") }}

   While conducting software archaeology with a colleague some days ago, we ran
into a 0-byte Java class and figured we'd look for more outliers and report to
the responsible parties:

```sh
paste <(fd -S0b)                                             \
      <(fd -S0b | cut -d/ -f1 | xargs -II grep I CODEOWNERS) \
      -d: | column -ts:
```
```txt
a/s/m/j/c/a/a/c/LoginController.java               auth-service     @big-brother
a/s/m/j/c/a/a/d/LoginRequest.java                  auth-service     @big-brother
a/s/t/j/c/a/a/s/AuthenticationServiceTest.java     auth-service     @big-brother
b/s/m/j/c/a/b/c/InvoiceController.java             billing-service  @gold-diggers
c/s/m/j/c/a/c/c/utils/DateUtils.java               core-common      @super-nerds
c/s/t/j/c/a/c/c/utils/ValidationUtilsTest.java     core-common      @super-nerds
c/s/t/j/c/a/c/s/services/EmployeeServiceTest.java  core-server      @fast-and-curious
```
{{ note(msg="all that data was fake even before truncation: `src/test/java/com/acme/auth/controllers`") }}

   From `cut` to `xargs`, the entire incantation was met with a mixture of
incredulity and awe: some simple, composable tools go a long way to articulate
queries for your shell interpreter.  Here, I'll lay the foundations for your
horizontal text alignment needs, from the CLI.

## Using `column`

   In the introductory piece of this article, I proposed a classification for
the various forms of textual horizontal alignment.  The first three are mundane
enough to be easily achieved using nothing but a pair of trustworthy tools;
chief among them is <abbr title="Columnate lists">`column`</abbr>[^cited-tools].

### The list in a grid

   If your items are begging to fit on a single screenful of text, you can lay
them out in a grid with `column`:

```sh
echo $PATH | tr : '\n' | column
```
```txt
/home/ccjmne/bin	/usr/local/sbin		/usr/bin/core_perl
/usr/local/bin		/usr/bin/site_perl	/usr/lib/rustup/bin
/usr/bin		/usr/bin/vendor_perl	/home/ccjmne/share/pnpm
```

   It wants to print out columns of unique width, regardless of their individual
content.<br>
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

   If you find yourself wanting to create a proper table, `column` again has got
you covered: use its `--table`/`-t` flag to have it create or manipulate tabular
data.<br>
   Consider the case of <abbr title="User account information">`/etc/passwd`</abbr>:

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
{{ note(msg="note the startling absence of a [`UUOC`](@/posts/useless-use-of-cat.md)") }}

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

   However, the above is rather extreme: I generally limit myself
to the <abbr font="mono" title="--table">`-t`</abbr>, <abbr
font="mono" title="--separator">`-s`</abbr>, <abbr font="mono"
title="--output-separator">`-o`</abbr> (and on occasion, <abbr font="mono"
title="--table-right">`-R`</abbr>) flags, preferably preparing data upstream
with composable tools that I use often enough to need not [browse the trusty
manual](@/posts/man):

```sh
{ echo 'User:UID:Home:Shell'; head -7 /etc/passwd | cut -d: -f1,3,6,7 } | column -ts:
```
{{ note(msg="this command is essentially equivalent to the one above it") }}

#### A note on field selection

   Now probably comes time to touch on touch on <abbr title="Cut out selected
fields of each line of a file ">`cut`</abbr>, which justly sounds like a fated
partner to `paste`.

   At its core, `cut` merely serves to carve out chunks ("fields") from
your lines.  Specify the delimiter by which to delineate your fields with
`--delimiter`/`-d`, and extract the ones you need with `--fields`/`-f`:

```sh
head -7 /etc/passwd | cut -d: -f1,6
head --lines 7 /etc/passwd | cut --delimiter : --fields f1,6
```
```txt
root:/root
bin:/
daemon:/
mail:/var/spool/mail
ftp:/srv/ftp
http:/srv/http
nobody:/
```
{{ note(msg= select fields 1 and 6  ) }}

   Note that you may identify 1-indexed, comma-separated fields, *or ranges*,
possibly open-ended:

- `1,3,5` selects *fields 1, 3 and 5*,
- `1-3` means *1 through 3*,
- `-5` is *5 and below*, and
- `3-` is *3 and beyond*.

 With `column`, the various field-selecting flags behave similarly, with some
notable extensions: you may use the `0` field alone to denote *all fields*, or
use negative indices to target fields from the *end*.  Thus, `-1` is the *last
field*, `-2` is the *penultimate field* and so on.<br>
   This has the consequence of invalidating the range notation that uses an open
lower bound: where `-3` would mean *1 through 3* in `cut`, it means *third field
from the end* in `column`.

## Using `paste`

   Here we are, where it gets good, <abbr title="Merge lines of
files">`paste`</abbr>[^cited-tools] is what we'd been after all along.  It only gets
introduced now because it requires cooperation from its friends to get the job
you likely want done.

### The adjoined and annotated fragments

   At last, there's data that's not quite tabular enough to be called that...
yet!  This final section of the article is where you finally get some bang
for your buck: we'll try our hands at putting chunks of text next to one
another.<br>
   The `paste` utility lets you join lines from multiple files:

<div class="grid-1-3">
<div>

```txt,name=a.txt
a
b
c
d
e
```
</div>
<div>

```txt,name=b.txt
1
2
3
4
```
</div>
<div>

```sh
paste a.txt b.txt
```
```txt
a	1
b	2
c	3
d	4
e
```
{{ note(msg="these are *tabulations*") }}
</div>
</div>

How often do you need to do that?  Precisely *never*, were it not for
[everything being a file (descriptor)](@/posts/everything-is-a-file.md): you can
also `paste` the output of commands together (beware the non-`POSIX` Bashism,
however):

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
{{ note(msg="these are still *tabulations*") }}

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
{{ note(msg="data may overflow past the tabulations stops") }}

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
{{ note(msg="imbalanced datasets also create problems (the `recall` command is made up)") }}

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
{{ note(msg="circling back to the `/etc/passwd` format") }}
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
through a list of <abbr title="American Standard Code for Information
Interchange">`ASCII`</abbr> characters to use instead of tabulations.
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
<pre class="language-txt z-code"><code><span class="z-string">f09f</span> <span class="z-string">a689</span> <span class="z-constant">0a</span>  <span class="z-string">....</span><span class="z-constant">.</span></pre></code>
```sh
yes | head -5 | paste -d🦉 - - - - -
```
```txt
yyyyy
```
```sh
yes | head -5 | paste -d🦉 - - - - - | xxd
```
<pre class="language-txt z-code"><code><span class="z-variable">79</span><span class="z-string">f0</span> <span class="z-variable">79</span><span class="z-string">9f</span> <span class="z-variable">79</span><span class="z-string">a6</span> <span class="z-variable">79</span><span class="z-string">89</span> <span class="z-variable">79</span><span class="z-constant">0a</span>  <span class="z-variable">y</span><span class="z-string">.</span><span class="z-variable">y</span><span class="z-string">.</span><span class="z-variable">y</span><span class="z-string">.</span><span class="z-variable">y</span><span class="z-string">.</span><span class="z-variable">y</span><span class="z-constant">.</span></pre></code>
</div>
<div>

```sh
cat /dev/null                              \
    | paste -d🦉 <(echo [) - - - <(echo ]) \
    | xxd
```
<pre class="language-txt z-code"><code><span class="z-variable">5b</span><span class="z-string">f0</span> <span class="z-string">9fa6</span> <span class="z-string">89</span><span class="z-variable">5d</span> <span class="z-constant">0a</span>  <span class="z-variable">[</span><span class="z-string">....</span><span class="z-variable">]</span><span class="z-constant">.</span></pre></code>
```sh
cat /dev/null \
    | paste -d🦉 <(echo [) - - - <(echo ])
```
```txt
[🦉]
```
{{ note(msg="I'll allow `cat` here, for `- - -`") }}
</div>
</div>

   I did alter <abbr title="Make a hex dump or do the reverse">`xxd`</abbr>'s
output for simplicity, and attempted to provide reasonably adequate
highlighting, which I hope to be more helpful than it is confusing.

## Closing words

   Note that, if you want to add line numbers or timestamps of all kinds, you
should prefer `nl` (from `coreutils`) or `ts` (from `moreutils`) to `paste`.

   That's it, this article boils down to: `paste <(left) <(right)` and `column
-ts:`, with some `-d:` passed here and there to `cut` or `paste` where
necessary.  Go wild, have fun, don't forget that everything is possible, you
just need to browse the `man`ual.

   In the [next and final part](@/posts/intralinear-partitioning-3.md), find
out how to swifty do all of that, and a *lot* more, from the comfort of an
exceptional yet ubiquitous text editor.
