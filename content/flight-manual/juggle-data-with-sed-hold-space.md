+++
title = "Juggle context with `sed`'s pattern and hold spaces"
date = 2026-01-08
description = "Master the use of `sed`'s secondary buffer to carry some state across lines"
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'posix', 'sed']

[[extra.cited_tools]]
   name    = "sed"
   repo    = "https://git.savannah.gnu.org/git/sed.git"
   package = "core/x86_64/sed"
   manual  = "https://www.gnu.org/software/sed/manual/"
[[extra.cited_tools]]
   name    = "vim"
   repo    = "https://github.com/vim/vim"
   package = "extra/x86_64/vim"
   manual  = "https://vimhelp.org/"
[[extra.cited_tools]]
   name    = "keepassxc"
   repo    = "https://github.com/keepassxreboot/keepassxc"
   package = "extra/x86_64/keepassxc"
   manual  = "https://man.archlinux.org/man/extra/keepassxc/keepassxc-cli.1.en"
+++

As `sed` processes its input line by line, it works primarily with its **pattern
space**: a buffer that generally holds the current line being processed.
Generally?  Let's look into it.

> [!IMPORTANT]
>
> There's virtually no point in getting into this article if `sed '2!d'`
> leaves you perplexed.  If that is the case, you may find better value
> in a detour through some thorough (or quick, there's a `TL;DR`)
> introduction to the one core, digestible, unequivocally practical facet
> of `sed` that you may be lacking, in [_Scope `sed` commands to specific
> lines_](@/flight-manual/scope-sed-commands-target-lines.md).

<div class="hi">

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

Most `sed` operations are executed against the content in the **pattern space**,
the current input line.  The **hold** space is a second buffer that is at your
disposal, and with which you can carry state across lines, compare with previous
content, or assemble output that spans multiple lines.

These few commands are the substrate of what using the hold space distils down
to:

- `h`/`H` to copy/append **from pattern to hold** space (`h` for "hold"),
- `g`/`G` to copy/append **from hold to pattern** space (`g` possibly for "get"?)  
  I feel like `g` also nicely mirrors and follows `h` (on a touch-typist's
  QWERTY keyboard and in the alphabet, respectively),
- `x` to **e`x`change** the contents of hold and pattern spaces.

Consider the following document:

```toml,name=my-awesome-crate.toml
[package]
name = "my-awesome-crate"
version = "1.2.3-final.rc.99+g55dd287"
readme = "README.md"

[dependencies]
async-io = { version = "2.6.0", optional = true }
clap = { workspace = true, features = ["string"] }
libc = "0.2.176"
```
{{ note(msg="a semi-legible version number that nonetheless conforms to the [SemVer](https://semver.org/) specification") }}

Sprinkle in some impossibly dense, `POSIX`-compliant `sed` magic to in-line the
section names:

```sh
sed '/^\[/ {s/^.\|.$//g;h;d}
     /./   {G;s/\(.*\)\n\(.*\)/\2.\1/}' my-awesome-crate.toml
```
```txt
package.name = "my-awesome-crate"
package.version = "1.2.3-final.rc.99+g55dd287"
package.readme = "README.md"

dependencies.async-io = { version = "2.6.0", optional = true }
dependencies.clap = { workspace = true, features = ["string"] }
dependencies.libc = "0.2.176"
```
{{ note(msg="horrifying?  possibly—beauty is in the eye of the beholder; `POSIX` compliance, however, is indisputable") }}

</div>

This example above in the `TL;DR` doesn't look too pretty (although, it'd
be nicer with some extended <abbr title='Regular Expressions'>RegExp</abbr>
syntax).  I would say in general that my articles on `sed` or `vim` won't quite
be for the faint of heart: you have to pace yourself reading it, just like you
would German literature[^long-german-words], but I assure you: it is so very
simple to come up with.

[^long-german-words]: I only jest and am referring here to the famously long
compound words that German is known for.

In any case, despite routinely lovingly calling these _"write-only"_, there's
something about contorting `POSIX` tools to get the job done that I find serves
me well in the long run.

## The processing cycle

