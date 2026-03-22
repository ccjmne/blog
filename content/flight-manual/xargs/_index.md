+++
title = 'The complete `xargs` rulebook'
sort_by = 'slug'
extra.series = true
+++

The shell's pipe operator, `|`, is a marvellous thing: it connects the _standard
output_ of one command to the _standard input_ of another, letting you chain
utilities together into elegant pipelines.  But quite a few times, it's the
very **flags or arguments** of some subsequent invocation that you want to be
determined by the **output** of a previous one.

Enter `xargs`: the adapter that bridges this gap, transforming `stdin` into
arguments for commands that won't read from it otherwise.

This series presumes to put together a **quite comprehensive guide on all
pragmatic `xargs` things**.  That does suggest that not quite everything will be
covered, but will give you all that you need to go about your `CLI` life with
much fluency, some bravado, and perhaps even a touch of grace.
