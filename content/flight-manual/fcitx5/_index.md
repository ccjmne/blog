+++
title = 'Maybe a new `fcitx`'
sort_by = 'slug'

[extra]
series = true
+++

`IBus`, standing (vaguely) for _"Intelligent Input Bus"_, is an **input
framework** that allows users to, for example, switch between different keyboard
layouts, which any non-English native speakers reading this blog would certainly
be familiar with.

It is notably used by default by `GNOME`-based desktop environments, making it
the _de facto_ standard for many Linux users; however, it has been somewhat
finicky for me (and others) when working with <abbr title="A replacement for the
X11 window system protocol">Wayland</abbr>[^wayland-finicky]—which is where
`fcitx5`[^fcitx-5] comes in.

[^wayland-finicky]: Although "applications being finicky" under Wayland will
come at no surprise to anyone, I will note that it mostly has to do with running
a lot of <abbr title="X Window System version 11">`X11`</abbr> applications
actually **through a compatibility layer**, and [`NVIDIA` notoriously having
been an execrable collaborator](https://www.youtube.com/watch?v=MShbP3OpASA) in
helping the Linux kernel developers integrate their hardware into the ecosystem.

[^fcitx-5]: `fcitx5` is a fairly recent project (started around 2019) led by the
same original author, a _complete rewrite_ of its predecessor, infusing new life
into `fcitx` notably in including first-class Wayland support, a vastly more
modern codebase, greater performance (reportedly), and some unified theming and
configuration tools.

But `fcitx5` **is a lot other than "Wayland's `IBus`"**: just as vaguely, it
stands for _"Flexible Context-aware Input Tool with eXtension support"_, and in
this series, I mean to delve deeply into the most practical and ubiquitous of
its built-in modules.
