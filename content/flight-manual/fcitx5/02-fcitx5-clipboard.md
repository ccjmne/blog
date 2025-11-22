+++
title = 'System-wide clipboard history with `fcitx5`'
date = 2025-11-19
description = "Beyond the obvious, `fcitx5` also satisfies their sharper users' expectations in handling sensitive data"
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'quibblery']

[[extra.cited_tools]]
   name    = 'fcitx5'
   repo    = 'https://github.com/fcitx/fcitx5'
   package = 'extra/x86_64/fcitx5'
   manual  = 'https://fcitx-im.org/wiki/Fcitx_5'
[[extra.cited_tools]]
   name    = 'keepassxc'
   repo    = 'https://github.com/keepassxreboot/keepassxc'
   package = 'extra/x86_64/keepassxc'
   manual  = 'https://keepassxc.org/docs/#command-line'
+++

A staple of the frantic user's tool belt, the clipboard history needs no
introduction.

I remember the day one of my colleagues excitedly demonstrated their
newly-acquired copy-paste buffer history plug-in that would work well inside
the very specific _"file editing"_ view of their <abbr title="convoluted
abstraction over build tools">`IDE`</abbr>.  I remember it well, because
it was **last year**—a whopping **half a century** or so after
[`vi`](https://en.wikipedia.org/wiki/Vi_(text_editor)) introduced them.

Ah, and <abbr title="The ubiquitous editor">Vim</abbr> today offers a lofty
**forty-five** registers, complete with bindings to append, replace, print from
as plain text, print from as if you were typing it, _et cet._; see [`:help
registers`](https://vimdoc.sourceforge.net/htmldoc/usr_10.html).

**But I digress.**

What Vim doesn't quite do with its many registers is **avail them to other
applications**.  For that, you've got your syste—

Ah, I'm being told that neither _Windows_ nor _macOS_ actually
offers any more than _one_ measly "clipboard", despite `X11`
having had, **since the early 1990s** at the latest, a
[complete, detailed specification for **no less than three such
buffers**](https://www.x.org/archive/current/doc/xorg-docs/icccm/icccm.pdf),
two of which are exceptionally convenient and still **completely
supported and working across the board (BSD and Linux)**—even many
[Wayland](https://wayland.freedesktop.org/) compositors implement that
compatibility to the `X11` specification.

**But I digress some more.**

If you're neither in a sensible text editor, nor on a sensible `OS`, and that
despite your recurring-payment-contingent system gradually unveiling its <abbr
title="lacking, pauce">dearthy</abbr> core, its familiar-enough face has you
keep coming back...  I bid you good luck[^good-luck]; the rest of us shall
tonight feast on a tidy serving of `fcitx5` goodness.

[^good-luck]: I truly mean this in good faith, and you're obviously much welcome
to stay and join us—I only jest here, I have no qualms against users of any
platform.  Plus, in all honestly, I have absolutely no doubt that the very same
capabilities are available on these as well.

## Clipboard history with `fcitx5`

A built-in add-on to `fcitx5`, the `clipboard` module keeps track of the
_"stuff"_ you put in your _"clipboard"_.  Obviously, right?  Well, with two
little notes:

1. The three `X11` _"clipboards"_ I alluded to earlier are collectively referred
   to as **selections**.  They're the `primary`, the `secondary`, and the
   `clipboard`.  Typically, you write to and paste from the `clipboard` (well,
   not really[^not-really-not-directly]) with `Ctrl`+`C` and `Ctrl`+`V`,
   respectively; any piece of text you **select** (double-click, or click and
   hold

<!-- [The `X11` clipboard](@/flight-manual/the-x11-clipboard). TODO: LINKME -->

   [^not-really-not-directly]: Not really.  Not directly.  In fact, nothing ever
   _"writes to it"_—the original authors didn't design them for machines with
   32GB or <abbr title="Random Access Memory">`RAM`</abbr> to waste away on such
   frivolities.  There's a lot more to unpack here, but that'll have to be the
   object of another blog post altogether.

2. The _"stuff"_ only is the **plain text** part of the data that you copied.
   Yes, there are indeed **several parts** in there.  **Typed** data.  Lazily
   **streamed on demand**.  Oh yeah, the `X11` selections function—they're
   a lot more than "some shared data dumps"—they're not even that at
   all[^not-really-not-directly], to begin with!

So, that module grabs the textual content of what goes into your `clipboard`
selection, and keep it in its memory, though **not only that last one**!  At any
time, you can recall the most recent few (how many is configurable), and insert
them [anywhere you can type—more on that later](#anywhere-you-can-type).

To recall your `clipboard` history, the default key binding is `Ctrl`+`;` (the
semicolon).  You may then fully configure how to go about making your selection:
paginate results, navigate through entries or pages, confirm with either `Enter`
or `Space`, cancel with `Escape`, pick a numbered entry right away with `1`
through `<n>` and clear its memory with `Backspace` or `Delete`.

## Due discretion manipulating passwords

As I mean to go over in a future article, the `clipboard` isn't just
(or at all) a _"transient data buffer"_.  If nothing else, **the data
it exposes is typed**—I mean by that that there is some [`MIME`
type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types)
associated with it.

<!-- [The `X11` clipboard](@/flight-manual/the-x11-clipboard). TODO: LINKME -->

One such "type", would be `x-kde-passwordManagerHint`, the de-facto standard
(however limited in use) when describing passwords across sensible platforms.

> [!NOTE]
>
> To be precise, `x-kde-passwordManagerHint` is technically not quite
> adhering to the `MIME` specification: it should rather likely be
> `application/x-kde-passwordManagerHint`.
>
> Moreover, global, top-level `MIME` types are typically
> also registered at the <abbr title="Internet Assigned
> Numbers Authority">`IANA`</abbr>, to its [Media Types
> Registry](https://www.iana.org/assignments/media-types/media-types.xhtml),
> which this isn't; but then again no "password" type is.

Capable password managers adequately make use of such types when providing
data through your **selections** (read: _"clipboard"_).  For illustration,
here's the reference of how [KeePassXC](https://keepassxc.org/) goes about this
implementation:

```cpp,name=Clipboard.cpp
void Clipboard::setText(const QString& text, bool clear)
{
    // ...

    auto* mime = new QMimeData;
    mime->setText(text);
#if defined(Q_OS_MACOS)
    mime->setData("application/x-nspasteboard-concealed-type", text.toUtf8());
#elif defined(Q_OS_UNIX)
    mime->setData("x-kde-passwordManagerHint", QByteArrayLiteral("secret"));
#elif defined(Q_OS_WIN)
    mime->setData("ExcludeClipboardContentFromMonitorProcessing", QByteArrayLiteral("1"));
    mime->setData("CanIncludeInClipboardHistory", {4, '\0'});
    mime->setData("CanUploadToCloudClipboard ", {4, '\0'});
#endif

    // ...
}
```
{{ note(msg="available [in their repository on GitHub](https://github.com/keepassxreboot/keepassxc/blob/f484d7f5ed00d77a6cd5f913663f5c437707901a/src/gui/Clipboard.cpp#L55-L65)") }}

Then, courteous _"clipboard"_ inspectors may give you **the privacy you
deserve in handling that data**.  By default, `fcitx5`'s `clipboard` add-on,
when prompted to display recent entries for reuse, will indicate them with
`•••••••• <Password>` instead of disclosing their contents.  The
actual underlying passwords will still be put in[^input-vs-inputted] when you so
choose, they're merely obscured for greater assurances that nobody may lay their
eyes on them.

[^input-vs-inputted]: I'd use _"input"_ as the past participle of the verb _"to
input"_, just like I'd use _"(broad)cast"_ over _"(broad)casted"_, but the few
authoritative dictionaries I consult, and [the one linguist whose influence is
greatest](https://en.wikipedia.org/wiki/Geoff_Lindsey) on my English nowadays,
are definitely aligned on the idea that **linguistics is descriptive rather than
prescriptive**—I went with "put in" to ruffle no feathers.

> [!NOTE]
>
> The `•••••••• <Password>` entry that `fcitx5` may display
> always uses 8 "bullet" characters (`•`), **regardless of the actual length
> of the corresponding password**.  There's absolutely no information surfacing
> about the content of the password then; only its nature is revealed.

I wanted to ascertain something and ended up also looking up `fcitx5`'s
implementation regarding that password handling mechanism, so I might as well
leave some interesting excepts here for explanation:

```cpp,name=clipboard.h
constexpr char PASSWORD_MIME_TYPE[] = "x-kde-passwordManagerHint";
```
{{ note(msg="find it also [here on GitHub](https://github.com/fcitx/fcitx5/blob/39274f29116681a16c3a0b02b814369c6530df09/src/modules/clipboard/clipboard.h#L45)") }}

<br>

```cpp,name=waylandclipboard.cpp
static const std::string passwordHint = PASSWORD_MIME_TYPE;
if (mimeTypes_.contains(passwordHint)) {
    receiveDataForMime(passwordHint, [this, callbackWrapper](const std::vector<char> &data) {
        if (std::string_view(data.data(), data.size()) == "secret" && ignorePassword_) {
            FCITX_CLIPBOARD_DEBUG() << "Wayland clipboard contains password, ignore.";
            return;
        }
        isPassword_ = true;
        receiveRealData(callbackWrapper);
    });
} else {
    receiveRealData(callbackWrapper);
}
```
{{ note(msg="find it also [here on GitHub](https://github.com/fcitx/fcitx5/blob/39274f29116681a16c3a0b02b814369c6530df09/src/modules/clipboard/waylandclipboard.cpp#L166-L181)") }}

I should note that this behaviour only is the default one, but that `fcitx5` may
be configured in several ways, either to ignore these records altogether, denote
them with the aforementioned bullets, or let them be shown plainly.

> [!TIP]
>
> On the topic of discretion with regards to data shown on screen, competent
> compositors also provide a way to block out some windows from your screen
> sharing activities.  See [niri's
> documentation](https://github.com/YaLTeR/niri/wiki/Screencasting#block-out-windows)
> for illustration.

## Anywhere you type {#anywhere-you-type}

On the topic of passwords, another benefit of using `fcitx` is that it still
is an **input method**, rather than a tool that pastes content.  From the
perspective of the applications that receive your input, you're indeed just
typing text in.

Take the example of these utterly misguided—and hopefully
antiquated—practice[^dont-disallow-pasting], whereby some **password inputs
would disallow being pasted into**:

   [^dont-disallow-pasting]: Its main achievement is in **ensuring you're using
passwords you remember**, and that very principle is indeed becoming antiquated
quite fast.  It's not that keeping your password nowhere but in your head isn't
safe—that'd be safe alright, even you are subject to losing access—it's that
this practice encourages **reusing passwords, or perhaps familiar patterns in
designing them**: the very fact there's a **design** to your passwords is the
vulnerability.<br>
   Although, come to think of it, [diceware
passphrases](https://en.wikipedia.org/wiki/Diceware) are indeed quite a good
idea, and not too much of a chore to either remember or type.  Maybe the
obsolescence is obsolete.  What goes around comes around!

```html
<input type="password" onpaste="return false;" placeholder="Passwords, please!">
```

<!-- can't spread this over several lines, lest it gets wrapped into a <p> -->
<input type="password" onpaste="return false" placeholder="Passwords, please!" style="display: block; background-color: var(--colour-surface0); border: 1px solid var(--colour-accent); padding: .5rem 1rem; color: var(--colour-text); width: var(--column-width); box-shadow: 0 3px 0 0 var(--colour-crust); margin: 0 auto 3px;">
{{ note(msg="you shouldn't be able to **paste** anything in this `<input>`") }}

No pasting allowed.  But if you're running `fcitx5`, you may just open up
your trusty global clipboard machine and pour your precious secrets into my
confidential ear—though if you'd be so kind as to rather mail me them, as I
don't operate a [keylogger](https://en.wikipedia.org/wiki/Keystroke_logging)
here...

Though pretty neat, this may come "at the cost" to what a more general-purpose
"clipboard history manager" may give you: **`fcitx5` only handles textual data**
through its `clipboard` add-on.  In reality of course, no feature was sacrificed
for this one: what we have here is is only the corollary to `fcitx5` still
being, at its core, an <abbr title="IM" font="mono">**Input Method**</abbr>
provider—a pretty good one.
