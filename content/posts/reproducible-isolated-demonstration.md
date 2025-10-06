+++
title = 'Reproducible, isolated demonstrations'
date = 2025-08-10
description = 'Create reproducible, isolated demonstration environments with containers'
taxonomies.tags = ['all', 'cli', 'tools', 'docker']
extra.toc = false
+++

Earlier this week, I put together installation instructions for a syntax support
package for <abbr title="The ubiquitous text editor">Vim</abbr>.

I have an idea how these things work and I'm fairly confident that `-u NONE`
will get Vim to disregard my years of sensibly crafted configuration, but I
wanted to go one step further: **from zero to a working plug-in, undoubtedly
reproducible on any machine**.

<!-- more -->

I spun up a fleeting shell session in a base [Docker](https://www.docker.com/)
image of my distribution of choice, installed the editor, the plug-in, verified
its functionality and *voilà*!

```sh
docker run --rm -it archlinux sh
pacman -Sy --noconfirm vim git
cat > work.klg <<EOF
2025-08-10 (8h!)
Getting some #work done.
    08:45 - ?
    -1h #lunch
EOF
# The demonstrably complete instructions: have the plug-in on your runtimepath
git clone https://github.com/73/vim-klog.git
vim -u NONE +'set rtp+=vim-klog' +'syn on' work.klg
```
{{ note(msg='I like using `--rm -it`, for which you may use the mnemonic "remove it"') }}

Just like that, a fresh Vim installation, augmented with the correct file type
detection and corresponding syntax highlighting, right off the `master` branch
of its plug-in's source code: no compilation even needed[^bare-and-simple].
Wanna give it a spin?  Assuming you already have your favourite distribution's
image ready, pasting the few commands above gets you **up and running in 5
seconds flat**.

[^bare-and-simple]:  By the way, the entire project consists of *TWO!* measly
files (it does two things, after all), plus a short `README` and its supporting
`LICENSE`.  No fuss, no dependencies, no compilation: no problem.

With the simple `docker run` command, your container will be pruned as soon as
you exit your shell: the above excerpt even contains all the clean-up you need.

I figured I'd try with <abbr title="The one capable 'alternative' to Vim
">Neovim</abbr>, too, to make sure that the *exact same instructions* (using
`nvim` instead of `vim`) work just as well.  Lo and behold: of course it does.

No more guesswork, no more "well, on my machine [...]"; we have access to as
many fully isolated environments as we want: make good use of them!