In brief, `sed` reads a line (without its trailing linefeed)[^trailing-linefeed]
into what it calls the **pattern space**, applies all commands whose addresses
match, in order[^may-bail-out], then prints out the resulting buffer, and
repeats.  The **hold** space is a companion to that main "work" buffer, which
persists across cycles and is effectively entirely inert unless you manipulate
it with `h`/`H`, `g`/`G`, or `x`.

[^trailing-linefeed]: Some notorious text wranglers, whose ranks I am
bolstering, define a line of text as ending with a `\n` character.
Consequently, there shall be a trailing `\n` at the end of a file, lest it
doesn't end with a line, but that constitutes in no way an "empty line", and
yes, a file containing text without a linefeed contains no line.  Numerous
tools, such as `wc` (`echo -n 'some text' | wc -l`), concur; but let not
popularity dictate your tastes, consider the elegance of the consequences.

[^may-bail-out]: Some commands may cut short the further processing of a loop
    and advance to the next iteration—that is, typically, process the next
    line.  For instance, `d` **`d`eletes** the pattern space and continues to
    the next cycle. `b` **`b`ranches** to a _label_, or the next cycle if no
    label is provided: I intimately call it _"bail"_ and use in such manner.

    > [!TIP]
    >
    > I often come across an alternative to explicitly continuing to the next
    > cycle: by default, `sed` prints the pattern space at the end of each
    > cycle.  Some routinely reach for `-n` to suppress that behaviour, together
    > with the `p` instruction to selectively output only the desired bits.
    > `POSIX` only defines `-n`, but at least `GNU`'s implementation also
    > synonymously supports `--quiet` and `--silent`.

    Do note that, without the `-n` flag, `b` would **still print out the pattern
    space** before the next loop, whereas `d` wouldn't.

    There is more to the labelling and branching system, such as the `t` and `T`
    operations, but these are quite the head-scratcher and may be better left to
    the discretion of the reader whose resolve is most unwavering, rather than
    to a hand-wavy footnote in any of my already generally hardly digestible
    articles.

> [!NOTE]
>
> Use addresses to scope where your logic runs: `<address>{<commands>}`.
> I wrote in great length about `sed` addresses in [this previous
> article](@/flight-manual/scope-sed-commands-target-lines.md), which is likely
> far more approachable and useful than this current one.

So how do you manipulate it?  Frankly, it's simple.  In my opinion, perhaps
simpler than whichever degree of simplicity would maximise elegance and
practicality (I would _very much_ like a way to clear the hold, for instance,
without having to clear the pattern and push that into the hold: `s/.*//;x`),
but at least it's simple: I'll give it to you (essentially) straight from the
scripture, `man 1p sed`:

- `g` replaces the contents of the pattern space by the contents of the hold
space,
- `G` appends to the pattern space a linefeed and the contents of the hold
space,
- `h` replaces the contents of the hold space with the contents of the pattern
space,
- `H` appends to the hold space a linefeed and the contents of the pattern
space,
- `x` exchanges the contents of the pattern and hold spaces,

> [!TIP]
>
> Appending with `H` and `G` always involves a linefeed: plan your `s///`
> expressions accordingly.

## Some fantasy recipes

There really isn't that much to the hold space in `sed`.  All that's possibly
quite noteworthy is that many seemingly go on their entire `CLI` dwelling life
without using it: do we simply never need anything like that, or is it a case of
not considering the options that require tools we haven't yet mastered?

Without much ceremony, here come some examples that are certain to lack
practicality for your software, but truly do come in handy when the servers are
on fire and we wouldn't mind somebody navigating the system like they would the
back of their hand—or, as the French would say, the bottom of their pocket.

### Reverse lines

Well, `sed`'s not built for that, it processes _streams_ of data, and while
this would indeed be guaranteed to work for files up to 8kb in size[^8kb],
`tac` (`cat` in reverse!) from `GNU`'s excellent `coreutils` is a much more
appropriate tool for that job.

In any case, this shall still function as a reasonably adequate way to get
started.

```sh
sed '1!G;h;$!d' file
sed '1!G; h; $!d' file
sed '
  h         # [h]old on to it
  $!d
' file
```
{{ note(msg="don't hesitate to format your `sed` scripts with newlines and comments for readability") }}

