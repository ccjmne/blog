+++
title = 'On shoddy pseudo-technical guides'
date = 2026-03-28
description = 'A condemning commentary on the scarcity of valuable information'
taxonomies.section = ['ramblings']
taxonomies.tags = ['all', 'quibblery']
+++

I do not know everything.

In fact, I—and many of you, I posit—started out with about zero knowledge
besides intuition.  My form then was such that I hadn't yet even quite caught on
to the idea that wiping one's bum would make for a healthy habit.

A curious thing is that I still know about nothing; but
at least I do know just that, which [Socrates might
appreciate](https://en.wikipedia.org/wiki/I_know_that_I_know_nothing).

In consequence, I spend a great deal of my time presumably allocated to _doing
something_ instead **playing and sniffing around, exploring the what-ifs and the
how-elses** to my heart's content.  My employer seems to have no problem with
that[^decent-worker-euphemism], at least so long as once in a while, we do care
about some _how-else_ and, when it is customary for herds of run-of-the-mill,
corporate developers to bring about as much acumen and incisiveness as would
the <abbr title="Large Language Models">`LLM`s</abbr>[^llm-acumen]; then the
resources with the unique dreams and the unique abilities to implement those
dreams simply cannot be emulated nor replaced (within the _"talent"_ these
corporations can acquire, retain or foster, that is).

[^decent-worker-euphemism]: That's a euphemism.  My current employer (at the
time of this writing), just like my previous ones, is elated to have me on
board.  The whole "playing and sniffing around" bit, while accurate, doesn't
do justice to the baseline of work I still get done; [it ain't much, but it's
honest work](https://en.wikipedia.org/wiki/David_Brandt_(farmer)).

[^llm-acumen]: I would best describe the inner workings of these machines that
much of the pretend-technical and technical-adjacent crew are fawning over
today, as _"putting together words that look good together"_.  As such, you'd
imagine that in lieu of savvy, sharp acumen, you'll likely be left with, at
best, **the most generic solutions** to **the problem nearest yours** that has
already been solved countless times.  I don't mean this in a discriminatory
manner or as an attack or denunciation: **its solution shall be generic by
design**.

<div class="hi">

But here's the thing: while the `man`ual's sagacity is nigh infinite, oftentimes
**extracting all of it requires profound, personal experience**, with not only
the topic at hand, but also with the plethora of its accomplices, the great many
utilities and other systems you'll want to weave together into a skilful web.

- A `tmux` pop-up that invokes a script putting something
  into your clipboard?  Not a chance you get it right
  without `nohup`, nor understanding how the [X clipboard
  works](https://www.x.org/archive/current/doc/xorg-docs/icccm/icccm.pdf).
- A [Cookie Clicker](https://cookieclicker.com/) helper, that will
  alternate between _start clicking_ and _stop clicking_ every other
  time you invoke it?  Time to whip out `flock`, but I don't suppose
  you'll come up with `exec 9<> /tmp/click.lock` if you're of the
  [`UUOC`](@/flight-manual/useless-use-of-cat.md) transgressors that have hardly
  even encountered `<` in the first place.
- Bringing together some script that sets up a bidirectional `TCP` tunnel with
  `aws ssm`, and opens your graphical database management tool using the right
  parameters, then kills off the former when you exit the latter?  All you need
  is `mkfifo`, `&`, and `kill -- -$$`—possibly with a splash of `stdbuf`;
  but without already holding onto the ravishing mastery of this constellation
  of simple tools, chances are you'll make-do with running both things in the
  foreground of two separate windows and close them both off manually.<br>
  Sure, you'll forget often about the tunnel and ram yourself right into a
  _"port already in use"_ on the regular, but **what else could we expect?**

Without some understanding of the systems you're presuming to pilot,
**you will not achieve any of the above** with any semblance of
elegance[^minus-points-for-python].  And without having spent much time actually
handling all these tasks, you won't develop much of that understanding...  And
there you have it, **a mutual dependency**, always a riot.  Indeed, how are you
then to build something competent, make yourself apt?

[^minus-points-for-python]:  In this case, my measurement for _"elegance"_ would
be how stark a contrast would the juxtaposition of the task's brief next to its
implementation.  Ah, and that solution's evaluation is capped at _"vile"_ on the
elegance measuring stick, if you manage to get Python to sink its foul fangs
even into this.

</div>

  **Stand on the shoulders of giants**—think
[Thompson](https://en.wikipedia.org/wiki/Ken_Thompson),
[Ritchie](https://en.wikipedia.org/wiki/Dennis_Ritchie),
[Stallman](https://en.wikipedia.org/wiki/Richard_Stallman).<br>
  Or be a rock star for a day [and surf the
crowd](https://en.wikipedia.org/wiki/Crowd_surfing) of savvy like-minded
contributors catching up with the most distinguished icons: consume _"the
documentation"_.  Go ask the people that have a solution already.  Then probe
the other people that have a different one.  And look at the history of either
solution, understand the contexts that shaped them the way they are...

In a few words, **appropriate existing knowledge**.

And here's the subject of today's grave annoyance: **that knowledge is
scarce—it shouldn't be, but it is**.  It is, because scarcity is relative,
and the world has long realised that cobbling together some vaguely copy-pasted
[_"so-and-so-101"_](https://dictionary.cambridge.org/dictionary/english/101)
from the most delirious litany of similar _"tutorial"_ and guides, actually
presents quite the formidable monetary-gains-to-effort ratio[^not-exaggerating].

[^not-exaggerating]: Surely it's not that bad?  Well, try consuming any help on
    getting the most out of your `tmux` set-up, and note how each individual
    write and YouTuber came up with the unique idea of remapping its prefix
    **specifically to `Ctrl-S`** because they personally find `Ctrl-B` too
    much of a (literal, physical) stretch.  And the processions of acolytes
    that flock to Reddit sharing their most perfect set-up, still bearing
    that pathetic mark of beginner that doesn't even do a good job of **being
    clueless**; skipping right to assuming they've got it all figured out, while
    never having actually attempted to contemplate the very fundamentals.

    You'd think I'm extrapolating possibly too much from this one alleged
    "personal" rebind that is in fact quite customary, but it's the other way
    around: I'm acutely aware of the problem and only point to one of its
    obvious symptoms.

<div class="hi">

The Internet today is choke-full of trifling articles spat by clueless
agents **whose years of _"tagging along for the ride of communal
mediocrity"_** actually constitute experience whose value is strictly
negative[^beautiful-ignorance].

[^beautiful-ignorance]: Some more reputable mind already evoked that idea:

    > A man's ignorance sometimes is not only useful, but beautiful—while his
    > knowledge, so called, is oftentimes worse than useless, besides being
    > ugly. Which is the best man to deal with—he who knows nothing about a
    > subject, and, what is extremely rare, knows that he knows nothing, or he who
    > really knows something about it, but thinks that he knows all?
    >
    > {% attribution() %} Henry David Thoreau, _Walking_ {% end %}

   By the time I'm asking the _World Wide
[[sic](@/ramblings/aptly-capitalised-names.md)] Web_ about some tool, some
procedure, some interface, some pattern... I am in need of some **learned
guidance**.  Learned!  Experienced!<br>
  **I am looking for some information that's beyond what I find in the
`man`ual**, not the bastardised drivel tirelessly eroded by generations of
apathetic individuals all relentlessly stagnant in the development of their
craft, each (generation) becoming more certain than the
   previous that the abhorrently poor _"norm"_
is sane, and each further reducing some original
[`TL;DR`](https://en.wikipedia.org/wiki/TL;DR) of the most basic, least
dexterous [happy path](https://en.wikipedia.org/wiki/Happy_path) through some
meaningless hello-world pastiche problem, to the **vague husk of perverted
pseudo-intellectualism that increasingly plagues people, projects and
organisations alike**.

</div>

A technical article with no substance should be deserving of mere scorn,
but collectively, that practice; I hold in contempt.  **My articles shall
be overwhelming, possibly, but they shall be bearing fruits truly not found
elsewhere.**
