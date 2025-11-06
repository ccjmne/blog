+++
title = 'In-depth: `/proc`'
date = 2025-08-19
description = ''
draft = true
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'posix']
+++

A follow-up to [everything is a file
(descriptor)](@/flight-manual/everything-is-a-file.md), this article will serve
as a deep dive into the `/proc` virtual filesystem.

SHOULD PROBABLY BE A SERIES!!!!

## Miscellaneous `/proc` resources

TODO: TALK of `/proc/uptime`, `/proc/version`, `/proc/meminfo`,
`/proc/stat`, `/proc/net`, `/proc/sys`...

## Interesting `/proc/<pid>` information

TODO: TALK ABOUT `/proc/<pid>/exe`, `/proc/<pid>/cwd`, `/proc/<pid>/root` and
`/proc/<pid>/fd`<br>

## Files descriptors `/proc/<pid>/fd`

First, a quick refresher.  Consider `sort`: invoked without arguments, it reads
from its standard input (`stdin`, `FD 0`) until that stream is closed, sorts the
lines it has received, and writes the result to its standard output (`stdout`,
`FD 1`).

```sh
sort
```
{{ note(msg="this will wait for your input") }}

Terminate your input on `stdin` with `Ctrl-D`[^ctrl-d].  As presented in [shell
redirections 101](@/flight-manual/shell-redirections-101.md), you can open
various file descriptors and assign them to your processes' `stdin`:

  [^ctrl-d]: An <abbr title="Input/Output">`I/O`</abbr> stream is typically
closed by pressing `Ctrl-D`, which sends an *end-of-file* sequence.
That combination is interpreted by your terminal emulator, and may be
queried and manipulated with <abbr title="Set the options for a terminal
">`stty`</abbr>.<br>
  Your emulator is (enormously) likely configured to send `EOF` when you
press that combination; you may use <abbr title="Print current terminal
settings">`stty -a`</abbr> to verify:
    <pre class="z-code"><code>intr = ^C; quit = ^\; erase = ^?; kill = ^U; <span
    class="term-fg33">eof = ^D</span>; eol = &lt;undef&gt;;</pre></code>

<div class="grid-1-2"><div>

```sh
sort < unsorted.txt
```
```txt
A pricot
B anana
C oconut
D ragonfruit
```
{{ note(msg="this uses `unsorted.txt` as standard input") }}
</div><div>

```sh
sort 3< unsorted.txt
```
{{ note(msg="this will wait for your input, `FD 3` has no use") }}
</div><div style="grid-area: 1 / 2 / 3 / 3;">

```txt,name=unsorted.txt
D ragonfruit
C oconut
A pricot
B anana
```
</div></div>

  With "everything being a file", you'll be happy to know that you may[^permissions] access *the resource that a process has opened
on one of its file descriptors* (this specific nuance is relevant), by referring
to as `/proc/<pid>/fd/<fd>`, where `<pid>` is the process `ID`, and `<fd>` is
the file descriptor you want to access.<br>
  You may use `self` in place of a <abbr title="Process ID">`PID`</abbr> to
refer to the *current* process `/proc/self/fd/<fd>`.  Remember this, it'll come
back in a minute.

[^permissions]: You may, *provided that you have the adequate permissions*.

Since `sort` falls somewhat flat when receiving non-standard file descriptors,
let's have `cat` do things (namely: print out) with any file descriptor you feed
it.  The following will have `FD 3` point to `file.txt`, and `cat` regurgitate
the content from its `FD 3`, *twice*, back to back:

<div class="grid-1-2"><div>

```sh
cat /proc/self/fd/3 /proc/self/fd/3 3< file.txt
```
```txt
This is the content of file.txt
This is the content of file.txt
```
</div><div>

```txt,name=file.txt
This is the content of file.txt
```
</div></div>

Here's a nice tip: numerous utilities understand `-` (a hyphen) to mean "read
from the standard input", so you can tell `cat` to read from its `stdin`, where
you'd have redirected `file.txt` to:

<div class="grid-1-2"><div>

```sh
cat - < file.txt
```
```txt
This is the content of file.txt
```
{{ note(msg="`-` instructs `cat` to read from its `stdin`") }}
</div><div>

```sh
cat < file.txt
```
```txt
This is the content of file.txt
```
{{ note(msg="though `cat` *by default* reads the standard input") }}
</div></div>

How about `cat - -`&nbsp;? It would read from `FD 0` (the standard input) twice,
but *`stdin` is closed when you arrive at the end of the stream*: after having
read (and spat back) `-` (`stdin`) once, `cat` attempts again to read from `FD
0`, which is now closed and therefore *empty*.

Conversely, `/proc/self/fd/0` is a *descriptor* to the
resource that `FD 0` points to (see [File descriptors in
`/proc`](@/flight-manual/everything-is-a-file.md#file-descriptors)).  In our
case, that resource is a simple file on our system and we can open a new
stream to it: `cat` can consume it several times; despite pointing to the same
resource, `/proc/self/fd/0` is *not* the same `I/O` stream as `FD 0`!

<div class="grid-1-2"><div>

```sh
cat - - < file.txt
```
```txt
This is the content of file.txt
```
{{ note(msg="`stdin` is closed after `EOF`") }}
</div><div>

```sh
cat /proc/self/fd/0 /proc/self/fd/0 < file.txt
```
```txt
This is the content of file.txt
This is the content of file.txt
```
{{ note(msg="each file descriptor indirectly points to `file.txt`") }}
</div></div>
