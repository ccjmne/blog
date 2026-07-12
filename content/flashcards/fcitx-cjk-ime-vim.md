+++
title = 'Reconciling your `CJK` prose with the Vim motions'
date = 2026-06-29
description = 'Not just <abbr title="Chinese, Japanese and Korean [writing systems]">`CJK`</abbr>, but any <abbr title="Input Method Editor">`IME`</abbr> other than the destined one that you moulded your body and mind around for your most acrobatic text navigation purposes'
taxonomies.section = ['flashcards']
taxonomies.tags = ['all', 'vim', 'fcitx5', 'quibblery', '한국어']
extra.cited_tools = ['fcitx5', 'vim']
+++

Say that you're not always typing some fairly boring `ASCII`-only content, to
the point you end up using an Input Method ("`IM`") that doesn't give you access
to `h`, `j`, `k`, `l` where you expect them—or any of the litany of other
normal-mode mappings which you surely don't need me to tell you all about.

## The problem illustrated: some <abbr title="Chinese, Japanese and Korean [writing systems]">`CJK`</abbr> input method

Let's take the example of a form of Korean input method, where the
character[^not-just-a-character] that is _"buffered"_ by pressing the key
typically labelled `j` on a keyboard using the US layout:

[^not-just-a-character]: In the Korean writing system (한글), ㅓ isn't
necessarily the **character** that would be in your `IME` buffer as you tap the
corresponding key, but it nonetheless is the Korean Hangeul letter (자모) that
it corresponds to.

> [!NOTE]
>
> Note that I'm assuming the—most standard—_dubeolsik_ (두벌식) layout.

While in `i`nsert mode: brilliant, you get to type away as expected; while in
normal mode however, you don't get to navigate down, or anywhere else for that
matter, since <abbr title="The ubiquitous text editor">Vim</abbr> doesn't come
with a bunch of bindings mapping various 자모 and 음절 to some sort of
actions.

You could indeed just do:

```vim
nmap ㅗ h
nmap ㅓ j
nmap ㅏ k
nmap ㅣ l
```
{{ note(msg='Mapping the 자모 that "happen" via the keys labelled `h`, `j`, `k`, `l` as "expected" in `n`ormal mode') }}

But this comes with two shortcomings, each of which would already be crushing on
its own:

1. you'd have to remap **everything** (oh, trust me, there's a lot more to
   "everything" than the measly 26 letters of the Latin alphabet and their
   capital variants), and
2. your `IME` doesn't commit individual letters (자모), which are buffered and
   submitted only when syllable blocks (음절) are complete.  In consequence:
   - your cursor would only go down not as you press `j`/`ㅓ`, but after you've
     trigged a commit of that character, perhaps by pressing `k`/`ㅏ`, and
     you'd visually always be lagging at least one input late.
   - the rules for triggering a "committing" of some individual letter are quite
     intuitive when actually using the Korean writing system (한글), but would
     be impossibly tedious when trying to emit partial syllable blocks (음절).

## My work-in-progress starter solution

Whereas all you really want would be to always switch to the plain US English
layout whenever in `n`ormal mode, and switching back to whichever mode you were
in, as you go into `i`nsert mode.

Yep.  Your Vim brain just went: _"so, two `autocmd`s?"_, and you're exactly
right: two `autocommands` (plus perhaps some extra trickery for the less obvious
cases).

Behold, the three lines of Vim script to drop anywhere and reconcile your <abbr
title="Chinese, Japanese and Korean [writing systems]">`CJK`</abbr> prose with
the Vim motions!

```vim
let g:fcitx_state = system("fcitx5-remote")
autocmd InsertLeave * let g:fcitx_state = system("fcitx5-remote") | call system("fcitx5-remote -c")
autocmd InsertEnter * if g:fcitx_state == 2 | call system("fcitx5-remote -o") | endif
```

This code essentially relies on the presumption that your **"`IME` inactive"**
state (state `1`) is something usable in `n`ormal Vim mode, such as
`us-english`.  Conversely, the **active** state, `2`, corresponds to your
prosodic input method.

In a nutshell, it stores `fcitx5`'s current active or inactive state, then:

- whenever you **leave `i`nsert mode**, it saves that state again and
  deactivates the input method, and
- whenever you **enter `i`nsert mode**, it checks whether the saved state was
  active (2), and re-activates it if so.

In practice, that means `n`ormal mode forces the input method "off", whereas
`i`nsert mode **restores** it if it was ever set in the first place.

## Going further

Though this is simple and effective, intense use may reveal it to be still rough
around the edges.

There's more that could be done, mostly generally regarding **supporting the
many other modes**, such as `c`ommand; as well as possibly enforcing/restoring
your general input method of choice input method **when a normal-mode Vim gets
or loses focus**...  And possibly guard against curious mishaps when switching
modes while replaying macros.

Several people online have shared their more-or-less polished versions of this
set-up, but none really worked most splendidly for me, so I'll start simple and
bridge the gaps that I need bridged, over time: if nothing else, I'll get to
hone my tools and refine my skills.

And if you figure it out before me, don't hesitate to share!  
In the meantime, good luck, and have fun.
