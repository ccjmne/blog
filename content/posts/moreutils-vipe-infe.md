+++
title = 'Script-friendliest `$EDITOR` with `moreutils`'
date = 2025-07-31
description = "Adoping moreutils's `vipe` and `ifne` for friendlier scripting"
+++

I carry around a (very humble) collection of <abbr title="A command-line fuzzy
finder">`fzf`</abbr>[^fzf] utilities, where I intend to leverage a tacit promise
of <abbr title="The ubiquitous text editor">Vim</abbr>: I can edit content,
right there in the terminal, between two commands, and be done earlier than a
corporate <abbr title="Integrated Development Environment">IDE</abbr> would be
flashing its splash screen[^cli-editor].

[^fzf]: {{ cmd(name="fzf", repo="https://github.com/junegunn/fzf", package="extra/x86_64/fzf", manual="https://man.archlinux.org/man/extra/fzf/fzf.1.en") }}

[^cli-editor]: So we're clear: it's not just about shaving off a few seconds
here and there: wait until you learn about `fc`!

But I'm not talking about the speed: I'm talking about the *availability* and
*convenience*.

With <abbr title="Aptly and delightfully named companion to coreutils">`moreutils`</abbr>,
this elevator pitch needs to be challenged: *between*
two commands?  Laughable.  The adept [functional
programmer](https://en.wikipedia.org/wiki/Functional_programming) in me should
have sniffed it out some time ago: I can use Vim like I use <abbr title="Stream
editor for filtering and transforming text ">`sed`</abbr>.

## The script-friendly editor

Let's start with a quick round of qualifications against the few
IDEs I've had the occasion to use over the last couple of years: [VS
Code](https://code.visualstudio.com/), [Eclipse](https://www.eclipse.org/) and
[IntelliJ](https://www.jetbrains.com/idea/).

- all three can be made to accept a file to open as an argument, though only one
  doesn't require prior set-up or extra gymnastics,
- only two can be spawned in `--wait` mode, blocking progress of the invoking
  script until their interface is closed,
- none of them provide a reasonable way to error out (`exit 1`).

These functionalities don't sound like much, but they're part of what I would
expect from a *script-friendly editor*.

### Building a quaint example

I've prepared for this article a little utility to illustrate how neatly a
terminal editor can integrate to your scripting.  Let's build a script that
will:

1. let the user select a quote from some collection,
2. prepare an e-mail sharing that quote to some unsuspecting recipient,
3. let the user customise that e-mail,
4. send the e-mail to the unsuspecting recipient.

Let's start off with steps 1 and 2:

```sh
MAIL=$(mktemp --suffix .eml)
curl https://zenquotes.io/api/quotes \
   | jq -r '.[] | .a + "@" + .q'     \
   | fzf --delimiter=@               \
         --with-nth=2                \
         --bind='enter:become:cat <<-EOF
		Date: $(date --rfc-email)
		From: ccjmne@gmail.com
		To: sherlock.inbox@221b.uk
		Subject: This quote made me think of you
		
		{r2}
		
		    — {r1}
		EOF' \
   > $MAIL
```
{% note(type="comment") %} I didn't even put quotation marks around `$MAIL`: all the variables in the script are expansion-safe! {% end %}

We create a temporary[^tmpfs] file with `mktemp`, using a specific *file
extension* with the `--suffix` flag: that'll let our text editor figure out how
to highlight our document's syntax.

[^tmpfs]: These files will routinely be cleared (historically, some systems
would do that on each boot).  On mine, `/tmp` is a mount-point to some
[RAM-backed file-system](https://en.wikipedia.org/wiki/tmpfs): the stuff going
in there *never* makes it to an actual storage device.

The <abbr title="World Wide Web, with a capital W">Web</abbr> server at
`https://zenquotes.io/api/quotes` will yield 50 randomised quotes (with their
respective authors' name) as a [JSON](https://www.json.org/json-en.html)
array.  We'll process them with <abbr title="Command-line JSON
processor">`jq`</abbr>[^jq] and pass them along to `fzf`, offering an
interactive interface for the user to pick an entry.  The selected quote is
finally written to `$MAIL`, in a format suitable for plain-text e-mails:

```eml
Date: Mon, 11 Aug 2025 00:20:43 +0200
From: ccjmne@gmail.com
To: sherlock.inbox@221b.uk
Subject: This quote made me think of you

Success is getting what you want, happiness is wanting what you get.

    — W.P. Kinsella
```
{% note(type="comment") %} it'll be highlighted sensibly in your editor {% end %}

[^jq]: {{ cmd(name="jq", repo="https://gitlab.archlinux.org/archlinux/packaging/packages/jq", package="extra/x86_64/jq", manual="https://man.archlinux.org/man/extra/jq/jq.1.en") }}

On with the last two steps: if the user did select a quote, they'll get to edit
their e-mail in their favourite `$EDITOR`, with adequate highlighting for the
e-mail format.  When they're done, if they neither emptied or deleted the file,
nor emitted an error (`:cq`), their e-mail is then sent off to the unsuspecting
recipient:

```sh
if [ -s $MAIL ]; then
    $EDITOR $MAIL
    if [ $? -eq 0 ] && [ -s $MAIL ]; then
        msmtp sherlock.inbox@221b.uk < $MAIL
    fi
fi
rm $MAIL
```

There you go, all in a few lines of shell scripting, while you're out
and about surfing the command line.  Spawn it in a <abbr title="Terminal
multiplexer">`tmux`</abbr> pop-up and start spamming to your heart's content,
barely interrupting your flow long enough to personalise the e-mail.  Fantastic!

But it gets better: you can integrate it right inside an outright
[pipeline](https://en.wikipedia.org/wiki/Pipeline_(Unix)).

## More friendliness with `moreutils`

Enter [`moreutils`](https://joeyh.name/code/moreutils/), a "collection of the
Unix tools that nobody thought to write long ago when Unix was young".

It's got some niceties that do find some fame online, such as <abbr title="Look
up errno names and descriptions">`errno`</abbr>, <abbr title="Soak up standard
input and write to a file">`sponge`</abbr> and <abbr title="Timestamp
input">`ts`</abbr>, but the treats of the day are `vipe` and `ifne`.

[^vipe]: {{ cmd(name="vipe", repo="git://joeyh.name/code/moreutils/", package="extra/x86_64/moreutils", manual="https://man.archlinux.org/man/vipe.1.en") }}

[^ifne]: {{ cmd(name="ifne", repo="git://git.joeyh.name/moreutils", package="extra/x86_64/moreutils", manual="https://man.archlinux.org/man/ifne.1.en") }}

   With <abbr title="Edit pipe">`vipe`</abbr>[^vipe], you can edit the standard
input in your favourite editor, then pipe the result to the next command.  It
accepts the same[^vipe-suffix] `--suffix` argument as `mktemp` to provide your
`$EDITOR` with some context as to the syntax of your content.<br>
   With <abbr title="Run command if the standard input is not
empty">`ifne`</abbr>[^ifne], you can guard the execution of a command on the
condition that the standard input is not empty.<br>

<!-- FIXME: wording -->
[^vipe-suffix]: Essentially the same as that of `mktemp`, though with more
ingenuity: it will assume the implied leading `.` in your suffix.

That all sounds like it could replace the entire second half of our script.
Could it?  Let's try it out:

```diff
-MAIL=$(mktemp --suffix .eml)
 curl https://zenquotes.io/api/quotes \
    | jq -r '.[] | .a + "@" + .q'     \
    | fzf --delimiter=@               \
          --with-nth=2                \
          --bind='enter:become:cat <<-EOF
 		...
 		EOF' \
-   > $MAIL
-
-if [ -s $MAIL ]; then
-    $EDITOR $MAIL
-    if [ $? -eq 0 ] && [ -s $MAIL ]; then
-        msmtp sherlock.inbox@221b.uk < $MAIL
-    fi
-fi
-rm $MAIL
+   | ifne vipe --suffix eml \
+   | msmtp sherlock.inbox@221b.uk
```
{% note(type="comment") %} these two lines replace the entire second half of the script and forgo toying with a variable in the first {% end %}

   Well, what do you know: it can.  That tedious business from the earlier
script?  Gone.  The variable we were passing around?  Gone as well.<br>
   We're left with *a single pipeline*: `curl` | `jq` | `fzf` | `vipe`
| `msmtp`.  You can pretty much map it one-to-one to the original
requirements!  And they say that <abbr title="The big OOP(s)">object-oriented
programming</abbr> is modelling real-world concepts...

```sh
curl https://zenquotes.io/api/quotes \
   | jq -r '.[] | .a + "@" + .q'     \
   | fzf --delimiter=@               \
         --with-nth=2                \
         --bind='enter:become:cat <<-EOF
		Date: $(date --rfc-email)
		From: ccjmne@gmail.com
		To: sherlock.inbox@221b.uk
		Subject: This quote made me think of you
		
		{r2}
		
		    — {r1}
		EOF' \
   | ifne vipe --suffix eml \
   | msmtp sherlock.inbox@221b.uk
```
{% note(type="comment") %} here's the full thing: the e-mail template comprises most of it {% end %}

## Compose your mastery

In isolation, this isn't anything earth-shattering, but here's the point: I can
now write this up in one go; no fumbling, no hesitation.

Wielding *simple*, generic, *composable* tools lets you to reify your ideas
without friction, as if you were merely transposing them more formally.  That
concept, and its consequences on your ability to explore, play and eventually
build up mastery of your craft, are indeed of remarkable value.

Have fun!
