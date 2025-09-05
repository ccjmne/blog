+++
title = 'Useless use of `cat`'
date = 2025-08-16
description = 'The signature of the perpetually uneducated'
+++

Short for con`cat`enate, `cat`[^cat] takes multiple files and prints them
together into one continuous stream of text.  However, the first introduction to
the <abbr title="Command Line Interface, where I dwell">`CLI`</abbr> is sure to
establish into the wasteland of the hurried neophyte's mind a simplistic mental
model boiling down to: "`cat` is what you use when you have a file and want its
content".

[^cat]: {{ cmd(name="cat", repo="https://github.com/coreutils/coreutils", package="core/x86_64/coreutils", manual="https://man.archlinux.org/man/cat.1.en") }}

The consequence?  Processes multiplying like cancerous cells:

```sh
cat 2020-05-13.log | grep ERROR
cat mentions.txt | wc -l
cat catalina.out | tail
cat server.cfg | sed 's/127.0.0.1/localhost/' > server.cfg
```
{{ note(msg="the ailment (the last one doesn't even work)") }}

<br>

```sh
grep ERROR 2020-05-13.log 
wc -l mentions.txt
tail catalina.out 
sed -i 's/127.0.0.1/localhost/' server.cfg
```
{{ note(msg="the remedy") }}

## Files all the way down

Files are a fairly common in the world of computing, and even more
so across Unix-like operating systems, where [everything is a file
(descriptor)](@/posts/everything-is-a-file.md).

When you do `cat asdf`, your Kernel looks up `asdf` in the file system and
returns a *file descriptor* (abbreviated `FD`) to the process running `cat`,
which reads from it and prints to another, specific `FD` (numbered `1`), which
your shell interpreter displays on your terminal.

That is it, no mystery, nothing special.  We can now appreciate how silly
`cat file | grep` is: reading from a file isn't any different from reading
from the standard input.  Your tool only has to support being specified which
file to read from, and you only need to <abbr title="Read The F... riendly
Manual">`RTFM`</abbr>:

```sh
man grep | head
```
```txt
GREP(1)                          User Commands                           GREP(1)

NAME
       grep - print lines that match patterns

SYNOPSIS
       grep [OPTION]... PATTERNS [FILE]...
       grep [OPTION]... -e PATTERNS ... [FILE]...
       grep [OPTION]... -f PATTERN_FILE ... [FILE]...
```

There you have it: `grep` and friends not only *obviously* accept files names as
arguments, they *evidently* do.

### But what if?

   What if one didn't?  After rounding up the usual suspects, I can attest
to the stunning rarity of common utilities not playing by this tacit
rule.  Let's conjure up `gerp` (`grep` + <abbr title="A foolish or ignorant
person">derp</abbr>!), an abominable degradation of `grep` that only knows of
<abbr title="The standard input">`stdin`</abbr>.<br>
   You can use *input redirection* (`<`) to funnel the data from whichever file
descriptor you get over your file, to `FD 0` (the standard input):

```sh
gerp keyword < file.txt
```

That's it!  A patched `gerp`, no `cat`, no `|`, just a smidgen of understanding;
all <abbr title="Portable Operating System Interface">`POSIX`</abbr>-compliant,
too.

How seldom have you come across the redirection above?  It should unquestionably
be more common than `cat file | grep keyword`, yet I'm fairly confident it
isn't, despite its twin counterpart (the *output* redirection) being virtually
omnipresent: I explain this phenomenon with the concept of [rampant shell
illiteracy](@/posts/rampant-shell-illiteracy).

## The legitimate use of `cat`

Despite my furry companion being of the canine variety, I have nothing against
`cat` in principle.  Outside of scripts, I'd still argue that `less` is surely
often preferable, possibly with `--quit-if-one-screen`/`-F` to have it behave
like `cat` when you require no pagination; but here are a few instances where
`cat` is sensible nonetheless:

```sh
# Create file in-line
cat > greeting.txt <<-EOF
	Hello, world!
EOF

# Concatenate several files
cat header.txt section1.txt section2.txt footer.txt > article.txt

# Compound commands
{ print-header; cat section1.txt; print-footer } | package-article

# Concatenate standard input and file
echo 'About me:' | cat - aboutme.txt
```

### The definitive escalation mechanism

Somewhere along the way, we started using `cat` as a ceremonial prelude to
everything, as if every command needed a feline blessing.  With [everything
being a file (descriptor)](@/posts/everything-is-a-file.md), it turns out that
quite a few commands will happily accept to read from a file!

As such, here is the *definitive escalation mechanism* for your commands that
are to consume the contents of a file:

```sh
grep keyword file.txt        # the one way
grep keyword < file.txt      # the workaround for curious utilities
cat file.txt | grep keyword  # the universally incorrect, useless use of cat
```
