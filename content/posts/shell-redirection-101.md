+++
title = 'Redirection 101: the very basics'
date = 2025-08-18
description = 'A gentle introduction to redirection in the shell, for the uninitiated'
draft = true
taxonomies.tags = ['all', 'cli', 'posix']
+++

  *Disclaimer:* this article is tailored to those of us who are taking
their first steps in the <abbr title="Command Line Interface, where I
dwell">`CLI`</abbr>.<br>
  A seasoned user is still likely to find some quite interesting information
in the various notes, but the main focus of the article still is only
meant to level the playing field in order to approach the [everything is a
file](@/posts/everything-is-a-file.md) series.

<!-- more -->

## Redirection

  Straight from `bash`'s `man`ual, we learn that before a command is executed,
its input and output may be redirected using a special notation interpreted by
the shell.<br>
  There is a *lot* to talk about here: redirection allows commands' file handles
to be duplicated, opened, closed, made to refer to different files, and can
change the files the command reads from and writes to; but I'll stick here to
the practical, day-to-day uses of redirection.

Instead of manually typing up on `stdin`, you may redirect some other `I/O`
stream to `sort`'s standard input.  Just as well, you may redirect its output
to an any other file descriptor using one (or more!) of five (or 6, with the
`HERESTRING` Bashism) redirection operators:

- `<` redirects `stdin` from a file descriptor
- `>` redirects `stdout` to a file descriptor
- `>>` appends `stdout` to a file descriptor
- `<<` redirects `stdin` from an in-line document (`HEREDOC`)
- `<<<` redirects `stdin` from an in-line string (`HERESTRING`, non-`POSIX`!)
- `|` pipes `stdout` from a command to `stdin` of another

Let's explore the few things to know about each.

### Input redirection: `<`

The dead simple `<` operator redirects a file descriptor to `FD 0`.  Whereas
`sort` invoked on its own would have you type your input, you may have it sort
the files of a file on disk instead:

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
{% note(type="comment") %} this uses `unsorted.txt` as standard input {% end %}
</div><div>

{% note(type="heading") %} `unsorted.txt` {% end %}
```txt
D ragonfruit
C oconut
A pricot
B anana
```
</div></div>

It may take a `FD` number, too, to redirect to a file descriptor other than
`0`, the standard input.  For instance, you may redirect `FD 3`
to the contents of `unsorted.txt`:
```sh
sort 3< unsorted.txt
```