[^8kb]: The `POSIX` specification (`man 1p sed`) guarantees that both pattern
and hold spaces can hold at least 8192 bytes.  `GNU sed` removes practical
limits for most uses.

- `1!G`, unless at line 1 (the first), append the accumulated hold to the
  pattern;
- `h`, save the aggregate into the hold;
- `$!d`, unless at line `$` (the last), discard the pattern; `sed` will
  implicitly print out the only non-discarded pattern, the ultimate one
  coalescing the entire accumulated reversed collection of lines.

You could do away with specifying `1!`, in which case the (empty) hold space,
**as well as an extra linefeed**, would be appended to the end of the output.
Non-printable characters may very well not be most obvious, but we should strive
to keep things tight.  Restricting `G` to `1!` avoids having to `$s/\n$//` at
the end of the script.

### Annotate particularly long functions in source code

```sh
sed -E '/^\s*function\b/ h; /^}$/ {G;s@\nfun\w*\s*(\w+)\(.*@ // end \1@}' module.ts
sed -E '
/^\s*function\b/ h                    # on top-level function definition, save in hold
/^}$/ {                               # on lonesome top-level closing bracket,
  G                                   #   get function name from hold
  s@\nfun\w*\s*(\w+)\(.*@ // end \1@  #   append comment to line
}' module.ts
```

This above incantation will add a comment to the closing bracket of top-level
function definitions, which you may find of some utility, when taming some
particularly rambly procedures now and then:

<div class="grid-1-2">
<div>

```js
function preparePages() {
  const pages = readdirSync(src, { withFileTypes: true })
    .filter(({ name }) => /^\d+\.ts$/.test(name))
    .map(({ name }) => name.replace(/\.ts$/, ''))
  const dom = new JSDOM(readFileSync(resolve(src, 'index.html')).toString())
  const doc = dom.window.document
  doc.head.append(...Object
    .entries({ author, description, homepage, keywords, title })
    .map(([k, v]) => (e => (e.setAttribute(k, String(v)), e))(doc.createElement('meta'))),
  )
  const H = doc.head
  for (const page of pages) {
    const s = doc.createElement('script')
    s.setAttribute('defer', 'defer')
    s.setAttribute('type', 'module')
    s.setAttribute('src', `/${page}.ts`)
    const h = H.cloneNode(true) as HTMLHeadElement
    h.append(s)
    doc.head.replaceWith(h)
    writeFileSync(resolve(src, `${page}.html`), dom.serialize())
  }
  return pages
}
```
{{ note(msg="before, some plain TypeScript code") }}
</div>
<div>

```js
function preparePages() {
  const pages = readdirSync(src, { withFileTypes: true })
    .filter(({ name }) => /^\d+\.ts$/.test(name))
    .map(({ name }) => name.replace(/\.ts$/, ''))
  const dom = new JSDOM(readFileSync(resolve(src, 'index.html')).toString())
  const doc = dom.window.document
  doc.head.append(...Object
    .entries({ author, description, homepage, keywords, title })
    .map(([k, v]) => (e => (e.setAttribute(k, String(v)), e))(doc.createElement('meta'))),
  )
  const H = doc.head
  for (const page of pages) {
    const s = doc.createElement('script')
    s.setAttribute('defer', 'defer')
    s.setAttribute('type', 'module')
    s.setAttribute('src', `/${page}.ts`)
    const h = H.cloneNode(true) as HTMLHeadElement
    h.append(s)
    doc.head.replaceWith(h)
    writeFileSync(resolve(src, `${page}.html`), dom.serialize())
  }
  return pages
} // end preparePages
```
{{ note(msg="after: note the comment on the last line") }}

</div>
</div>

### Better contextualise logs

We've all been there: some botched batch processing expired with barely more
than a whimper, and we've got some sort of report that was seemingly never meant
to be grokked.

