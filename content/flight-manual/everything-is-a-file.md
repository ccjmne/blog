+++
title = 'Everything is a file (descriptor)'
date = 2025-08-18
description = 'Becoming one with the pipes, in ways only [Mario](https://en.wikipedia.org/wiki/Mario) could'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'plumbing-secrets', 'posix']
draft = true
+++

You will certainly have come across the saying "everything is a file" in your
journey towards `CLI` mastery: but what does it mean?

In reality, not everything is _a file_ as much as a file _descriptor_ (often
abbreviated `FD`).  On Unix-like systems, file descriptors are the abstraction
that lets processes interact with all kinds of resources (files, sockets, pipes,
terminals, devices...) in a uniform way.

Typically, they're identified by a single positive integer, scoped to the
process that opened them: this means that `FD 0` in one process may be different
from `FD 0` in another.

## File descriptors

There are three standard file descriptors that are ubiquitous enough to warrant
being outlined here:

- `FD 0` is the standard input (`stdin`)
- `FD 1` is the standard output (`stdout`)
- `FD 2` is the standard error output (`stderr`)

 You use them implicitly every time you use a command in your shell.  Take the
example of `sort`: if you invoke it, it'll read from `FD 0` until that steam is
closed, sort all the lines alphabetically, then write the result to `FD 1`.<br>
   Your shell interpreter will consume your input and pass them along to
`sort`'s `FD 0`, and hook into its `FD 1` to display output to your terminal
again.

If you open your terminal (I should say: your terminal _emulator_, unless you're
on a physical [VT100](https://en.wikipedia.org/wiki/VT100) or similar), and:

1. invoke `sort`,
2. feed it `c`, then `d`, `a`, `b` as four distinct lines of input,
3. close its `stdin`, with `Ctrl-D`[^ctrl-d],

  [^ctrl-d]: An <abbr title="Input/Output">`I/O`</abbr> stream is typically
closed by pressing `Ctrl-D`, which sends an _end-of-file_ sequence.
That combination is interpreted by your terminal emulator, and may be
queried and manipulated with <abbr title="Set the options for a terminal
">`stty`</abbr>.<br>
  Your emulator is (enormously) likely configured to send `EOF` when you
press that combination; you may use <abbr title="Print current terminal
settings">`stty -a`</abbr> to verify:
    <pre class="z-code"><code>intr = ^C; quit = ^\; erase = ^?; kill = ^U; <span
    class="term-fg33">eof = ^D</span>; eol = &lt;undef&gt;;</pre></code>

then you should be presented with your input, sorted; that is: `a`, `b`, `c`,
and `d`, on four separate lines.

### File descriptors in `/proc`

The [in-depth: `/proc`](@/flight-manual/in-depth-slash-proc.md) follow-up
to this article touches on the `/proc` virtual filesystem, which primarily
lets you refer to your processes' `I/O` resources, and complements this
introduction from a more technical perspective.  It pairs nicely with all sort
of shell redirection mechanisms: I go over those in the [shell redirection
101](@/flight-manual/shell-redirection-101.md) article.














POST ON EVERYTHING IS A FILE!! see /dev/udp/host/port, process substitution <() >(), HEREDOC HERESTRING, exec...

SEE c2 wiki on symlink v hardlink










  They're not the only thing you have, though: devices, sockets, "plain" pipes,
named pipes (`FIFO`s), _et cet._ all exist, and are accessed through a _file
descriptor_ (oft abbreviated `FD`).

   That is it, no mystery, nothing special; one mechanism to rule them all, and
in the light bind them.<br>























### VAGUELY RELATING TO UUOC

In fact, the pipe (`|`) operator is essentially a way to connect the `FD 1`
("`stdout`") of one process to the `FD 0` ("`stdin`") of another.  And the
output redirection (`>`) can be specified which file descriptor to redirect, as
well as which to redirect it to:

```sh
echo 'Hello, world!'     1> greeting.txt   # Redirect fd1 (stdout) to greeting.txt
echo 'Hello, world!'     >  greeting.txt   # ">" without a descriptor implies fd1
sed 's/./\U\0/g'         0< file           # Redirect file to fd0 (stdin)
sed 's/./\U\0/g'         <  file           # "<" without a descriptor implies fd0
withdraw '1_000_000 EUR' 2> not-today.log  # Redirect fd2 (stderr) to errors.log
./i-use-fd3.sh           3< input          # You're not limited to fd0, fd1, fd2!
./live-a-little.sh       1> blog.md 2>&1   # Redirect fd1 blog.md and fd2 to fd1 (now blog.md)
cat file                 |  process        # Connect fd1 of cat to fd0 of process
cat                      0<in 1>out 2>err  # Read from in, write to out with errors to err
```
{{ note(msg="there's a lot more to go over; I only mean this as a quick, apt first encounter with file descriptors") }}