The above is of dubious interest, since `sort` doesn't do anything with its `FD
3`.

nb.: Going forward, I'll invoke `sort` with a file descriptor as its first
positional argument, which will have it read from there instead of `stdin`.

### Output redirection: `>`

A counterpart to `<`, the `>` operator redirects a file descriptor to `FD 1`.
Whereas `sort` invoked on its own would print its output to the terminal, you
may have it write the sorted output to a file on disk instead:

<div class="grid-1-2"><div style="grid-area: 1 / 1 / 2 / 3;">

```sh
sort unsorted.txt > sorted.txt
```
{% note(type="comment") %} this has no visible output, since `stdout` was redirected to `sorted.txt` {% end %}
</div><div>

{% note(type="heading") %} `unsorted.txt` {% end %}
```txt
D ragonfruit
C oconut
A pricot
B anana
```
</div><div>

{% note(type="heading") %} `sorted.txt` {% end %}
```txt
A pricot
B anana
C oconut
D ragonfruit
```
</div></div>

Just like `<`, it may take a `FD` number, to redirect to to another descriptor.
A fairly common use case is to redirect `FD 2`, the standard error output, to a
file, so that you can inspect it later:

```sh
sort unsorted.txt 2> errors.txt
```
```txt
A pricot
B anana
C oconut
D ragonfruit
```
{% note(type="comment") %} `errors.txt` would contain any error output {% end %}

You may redirect *both* `stdout` and `stderr` at the same time, using the `&>`
operator, though it is not `POSIX`-compliant.

### Appending output: `>>`

The `>>` operator is similar to `>`, but *appends* to the file descriptor
instead of overwriting it.  This is useful when you want to keep the previous
contents of a file and add new data to it, rather than replacing it.

It also understands a file descriptor number, like the two operators above.

### Here Document: `<<`

The `<<` operator redirects a *here document* (abbreviated `HEREDOC`) to
`FD 0`.  A here document is a way to provide input to a command directly
within the script or command line, rather than from a separate file.
For instance, you can use it to sort a list of items without having to create a
separate file:

```sh
sort <<EOF
C oconut
D ragonfruit
A pricot
B anana
EOF
```
```txt
A pricot
B anana
C oconut
D ragonfruit
```

Once again, it may take a file descriptor number, to redirect to a file
descriptor other than `0`, the standard input.  There are a few more things
that make `HEREDOC` uniquely useful, which I go over in [a complementary
article](heredoc.md).

### Here String: `<<<`

Disclaimer: this one is not part of the `POSIX` standard.

The `<<<` operator redirects a *here string* to `FD 0`.  A here string is a
way to provide a single line of input to a command directly within the script or
command line, rather than from a separate file or a here document.  For example,
you can use it to sort a single line of text:

<div class="grid-1-2"><div>

```sh
sort <<< '
C oconut
D ragonfruit
A pricot
B anana
'
```
```txt
A pricot
B anana
C oconut
D ragonfruit
```
{% note(type="comment") %} `<<<` isn't part of the `POSIX` specification {% end %}
</div><div>

```sh
sort <<< $'\nC oconut\nD ragonfruit\nA pricot\nB anana'
```
```txt
A pricot
B anana
C oconut
D ragonfruit
```
{% note(type="comment") %} `<<<` and `$'...'` make this *doubly* non-`POSIX` {% end %}
</div></div>

Since you'll already be using Bashisms if you're there, you may like to know
that the `$'...'` (`ANSI-C` quoting) allows you, in `bash`, `zsh` and other
popular interactive interpreters, to interpret backlash escape sequences much
like `C` string literals would.  There, `\n` is a linefeed, `\t` a tabulation,
`\x20` is a byte with the hexadecimal value `20` (a whitespace), `\u20AC` is
the Unicode character with code point `U+20AC` (the Euro sign), and so on.

### Command piping: `|`

The `|` operator pipes the standard output (`stdout`, `FD 1`) of one command to
the input (`stdin`, `FD 0`) of another.  This is a powerful feature that allows
you to chain commands together, passing the output of one command as input to
the next.  We talk then of *pipeline*, as opposed to *simple commands*.

For example, you can use it to sort a list of items generated by another
command:

```sh
printf 'C\nD\nA\nB' | sort
```
```txt
A
B
C
D
```
{% note(type="comment") %} the `\n` are interpreted by `printf` and therefore *aren't non-POSIX* constructs here! {% end %}

<div class="grid-1-2"><div>

```sh
sort 3< unsorted.txt
```
{% note(type="comment") %} this will wait for your input, `FD 3` has no use {% end %}
</div><div>

```sh
sort < unsorted.txt
```
```txt
A pricot
B anana
C oconut
D ragonfruit
```
{% note(type="comment") %} this uses `unsorted.txt` as standard input {% end %}
</div><div style="grid-area: 1 / 2 / 3 / 3;">

{% note(type="heading") %} `unsorted.txt` {% end %}
```txt
D ragonfruit
C oconut
A pricot
B anana
```
</div></div>

That is, of course, of dubious utility, since `sort` doesn't do anything with
its `FD 3`.  However, you can get `cat` to do things (namely: print out) with
any file descriptor you feed it.  The following opens an `I/O` stream to the
contents of the file `file.txt` in `FD 3`, and prints it out, *twice*, back to
back:

If you redirect the output of `echo` to a file, your shell will open that file
and write to it, using a new file descriptor (let's say `FD 3`) instead
of `FD 1`.  If you redirect the error output of a command,
your shell will open a file for that, too, and use a new file descriptor (let's
say `FD 4`) for it.