```sh
sed -E '/completed|skipped/ s/$/\n/
        /processing REQ-/   {s/pro\w+\s*(.*)/\1/;h;s/.*/processing/}
        G;s/(.*)\n(.*)/\2> \1/' log.txt

sed -E '
/completed|skipped/ s/$/\n/  # upon finalising request, add linefeed
/processing REQ-/ {          # upon new request,
  s/pro\w+\s*(.*)/\1/        #   extract ID
  h                          #   hold on to it
  s/.*/processing/           #   change message to "processing"
}
                             # for each line,
G                            #   get current request ID
s/(.*)\n(.*)/\2> \1/         #   format as "ID> message"
' log.txt
```

Heh, it works!  Yet admittedly, that one would be quite neater using `awk`.

<div class="grid-1-2">
<div>

```txt
processing REQ-841239
validating
downloading document
parsing document
transforming data
saving record
completed
processing REQ-841240
validating
downloading document
timeout, retrying
parsing document
transforming data
saving record
completed
processing REQ-841241
validating
invalid payload
skipped
processing REQ-841242
validating
downloading document
parsing document
transforming data
saving record
completed
processing REQ-841243
validating
downloading document
parsing document
transforming data
saving record
completed
```
{{ note(msg="before; a curiously impenetrable log file") }}
</div>
<div>

```txt
REQ-841239> processing
REQ-841239> validating
REQ-841239> downloading document
REQ-841239> parsing document
REQ-841239> transforming data
REQ-841239> saving record
REQ-841239> completed

REQ-841240> processing
REQ-841240> validating
REQ-841240> downloading document
REQ-841240> timeout, retrying
REQ-841240> parsing document
REQ-841240> transforming data
REQ-841240> saving record
REQ-841240> completed

REQ-841241> processing
REQ-841241> validating
REQ-841241> invalid payload
REQ-841241> skipped

REQ-841242> processing
REQ-841242> validating
REQ-841242> downloading document
REQ-841242> parsing document
REQ-841242> transforming data
REQ-841242> saving record
REQ-841242> completed

REQ-841243> processing
REQ-841243> validating
REQ-841243> downloading document
REQ-841243> parsing document
REQ-841243> transforming data
REQ-841243> saving record
REQ-841243> completed
```
{{ note(msg="after; contextual information is made accessible throughout each item's life cycle") }}
</div>
</div>

### Collapse paragraphs to single lines

```sh
sed '/./{H;d}; s/.*//;x;s/\n/ /g' document.txt
```

When would you ever?  Frankly, that one I don't know.  You could map that to
something within your <abbr title="Vim, of course">favourite editor</abbr>, but
it already has [`J`](https://vimhelp.org/change.txt.html#v_J) for that.  One
character, just at the tip of most natural finger, in its resting position!  And
I suppose that if you can distinguish your editor from your shell, you'll likely
dance the _end-delete-down_ sequence for a while (which is actually quite fun to
do!), so there may be no case for this specific one ever, ever; oh well.

## Practical use case: pull an entry to the top

I store my passwords in `KeePassXC`, and I often need to copy some attribute
of an entry, such as the password itself, or the username, or the URL.  I have
a menu that lists available attributes for a given entry, and would just like
the convenience of having the password as the first, most accessible option: 42
bytes of `sed` ~gibberish~ goodness later, and voilà, the password comes first,
and the rest knows how to best organise itself.

```sh
sed -n '/^Password:/{p;b};H;${g;s/\n//p}'
sed -n '
  /^Password:/ {p;b}  # when the "Password" option is shown, print it and "bail" out
  H                   # accumulate other fields
  $ {                 # at the end of the document,
    g                 #   bring hold into pattern
    s/\n//            #   remove opening linefeed (from "H" into an empty hold space)
    p                 #   print the other options in their natural order
  }'
```
{{ note(msg="`keepassxc-cli` actually displays that attribute as `Password: PROTECTED`, of course") }}

For completeness' sake, I could explain that each entry's attributes ranking is
weighted via some access frecency (frequency + recency) heuristic, but that, for
these old accounts I haven't accessed in a while (or to start off the system), I
know that **the password** is most likely the attribute I want available through
my clipboard for the next 5 seconds.

It certainly could have been done otherwise, possibly, but I did it like that,
and therefore I, **and you too now**, have seen it done like that.  I actually
don't recall having seen it done any other way.

Cheers!
