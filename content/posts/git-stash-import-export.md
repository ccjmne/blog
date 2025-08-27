+++
title = 'Share and recover your Git stashes with ease'
date = 2025-08-26
description = '`Import` and `export` your Git stashes with the `2.51` release'
+++

<abbr title="The stupid content tracker">Git</abbr> `2.51`[^2.51] released a
week ago and is packed with upgrades to its plumbing and performance, with
better indexes for some packfiles, *noticeably* improved `fetch`/`push` speed,
deprecation[^istillusethis] of `whatchanged`, and promotion of `git switch`
and `git restore` out of experimental status (though `checkout` is *not going
anywhere*).

Yet, to the <abbr title="Having two phases">diphasic</abbr>[^diphasic] end-user,
the unassuming highlight of this release is the ability to **share your stashes
through your remote**: let's check it out!

[^2.51]: Git `2.51` ([release notes](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.51.0.adoc))
was released on August 18, 2025.

[^istillusethis]: With 2.51, `git whatchanged` shall only function when paired
when invoked with the `--i-still-use-this` flag, just like `pack-redundant` was,
2 years ago.  That's some pretty hard deprecation: I like it.  It's scheduled to
be removed in Git 3.0.

[^diphasic]: "Having two phases"
([Merriam-Webster](https://www.merriam-webster.com/dictionary/diphasic)).  I
refer here to the migration to your personal computer after work.

<!--more-->

## Obligatory [TL;DR](https://en.wikipedia.org/wiki/TL;DR)

```sh
git stash export --to-ref refs/stashes/my-stash
git push origin refs/stashes/my-stash
```

This creates a new ref called `my-stash` under `refs/stashes/` and pushes it
upstream (to a remote whose name is `origin`).

On another machine, fetch all remote stashes and import the one you want:

```sh
git fetch origin '+refs/stashes/*:refs/stashes/*'
git stash import refs/stashes/my-stash
```

The `fetch` command uses a refspec to fetch all stashes under `refs/stashes/`
and store them locally under the same path: `<remote-ref>:<local-ref>`.  The `+`
is equivalent to `--force`, to overwrite any existing local ref or the same
name.

### A note on garbage collection

Remember that these are **dangling refs**, and as such are subject to garbage
collection, if you've skilfully set up your repository.  Chances are that your
Git host provider *does* by default end up pruning these after a while: nobody
wants to keep around stale references forever that aren't reachable from any
branch or tag.

### See how the sausage is made

Here's a link to the [commits
introducing](https://github.com/git/git/compare/a013680162522425ab74d12f1d0cd4df1a389383...bc303718cc288b54233b204ce88223a16fb38487) these changes.

## Stashes were inherently local

   Until now, your stashes lived only as `reflog` under a single `ref/stash`
reference, which is not only fairly impractical for programmatic manipulation,
but also means that all but the latest one essentially only existed *locally on
your host*.<br>
   If you wanted to move them elsewhere, you had to resort to savvy (let's not
call them "awkward") workarounds: patch files, stash branches, cherry-picking...
Anything would go, with the exception of outright copying entire files or tree
on your file-system, I'm sure.

### Aren't they just usable commits under the hood?

   `Jein` ("yes and no"), as my German colleagues would say.<br>
   You could always `git show stash@{0}` and see it in all its splendour to find
out.  Let's do just that!

```sh
cd $(mktemp -d)
git init  # ....................... 1. New repo with an empty file
touch file
git add file
git commit --message 'Create file'
echo 'Line 1' >> file  # .......... 2. Stage a change to the file
git add file
echo 'Line 2' >> file  # .......... 3. Modify the workdir
touch other-file  # ............... 4. Add a new untracked file
git stash push  # ................. 5. Stash everything
```
{% note(type="comment") %} note the nifty `cd $(mktemp -d)`: you may follow along by copy-pasting without risk {% end %}

Here, I create a repository with a single commit containing a single empty file,
`file`.  I add two lines to it, then stage the first one but not the second.  I
also create an untracked file, `other-file`, then I stash all my changes.

What have we done?!  Here's the monstrosity:

```sh
git show stash@{0} --oneline --decorate
```
<pre class="language-txt z-code"><code><span class="term-fg33">a196b1a (</span><span class="term-fg35 term-fg1">refs&#47;stash</span><span class="term-fg33">)</span> WIP on master: d4d8585 Create file
&nbsp;
<span class="term-fg1">diff --cc file</span>
<span class="term-fg1">index e69de29,3be9c81,0000000..c82de6a</span>
mode 100644,100644,000000..100644
<span class="term-fg1">--- a&#47;file</span>
<span class="term-fg1">+++ b&#47;file</span>
<span class="term-fg36">@@@@ -1,0 -1,1 -1,0 +1,2 @@@@</span>
<span class="term-fg32">+ +Line 1</span>
<span class="term-fg32">+++Line 2</span></pre></code>
{% note(type="comment") %} the `diff --cc` will show the "combined diff", when a commit has several parents (a "merge commit") {% end %}

### One stash, several commits

Let's not go today over how precisely to decipher the content of an octopus
commit[^octopus], when a picture may well be worth a thousand words:

[^octopus]: I call an *octopus commit* that, because it has many arms!
Sometimes I call them *hydra*, with greater reverence, when they are
particularly hard to tame.  Neither term is part of the customary
Git vernacular, but "octopus" is used to refer to a specific [merge
strategy](https://git-scm.com/docs/merge-strategies).

```sh
git log stash@{0} --oneline --decorate --graph
```
<pre class="language-txt z-code"><code>*<span class="term-fg33">-.</span>   <span class="term-fg33">a196b1a (</span><span class="term-fg35 term-fg1">refs&#47;stash</span><span class="term-fg33">)</span> WIP on master: d4d8585 Create file
<span class="term-fg31">|</span><span class="term-fg32">\</span> <span class="term-fg33">\</span>
<span class="term-fg31">|</span> <span class="term-fg32">|</span> * <span class="term-fg33">15f2a4d</span> untracked files on master: d4d8585 Create file
<span class="term-fg31">|</span> * <span class="term-fg33">aa4fa9e</span> index on master: d4d8585 Create file
<span class="term-fg31">|&#47;</span>
* <span class="term-fg33">d4d8585 (</span><span class="term-fg36 term-fg1">HEAD</span><span class="term-fg33"> -&gt; </span><span class="term-fg32 term-fg1">master</span><span class="term-fg33">)</span> Create file</pre></code>

Would you look at that!  Your stash isn't *one* commit, it's possibly **three**:
one for each of your staged, your unstaged, and your untracked changes,
respectively.

## A fourth parent with `2.51`

You know what the stash commit needs?  *More parents, of course!*

With Git `2.51`, you may opt into a new representation of your stashes, which
will have **one more parent**.  It's actually only a bit of a joke[^4-parents],
since in reality we're talking of an extra commit with two parents, on top of
your current commit with three parents.

[^4-parents]: I thought the joke about stash-commits having *four parents* would
make the solution scarier than it is, but I have some doubts now that I actually
describe the reality aloud.

The `export` subcommand to `git stash` lets you use that new format.  With it,
you need to use one of the `--print` or `--to-ref <ref>` options, to either
display the hash of the new stash commit or save it under a specific ref,
respectively.

```sh
git stash export --print stash@{0}
```
```txt
3e57536c189d73308254f5e3f233b9b97e016d11
```
{% note(type="comment") %} get the hash of your stash's new variant representation with `export --print` {% end %}

Let's open it up and see what it hides:

```sh
git log $(git stash export --print stash@{0}) --oneline --decorate --graph
```
<pre class="language-txt z-code"><code>*   <span class="term-fg33">3e57536</span> git stash: WIP on master: d4d8585 Create file
<span class="term-fg31">|</span><span class="term-fg32">\</span>
<span class="term-fg31">|</span> *<span class="term-fg35">-.</span>   <span class="term-fg33">a196b1a (</span><span class="term-fg35 term-fg1">refs&#47;stash</span><span class="term-fg33">)</span> WIP on master: d4d8585 Create file
<span class="term-fg31">|</span> <span class="term-fg33">|</span><span class="term-fg34">\</span> <span class="term-fg35">\</span>
<span class="term-fg31">|</span> <span class="term-fg33">|</span> <span class="term-fg34">|</span> * <span class="term-fg33">15f2a4d</span> untracked files on master: d4d8585 Create file
<span class="term-fg31">|</span> <span class="term-fg33">|</span> * <span class="term-fg33">aa4fa9e</span> index on master: d4d8585 Create file
<span class="term-fg31">|</span> <span class="term-fg33">|&#47;</span>
<span class="term-fg31">|</span> * <span class="term-fg33">d4d8585 (</span><span class="term-fg36 term-fg1">HEAD</span><span class="term-fg33"> -&gt; </span><span class="term-fg32 term-fg1">master</span><span class="term-fg33">)</span> Create file
* <span class="term-fg33">73c9bab</span></pre></code>

{% note(type="comment") %} the `a196b1a` commit (second parent) is the regular, historical "stash commit", `stash@{0}` {% end %}

This is the same command as before, except that where I would before use
`stash@{0}` as the reference to `log`, I now use `$(git stash export --print
stash@{0})` instead, to use the new model.

The additional commit introduced under this new format is `3e57536`, whose
parents are `a196b1a` (the "regular", historical stash commit) and `73c9bab`.

   What is `73c9bab`?  Just an **entire secondary history** to your
repository!<br>
   This alternative initial commit is only a dummy one, to mark the base of your
stash stack:

```sh
git show 73c9bab
```
<pre class="language-txt z-code"><code><span class="term-fg33">commit 73c9bab443d1f88ac61aa533d2eeaaa15451239c</span>
Author: git stash &lt;git@stash&gt;
Date:   Mon Sep 17 00:00:00 2001 +0000</code></pre>

As a fun tidbit, that date is essentially some sort of quirky
"Git epoch".  It's not Git's birthday (despite [an attempt to
have it as such](https://marc.info/?l=git&m=117230943206808)),
but is here to stay regardless.  See [`git format-patch`'s
documentation](https://git-scm.com/docs/git-format-patch#_description).

## Your stash stack

Finally, we arrive at the point of this entire post: stashes that used to only
be available through the `reflog` of `refs/stash` now properly *exist* as a
bunch of references that you can actually `push` and `fetch`.  You may even move
around your entire stack, or any subset of it, at once.

Let's push another stash:

```sh
echo 'Line 3' >> file
git stash push --message 'A new stash'
```
That new stash (whose message I set, to avoid confusion) is now the top of our
stash stack:

```sh
git log --oneline --decorate --graph stash@{0}
```
<pre class="z-code"><code>*   <span class="term-fg33">157c3dc (</span><span class="term-fg35 term-fg1">refs&#47;stash</span><span class="term-fg33">)</span> On master: A new stash
<span class="term-fg31">|</span><span class="term-fg32">\</span>
<span class="term-fg31">|</span> * <span class="term-fg33">d94cc67</span> index on master: d4d8585 Create file
<span class="term-fg31">|&#47;</span>
* <span class="term-fg33">d4d8585 (</span><span class="term-fg36 term-fg1">HEAD</span><span class="term-fg33"> -&gt; </span><span class="term-fg32 term-fg1">master</span><span class="term-fg33">)</span> Create file</pre></code>
{% note(type="comment") %} the new stash, `157c3dc`, is at the top of the stack, `stash@{0}`, or `refs/stash` {% end %}

As a reminder, here's the earlier stash, now at `stash@{1}`:
```sh
git log --oneline --decorate --graph stash@{1}
```
<pre class="z-code"><code>*<span class="term-fg33">-.</span>   <span class="term-fg33">a196b1a</span> WIP on master: d4d8585 Create file
<span class="term-fg31">|</span><span class="term-fg32">\</span> <span class="term-fg33">\</span>
<span class="term-fg31">|</span> <span class="term-fg32">|</span> * <span class="term-fg33">15f2a4d</span> untracked files on master: d4d8585 Create file
<span class="term-fg31">|</span> * <span class="term-fg33">aa4fa9e</span> index on master: d4d8585 Create file
<span class="term-fg31">|&#47;</span>
* <span class="term-fg33">d4d8585 (</span><span class="term-fg36 term-fg1">HEAD</span><span class="term-fg33"> -&gt; </span><span class="term-fg32 term-fg1">master</span><span class="term-fg33">)</span> Create file</pre></code>
{% note(type="comment") %} the earlier stash, `a196b1a`, is now the second entry on the stack, `stash@{1}`, but no more `refs/stash` {% end %}

The new model for stashes allow us to refer to our *entire stash stack*
directly, since they'll be parents of one another, provided that you want this
behaviour.

Note that you may pass a list of stashes to `git stash export --print`, or omit
it altogether to export the stack in its entirety:

```sh
git log $(git stash export --print stash@{0} stash@{1}) --oneline --decorate --graph
git log $(git stash export --print) --oneline --decorate --graph
```
<pre class="z-code"><code>*   <span class="term-fg33">ba4fea2</span> git stash: On master: A new stash
<span class="term-fg31">|</span><span class="term-fg32">\</span>
<span class="term-fg31">|</span> *   <span class="term-fg33">157c3dc (</span><span class="term-fg35 term-fg1">refs&#47;stash</span><span class="term-fg33">)</span> On master: A new stash
<span class="term-fg31">|</span> <span class="term-fg33">|</span><span class="term-fg34">\</span>
<span class="term-fg31">|</span> <span class="term-fg33">|</span> * <span class="term-fg33">d94cc67</span> index on master: d4d8585 Create file
<span class="term-fg31">|</span> <span class="term-fg33">|&#47;</span>
* <span class="term-fg33">|</span>   <span class="term-fg33">3e57536</span> git stash: WIP on master: d4d8585 Create file
<span class="term-fg35">|</span><span class="term-fg36">\</span> <span class="term-fg33">\</span>
<span class="term-fg35">|</span> <span class="term-fg36">|</span> <span class="term-fg33">\</span>
<span class="term-fg35">|</span> <span class="term-fg36">|</span>  <span class="term-fg33">\</span>
<span class="term-fg35">|</span> *<span class="term-fg33 term-fg1">-.</span> <span class="term-fg33">\</span>   <span class="term-fg33">a196b1a</span> WIP on master: d4d8585 Create file
<span class="term-fg35">|</span> <span class="term-fg33">|</span><span class="term-fg32 term-fg1">\</span> <span class="term-fg33 term-fg1">\</span> <span class="term-fg33">\</span>
<span class="term-fg35">|</span> <span class="term-fg33">|</span> <span class="term-fg32 term-fg1">|</span><span class="term-fg33">_</span><span class="term-fg33 term-fg1">|</span><span class="term-fg33">&#47;</span>
<span class="term-fg35">|</span> <span class="term-fg33">|&#47;</span><span class="term-fg32 term-fg1">|</span> <span class="term-fg33 term-fg1">|</span>
<span class="term-fg35">|</span> <span class="term-fg33">|</span> <span class="term-fg32 term-fg1">|</span> * <span class="term-fg33">15f2a4d</span> untracked files on master: d4d8585 Create file
<span class="term-fg35">|</span> <span class="term-fg33">|</span> * <span class="term-fg33">aa4fa9e</span> index on master: d4d8585 Create file
<span class="term-fg35">|</span> <span class="term-fg33">|&#47;</span>
<span class="term-fg35">|</span> * <span class="term-fg33">d4d8585 (</span><span class="term-fg36 term-fg1">HEAD</span><span class="term-fg33"> -&gt; </span><span class="term-fg32 term-fg1">master</span><span class="term-fg33">)</span> Create file
* <span class="term-fg33">73c9bab</span></pre></code>
{% note(type="comment") %} yes, I'll admit, this looks mad {% end %}

Try to focus on the leftmost branch: that's your stash stack, with `ba4fea2` at
the top, `3e57536` next, and `73c9bab` (the dummy initial "stash stack" commit)
at the bottom.

*Voilà*!  You need only your one reference from `git stash export --print`, and
can carry around your entire stash stack.

## So what?

There's a counterpart to the `--print` option: `--to-ref <ref>` lets you export
your stash stack (in its newly introduced model) to a proper Git ref, which you
can then push and fetch like any other reference:

```sh
git stash export --to-ref refs/my-stash
```

There we go, `refs/my-stash` is there.  You can lose and recover it all with
ease:

```sh
git stash list
# stash@{0}: On master: A new stash
# stash@{1}: WIP on master: d4d8585 Create file
git stash drop
# Dropped refs/stash@{0} (157c3dc905a6c52c6a56044e58d042b69827d8c4)
git stash drop
# Dropped refs/stash@{0} (a196b1a4c22a877046a8591fd15aedc4d596698b)
git stash list
# <no output>
git stash import refs/my-stash
git stash list
# stash@{0}: On master: A new stash
# stash@{1}: WIP on master: d4d8585 Create file
```

And of course, you can push and fetch `refs/my-stash` to and from any remote
repository, just like any other ref.

```sh
git push origin refs/my-stash
```
Then, on another machine:

```sh
git fetch origin refs/my-stash:refs/my-stash
git stash import refs/my-stash
```

   Though I should point out that the community (well, the very, very few
people that have been playing with this bleeding-edge feature) suggests to
keep things a bit more organised, and use `refs/stashes/<name>` instead of
`refs/<name>`.<br>
  I'll adopt this convention (in the making) going forward.

Have fun!
