+++
title = 'Target blocks of text with `sed`'
date = 2025-09-06
description = 'How to use `sed` to target **chunks of text** between two patterns'
taxonomies.tags = ['all', 'cli', 'posix', 'sed']

[[extra.cited_tools]]
   name    = "sed"
   repo    = "https://git.savannah.gnu.org/git/sed.git"
   package = "core/x86_64/sed"
   manual  = "https://www.gnu.org/software/sed/manual/"
[[extra.cited_tools]]
   name    = "sd"
   repo    = "https://github.com/chmln/sd"
   package = "extra/x86_64/sd"
   manual  = "https://man.archlinux.org/man/extra/sd/sd.1.en"
[[extra.cited_tools]]
   name    = "vim"
   repo    = "https://github.com/vim/vim"
   package = "extra/x86_64/vim"
   manual  = "https://vimhelp.org/"
+++

I really like `sed`.  Chances are that you use it sporadically to search and
replace text from the `CLI`, and if that is all you plan on reaching for this
trusty tool for, you may want to know of a very popular alternative that
somewhat simplifies that specific task: [`sd`](https://github.com/chmln/sd).

For the finer folks, you will find boundless treasures in the venerable `man`ual
pages, and perhaps a few tips and tricks scattered online, such as those I plan
to publish on this very platform.

> [!TIP]
> The <abbr title="Portable Operating System Interface">`POSIX`</abbr> `man`
> pages of `sed` are more complete than that of its `GNU` implementation:
> you may run `man 1p sed` to access the `POSIX` version for a more
> faithful (and universal) reference; however `GNU` offers a significantly
> more exhaustive version through either `info sed` or its [on-line
> version](https://www.gnu.org/software/sed/manual/).

<!-- , and I write about using the `man`ual here. (@/posts/read-the-friendly-manual). TODO: LINKME -->

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

You can limit the scope over which `sed` commands operate by preceding them
with one or two **addresses**.  An address may be a line number, a regular
expression, or a few other special forms.

```sh
sed '/match/       s/before/after'  file.txt   # substitute only on lines matching 'match'
sed '5,20          s/before/after'  file.txt   # substitute only on lines 5 through 20
sed '/if/,  /fi/   d'               script.sh  # delete if-blocks (not production-ready...)
sed '/!important/  !d'              style.css  # extract css !important rules
```
</div>

## The anatomy of a `sed` command

A `sed` **command** takes the following form:

```txt
[address[,address]]function
```

In this syntax, `function` represents a single-character **command verb** in
`sed`, followed by any applicable arguments.  The most common function is `s`,
which stands for *substitute*, but you'll find numerous others, such a `d` for
*delete*, `p` for *print*, `a` for *append*...[^from-ed-to-nvim]

[^from-ed-to-nvim]: They all were inherited from the traditional `ed`
line-oriented editor, and this legacy still lives on to this day, stronger than
ever, through even the <abbr title="The ubiquitous text editor">Vim</abbr> (and
Neovim) commands that use precisely these same single-letter verbs.  Oh yeah,
the `CLI`-only crew has it all figured out!

> [!TIP]
> To keep things readable (we wield regular expressions but we're not animals),
> the `address`es and `function` can be preceded and/or followed by *blank*
> characters.  The **command** in its entirety, `[address[,address]]function`,
> may be preceded and/or followed by *blank and/or semicolon* characters.

One last, simple yet quite useful trick regarding line selection: you can
**negate the selection** over which a `function` shall operate by preceding it
with an exclamation mark (`!`), which will cause the command to be executed on
all lines *except* those addressed.

Each **function** you can execute may take **up to either zero, one, or two**
**addresses**.

## The forms of addresses

An **address** may take one of the following forms:

- a *decimal number* that counts input lines cumulatively across files
  (`1`-indexed),
- a *dollar sign* (`$`) character, which references the last line of input, or
- a *context address*, which consists of a <abbr title="Basic Regular
  Expression">`BRE`</abbr> as described [here in the complete `GNU` `sed` manual
  on-line](https://www.gnu.org/software/sed/manual/html_node/BRE-syntax.html),
  preceded and followed by a delimiter—usually a *forward slash* (`/`).

   > [!WARNING]
   > Using `GNU` `sed`, using a different delimiter **in the context of
   > addresses** requires a `backslash` (`\`) **before the preceding
   > delimiter**.  For example, to use a *hash* [^hash] as the delimiter, with
   > `GNU` `sed`, you'd write `\#regexp#` instead of `#regexp#`.<br>
   >
   > In addition, `GNU`'s implementation [introduces the `/re/I` and `/re/M`
   > syntaxes](https://www.gnu.org/software/sed/manual/html_node/Regexp-Addresses.html#Regexp-Addresses)
   > for case-insensitive and multi-line matching, respectively.  Most often
   > in other contexts these flags are lower-case, but `GNU` `sed` offers a
   > would-be conflicting `i` function verb for *insert* that couldn't be
   > interpreted adequately, had the flags been `i` and `m` instead of `I` and
   > `M`.

[^hash]: The "hash" or "number sign" (`#`), is also routinely referred to by the
Americanisms "octothorpe", or more absurdly "pound sign"

To these `POSIX` standards, `GNU sed` adds the following option:

- the `first~step` form, where `first` and `step` are both *decimal numbers*.

  This matches one every every `step` lines, starting with `first`.  For
  example, `1~2` matches all odd-numbered lines, while `2~2` matches the even
  ones.

## Address ranges

In `sed`, most **commands** can be given with:

- **no addresses**, in which case the command will be executed for all input
  lines,
- **one address**, then only input lines which match that address will be
  considered, or
- **two addresses**, in which case the command will operate over all input lines
  matching the *inclusive* range of lines starting from the first address and
  continuing to the second address.

  > [!NOTE]
  > The syntax is `address1,address2` (that is, the addresses are separated
  > by a comma); the line which `address1` matched will always be accepted,
  > even if `address2` selects an earlier line; and if `address2` is a regular
  > expression, it will not be tested against the line that `address1` matched.

Using two addresses allows you to target *ranges
of lines* where the two addresses serve as
[flip-flop](https://en.wikipedia.org/wiki/Flip-flop_(electronics)) markers: when
the first address is matched, if we're currently outside a match range, we start
processing the input lines for that command, until the second address is matched
or the end of the input is reached.

### Some `GNU sed`-specific pseudo-addresses

The `GNU` version of `sed` introduces three pseudo-addresses that may only
be used in the context of address ranges, and **aren't valid as stand-alone
addresses**:

- `+N` and `~N`, where `N` is a decimal number, only **available to the second
  of an address pair**:

  `+N` matches the line that is `N` lines after that of the first address, `~N`
  matches the lines whose number is a multiple of `N`.

- `0`, which **may only be used as the first of an address pair**.  It is most
  esoteric and only included here for completeness.  The special `0,address2`
  syntax is used to:

  > Start out in "matched first address" state, until `address2` is found.  This
  > is similar to `1,address2`, except that if `address2` matches the very first
  > line of input the `0,address2` form will be at the end of its range, whereas
  > the `1,address2` form will still be at the beginning of its range.  This
  > works only when `address2` is a regular expression.

Well, that's a lot of theory, but nothing quite scary in practice, though I
suppose some demonstrations are in order.

## Exempli gratia

Here are some examples of **addresses** and **address ranges** in action, using
the **`d`elete** command:

```sh
seq 1 10 | sed '1d'      # delete the first line
seq 1 10 | sed '$d'      # delete the last line
seq 1 10 | sed '2,4d'    # delete lines 2 through 4, inclusive
seq 1 10 | sed '2,$d'    # delete from line 2 to the end

# The following are GNU sed extensions:
seq 1 10 | sed '1~2d'    # delete odd-numbered lines
seq 1 10 | sed '2~2d'    # delete even-numbered lines
seq 1 10 | sed '3,+2d'   # delete line 3 and the two following it (3, 4, and 5)
seq 1 10 | sed '3,~7d'   # delete line 3, up to the next multiple of 7 (3, 4, 5, 6, and 7)
```

It is also possible to use regular expressions as addresses:

```sh
seq 1 20 | sed '/3/d'       # delete lines matching '3' (lines 3 and 13)
seq 1 20 | sed '/[357]/d'   # delete lines matching '3', '5', or '7' (lines 3, 5, 7, 13, 15, and 17)
seq 1 20 | sed '1,/[357]/d' # delete from line 1 to the first matching '3', '5', or '7' (lines 1, 2, 3)
```

You may target some function from a script:

```sh
# Delete the function "handleanything" by specifying lines ranging from:
# - its declaration: /function handleanything/, to:
# - its closing brace: /^}$/
sed '/function handleanything/, /^}$/ d' <<'EOF'
answer=42
function handleanything() {
    echo "We will look into it next sprint, please create a Jira ticket"
}
function why() {
    echo $answer
}
EOF
```
```txt
answer=42
function why() {
    echo $answer
}
```
{{ note(msg="you can use white space in the `[address[,address]]function` pattern for better readability") }}

You can also retain only that function, one of two ways:

```sh
# Using the `-n` (or `--quiet` or `--silent`) option to suppress automatic
# printing of the processed stream, and the `p` command to print only the lines
# in the specified range:
sed -n '/function handleanything/, /^}$/  p' script.sh

# Using the negation operator (!) to operate on lines *outside* the specified range:
sed    '/function handleanything/, /^}$/ !d' script.sh
```
{{ note(msg="don't hesitate to use white-space, `/function handleanything/,  /^}$/  !d` is also legal") }}

For instance, you may refer to some of your favourite `man`ual entries in this way:

```sh
man strftime | sed '/%D/,/^$/!d'
man strftime | sed '/%D/,  /^$/  !d'
```
```txt
       %D     Equivalent to %m/%d/%y.  (Yecch—for Americans only.  Americans should note that in
              other countries %d/%m/%y is rather common.  This means that in international context
              this format is ambiguous and should not be used.) (SU)
```

### A real-life scenario

Another quick tip: if you find yourself wanting to **`s`ubstitute** some text
only on certain lines, you don't necessarily have to complicate your regular
expression.

Let's take the example of some `nginx` configuration:

```nginx
# handles https traffic
server {
    listen 443 ssl http2;
    server_name example.com;

    location /app1 {
        proxy_pass      http://backend1;
        proxy_redirect  http://backend1  /app1;
    }

    location /app2 {
        proxy_pass      http://backend2;
        proxy_redirect  http://backend2  /app2;
    }

    location /app3 {
        proxy_pass      http://backend3;
        proxy_redirect  http://backend3  /app3;
    }
}
```

Suppose that you want to avoid performing [`SSL`
termination](https://en.wikipedia.org/wiki/TLS_termination_proxy) in your
reverse proxy: you'll need to change occurrences of `http` to `https`.

Here's the diff you'd obtain after running a naive `sed 's/http/https/'
nginx.conf`:

```diff
-# handles https traffic
+# handles httpss traffic
 server {
-    listen 443 ssl http2;
+    listen 443 ssl https2;
     server_name example.com;

     location /app1 {
-        proxy_pass      http://backend1;
-        proxy_redirect  http://backend1  /app1;
+        proxy_pass      https://backend1;
+        proxy_redirect  https://backend1  /app1;
     }

     location /app2 {
-        proxy_pass      http://backend2;
-        proxy_redirect  http://backend2  /app2;
+        proxy_pass      https://backend2;
+        proxy_redirect  https://backend2  /app2;
     }

     location /app3 {
-        proxy_pass      http://backend3;
-        proxy_redirect  http://backend3  /app3;
+        proxy_pass      https://backend3;
+        proxy_redirect  https://backend3  /app3;
     }
 }
```

Oops, we don't actually want to change the comment line nor the protocol
(there's no `https2`), but only the `proxy_pass` directives.

You could revise your regular expression to something like:

```vim
s/\(proxy_pass *\|proxy_redirect *\) http/\1 https
```

That would work, but...  Good grief.

Even if you're comfortable with regular expressions in the first place,
and with the `BRE` flavour whenever necessary, in addition to the <abbr
title="Perl-Compatible Regular Expressions">`PCRE`</abbr> dialect I'm sure
you'll often favour, that's still a troublesome incantation not only to read,
but even to write: you may very well, for instance, forget about the pesky
multiple spaces for horizontal alignment in your first attempt!

A more idiomatic `sed` way would be to scope your substitution to the lines containing
`proxy_`:

```sh
sed '/proxy_/s/http/https/' nginx.conf
sed '/proxy_/  s/http/https/' nginx.conf
```
{{ note(msg="the second version is also entirely legal syntax, it merely adds white-space for readability") }}

How real-life is that, though?  Wouldn't you just spin up your favourite text
editor at this point?

Certainly.  But you'll be happy to know that your <abbr title="Vim, of
course">favourite text editor</abbr> offers the same function!

```vim
:g/proxy_/s/http/https
:g  /proxy_/  s/http/https
```
{{ note(msg="Vim is more lenient and tolerates omitting the final `/` at the end of the replacement pattern") }}

You could also have selected the `location` blocks:

```sh
sed '/location.*{/,/^}/s/http/https/' nginx.conf
sed '/location.*{/,  /^}/  s/http/https/' nginx.conf
```

Or maybe all lines following `/app1`:

```sh
sed '#/app1#,$s/http/https/' nginx.conf
sed '#/app1#,  $  s/http/https/' nginx.conf
sed '\#/app1#,  $  s/http/https/' nginx.conf  # GNU sed only
```
{{ note(msg="for illustration, I used hashes (`#`) to delineate the <abbr title='Regular Expressions'>RegExp</abbr> here, to not have to escape the literal `/`") }}

Or lines 5 and onwards:

```sh
sed '5,$s/http/https/' nginx.conf
sed '5,  $  s/http/https/' nginx.conf
```

The world is your oyster!  Know your options, start using them here and there,
you'll find what works for you and maybe best accommodate your tools to your
taste.

### One savvy application I use all the time

I'll share here a part of [my personal `prepare-commit-msg` Git
hook](https://github.com/ccjmne/dotfiles2025/blob/master/home/config/git/template/hooks/prepare-commit-msg),
which runs every time I commit anything anywhere and prepares the commit
template to my liking.

I use the `--verbose` flag when committing, so that Git shows me:

> [...] a unified diff between the HEAD commit and what would be committed at
> the bottom of the commit message template to help the user describe the commit
> by reminding what changes the commit has.

In summary, instead of being presented with:

```sh
git commit
```
<pre class="z-code language-txt"><code><span class="term-fg38"># Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch <span class="term-fg35">master</span>
# <span class="term-fg35">Changes to be committed:</span>
#	<span class="term-fg34">modified</span>:   <span class="term-fg33">test</span>
#
# <span class="term-fg35">Changes not staged for commit:</span>
#	<span class="term-fg34">modified</span>:   <span class="term-fg33">test</span>
#
# <span class="term-fg35">Untracked files:</span>
#	<span class="term-fg33">other</span>
</pre></code>

You would instead have:

```sh
git commit --verbose
```
<pre class="z-code language-txt"><code><span class="term-fg38"># Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch <span class="term-fg35">master</span>
# <span class="term-fg35">Changes to be committed:</span>
#	<span class="term-fg34">modified</span>:   <span class="term-fg33">test</span>
#
# <span class="term-fg35">Changes not staged for commit:</span>
#	<span class="term-fg34">modified</span>:   <span class="term-fg33">test</span>
#
# <span class="term-fg35">Untracked files:</span>
#	<span class="term-fg33">other</span>
#
# ------------------------ >8 ------------------------
# Do not modify or remove the line above.
# Everything below it will be ignored.</span>
<span class="term-fg34">diff --git a&#47;test b&#47;test</span>
<span class="term-fg36">index 84ef876..4c1d036 100644</span>
<span class="term-fg33">--- a/test</span>
<span class="term-fg35">+++ b/test</span>
<span class="term-fg36">@@ -1 +1 @@</span>
<span class="term-fg31">-Let me tell you about something</span>
<span class="term-fg32">+Let me tell you about something cool</span>
</pre></code>
{{ note(msg="I like having a recap of my changes below the [scissors line](https://git-scm.com/docs/git-mailinfo#Documentation/git-mailinfo.txt---scissors)") }}

Quite handy, yet too noisy.  My `prepare-commit-msg` hook prunes the content
that I find too busy, using `sed`:

```sh
# Prune unstaged/untracked content listing and hand-holding guidance
sed -i.bak "$commit_msg_file" -e '
    /^# Please enter the commit message/, /^#$/d                ;
    /^# Do not modify or remove/,         /^[^#]/ { /^[^#]/!d } ;
    /^# Changes not staged/,              /^#$/d                ;
    /^# Untracked files/,                 /^#$/d                ;'
```
{{ note(msg="I use `-i.bak` to keep a backup of the original file, just in case") }}

There's some more to unpack in this snippet, but the part I want to go over
in this article here is the selection of chunks to **`d`elete** using the
`/pattern/,/pattern/` address range syntax with `sed`, leaving me with a much
cleaner commit message template:

```sh
git commit --verbose
```
<pre class="z-code language-txt"><code><span class="term-fg38"># On branch <span class="term-fg35">master</span>
# <span class="term-fg35">Changes to be committed:</span>
#	<span class="term-fg34">modified</span>:   <span class="term-fg33">test</span>
# ------------------------ >8 ------------------------</span>
<span class="term-fg34">diff --git a&#47;test b&#47;test</span>
<span class="term-fg36">index 84ef876..4c1d036 100644</span>
<span class="term-fg33">--- a/test</span>
<span class="term-fg35">+++ b/test</span>
<span class="term-fg36">@@ -1 +1 @@</span>
<span class="term-fg31">-Let me tell you about something</span>
<span class="term-fg32">+Let me tell you about something cool</span>
</pre></code>
{{ note(msg="in reality, I have configured `git-commit` to always use `--verbose` and needn't specify it") }}

Much tidier, isn't it?

In this article, I only talked about **selecting lines** in `sed`, but I am
**barely scratching the surface** of what you can do with the tool altogether,
and will be sure to post more articles about it in the future.

Have fun!
