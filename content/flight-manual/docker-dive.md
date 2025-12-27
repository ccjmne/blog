+++
title = 'Explore Your Docker Images with Dive'
date = 2025-12-12
description = 'Put on your scaphander and get a sense for what goes in the depths of your Docker images.'
taxonomies.section = ['flight-manual']
taxonomies.tags = ['all', 'cli', 'docker']

[[extra.cited_tools]]
   name    = "dive"
   repo    = "https://github.com/wagoodman/dive"
   package = "extra/x86_64/dive"
   manual  = "https://github.com/wagoodman/dive"
[[extra.cited_tools]]
   name    = "docker"
   repo    = "https://github.com/moby/moby"
   package = "extra/x86_64/docker"
   manual  = "https://docs.docker.com/"
+++

> [!NOTE]
>
> **This customary first introductory section is far too long and beside the
> point**.  But you may jump right [back on topic](#back-on-topic) without
> losing anything of any technical relevance to this article.

Some months ago, I was **refactoring some 20+ years of disparate
configuration**, put together and gradually defaced by several teams over two
decades, without any official ownership, documentation, coordination, nor even
(evidently) communication or a shared vision.

Ah, and ideally it'd work just as well across several versions of the
mad, multilayered reverse-proxy/load-balancer/web-server these sprawling
and several configuration repositories were presuming to pilot: [Apache
`HTTPD`](https://httpd.apache.org/).

Get this: our development, production and staging environments are not in any
remote sense of parity, neither by:

- the number of layers of reverse proxies,
- the versions of said proxies,
- their enabled modules,
- their configuration,
- their underlying operating systems...

Oh and, we can't install the same version across all environments, 'cause some
of them run `OS`es so ancient their `glibc` can't compile anything vaguely
contemporary, such as a version of [OpenSSL](https://openssl-library.org/)
that accepts `ssh-rsa` keys.  And boy, is the retirement of these servers an
impenetrably complex endeavour of its own.

Long story short, it wasn't your run-of-the-mill refactoring job, and certainly
nothing that can be `LLM`'d away.  The task was deemed impossible, so when it
also acquired the _essential_ status, yours truly was let loose.

## Back to the topic {#back-on-topic}

Since pretty much all of that Apache `HTTPD` pre-dates the idea of
containerisation (or that of complete and accurate documentation, it seems), at
some point came the question of where the _!@#$_ are the bits and pieces in each
of these few third-party [Docker](https://www.docker.com/) images we had been
using.

You could `docker exec sh` and explore in there, but there's quite a bit of
places to look into and it's not the ideal way to get a good overview; and you
could perform some tool-assisted search, but you may not quite be sure what the
files you'd be looking for would be called exactly.  You could also read through
the various `Dockerfile`s, which reference other base images, which in turn
reference other base images, _et cet._

### A quick overview

**OR!** You could put on your <abbr title="(dated) A kind of diving
suit">scaphander</abbr> and interactively explore the contents of each layer of
your Docker images with [`dive`](https://github.com/wagoodman/dive).

Let's take a quick look at its `UI` that I semi-faithfully re-created below:

```sh
dive httpd:2.4
```
<pre class="z-code language-txt"><code><strong>│ Layers ├────────────────────────────────────────────</strong> <strong>│ Current Layer Contents ├─────────────</strong>
Cmp   Size  Command                                    ├── bin → usr/bin
<span class="term-fg34 term-inv">  </span>   79 MB  FROM blobs                                 ├── boot
<span class="term-fg34 term-inv">  </span>     0 B  RUN /bin/sh -c mkdir -p "$HTTPD_PREFIX"    ├── dev
<span class="term-fg34 term-inv">  </span>     0 B  WORKDIR /usr/local/apache2                 <span class="term-fg33">├── etc</span>
<span class="term-fg32 term-inv">  </span> <span class="term-inv"> 5.6 MB  RUN /bin/sh -c set -eux; apt-get install -</span> │   ├── .pwd.lock
     32 MB  RUN /bin/sh -c set -eux; savedAptMark="$(a │   ├─⊕ alternatives
     138 B  COPY httpd-foreground /usr/local/bin/ # bu │   ├─⊕ apt
                                                       │   ├── bash.bashrc
                                                       │   ├── bindresvport.blacklist
<strong>│ Layer Details ├─────────────────────────────────────</strong> │   <span class="term-fg32">├─⊕ ca-certificates</span>
                                                       │   <span class="term-fg32">├── ca-certificates.conf</span>
<strong>Tags:</strong>   <strong>(unavailable)</strong>                                  │   ├─⊕ cron.daily
<strong>Id:</strong>     blobs                                          │   ├── debconf.conf
<strong>Size:</strong>   5.6 MB                                         │   ├── debian_version
<strong>Digest:</strong> sha256:5d3f0156053276adafa015f05477b6d5bbd48d3 │   ├─⊕ default
<strong>Command:</strong>                                               │   ├─⊕ dpkg
RUN /bin/sh -c set -eux;     apt-get install --update  │   ├── environment
  ca-certificates         libaprutil1-ldap         lib │   ├── fstab
                                                       │   ├── gai.conf
<strong>│ Image Details ├─────────────────────────────────────</strong> │   ├── group
                                                       │   ├── group-
<strong>Image name:</strong> <strong>httpd:2.4</strong>                                  │   ├── gshadow
<strong>Total Image size:</strong> 117 MB                               │   ├── host.conf
<strong>Potential wasted space:</strong> 4.0 MB                         │   ├── hostname
<strong>Image efficiency score:</strong> 98 %                           │   ├── issue
                                                       │   ├── issue.net
<strong>Count   Total Space  Path</strong>                              │   ├─⊕ kernel
    2        1.6 MB  /var/cache/debconf/templates.dat  │   <span class="term-fg33">├── ld.so.cache</span>
<span class="term-inv">▏^C Quit ▏^W Switch view ▏^F Filter ▏^Space Collapse all dir ▏^E Extract File ▏^O Toggle sort </span>
</code></pre>

Not too shabby!  You may navigate between successive layers with the arrow
keys (or Vim-like bindings), and see, with each layer, which files were added,
modified or deleted with some colour-coding in the right pane.

I definitely recommend that you take a look at their main
[`README`](https://github.com/wagoodman/dive) page, which features primarily a
screen recording of the tool in action.

### Usage and configuration

Glancing at the bottom, you'll find a non-exhaustive list of keyboard
shortcuts to help you navigate the interface and perform some actions, such as
extracting a file from a layer to your host system for further processing.<br>

> [!TIP]
>
> Well, that specific one merely [results in a systemic segmentation
> fault](https://github.com/wagoodman/dive/issues/620); but hey, you can always
> perform a quick:
>
> ```sh
> docker exec $CONTAINER_NAME cat /path/to/some/file > extracted-file 
> ```

It also offers some configuration, although that may at times cause more
headaches than it solves, in notably its key-binding library being stunningly
incapable, with exceedingly poor documentation and offering the very worst
failure handling ever conceived: altogether silently disabling bindings it
doesn't support or understand.

Nonetheless, here's what I settled on, to make the navigation somewhat more
natural to Vim users, and the file tree somewhat usable:

```yaml,name=$XDG_CONFIG_HOME/dive/config.yaml
keybinding:
  toggle-view: ctrl+w
filetree:
  collapse-dir: true
```

## Not great, but the best

In any case, `dive` is a simple tool for a simple job.  It doesn't do that job
too well, but it does it well enough to be of great relief when you need to do
that one fairly niche task it addresses.

Unfortunately, `dive` is somewhat buggy and inelegant at times: you cannot, for
instance, have an active file filter while still navigating layers, [or even the
file tree itself](https://github.com/wagoodman/dive/issues/627), and it presents
quite a few other very rough edges are in the way of a great experience.

[Its `README`](https://github.com/wagoodman/dive) disclaims:

> **This is beta quality!** Feel free to submit an issue if you want a new
> feature or find a bug :)

While the [project is officially not
abandoned](https://github.com/wagoodman/dive/issues/568) either, that is also a
doubt routinely expressed among the community.

Despite all that, until somebody comes around to rebuild the whole thing into
a solid and sharp tool, **`dive` is still without a doubt the most interesting
option to interactively explore your Docker images' layers**.

Will you need it often?  Probably not.  If you did, you'd know of it already.
In my opinion, the ultimate punch it can throw to have it be adopted is its
ability to run **without being installed**:

```sh
alias dive="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock docker.io/wagoodman/dive"
dive <image>
```

I say, just add that `alias`, remember vaguely that it's called "dive", and on
that one fated day you'll be looking to do one of the things it enables, you
might be pretty pleased with yourself.
