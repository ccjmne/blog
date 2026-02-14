+++
title = 'On unfinished software migrations'
date = 2025-10-05
taxonomies.section = ['ramblings']
taxonomies.tags = ['all']
+++

> [!NOTE]
>    This is the sombrer branch of a dystopian choose-your-own-adventure essay
> on systemic failures to carry through sizeable projects in "enterprise"
> environments.<br>
>    Its alternative write-up is found at: [A systemic failure to follow
> through](@/ramblings/failing-to-follow-through.md).

<br>

Suppose that we have a problem.

Suppose that our e-commerce Web app consists essentially of a
patchwork of legacy "enterprise" Java front-and-back–end powered by
[Apache Wicket](https://wicket.apache.org/) (popular 2007–2012),
[Apache Struts](https://struts.apache.org/) (2002–2007), [Apache
Tapestry](https://tapestry.apache.org/) (2004–2007), or **all of the above**,
and we never quite considered ever serving customers on mobile devices.

Or suppose any sort of system deeply entangled with
everything, including itself, some sort of [living root
bridge](https://en.wikipedia.org/wiki/Living_root_bridge), except it's a whole
treetop dwelling, nothing but intertwined roots as far as the eye can see, a
gnarled knitting of [Gordian knots](https://en.wikipedia.org/wiki/Gordian_Knot)
that started out as a decision never formally taken and grew into a
institutionalised way of life.

Well, it's 2025 now, and it turns out that while the IT department never
considered smartphones, tablets (or the fact that windows aren't always
maximised, and on a horizontal monitor with the default font size and zoom
factor), our customer service department did...  Where do they get their ideas
from, eh? [^the-customer]

[^the-customer]: It's the customer.  They get their ideas from the end user,
the people we build this for.  Yeah, this entire thing we pour all that fun
technology into actually wasn't meant to be built for our amusement.  Talk to
your users, or at least analyse how they use your product!

<div class="hi">

The time comes to reinvent the entire thing.  We go for whatever is trendy and
must therefore be the best in all regards, [React](https://react.dev/).  Well,
not just that, of course: we probably need a hefty dose of other frameworks
([Nx](https://nx.dev/) maybe?) on top, for greater simplicity; then some bespoke
abstractions to avoid everybody having to learn the underlying tools.

None of the parties responsible for the decisions have both a serious,
foundational understanding of building the Web in the first place, as well as
significant experience maintaining a corporate-scale application to boot, yet
they still managed to land on the one panacea that contemporarily solves all
problems: obviously, it is that simple; we're off to the races.

<!-- [foundational understanding of building the Web](@/ramblings/youre-no-web-developer.md) in the first place, as well as TODO: LINKME-->

We create tools to run the tools to operate the transpilers, bundlers,
minifiers, linters, formatters (_et caetera_); we create tools to facilitate the
usage of the tools to version-control our code.  Name your micro-task, we are
building some specialised (read: contrived) mean to do it some sort of way.

Soon enough, everything is ready, **90% of the job is done** and
all that remains is to migrate/adapt/rewrite everybody to [El
Dorado](https://en.wikipedia.org/wiki/El_Dorado).

</div>

Now, **onto the remaining 90% of the job** (ha!): integrating the solution.

Every now and again we advocate for the new platform, but each team is
responsible for bringing their piece of the puzzle up to date, on their own
time: the feature requests for the established solution are still pouring in.
Yet the curators of its modernised counterpart aren't left idle, there is much
thumb-twiddling in the works:

We establish [`ADR`s](https://adr.github.io/), we keep expanding
the procedures and making things yet simpler by identifying
patterns and systematically preventing anybody from having to
endure how the sausage is made: do **not** repeat yourself—or
anybody else, [consistency is the opiate of the sophisticated
mind](https://en.wikipedia.org/wiki/Wikipedia:Emerson_and_Wilde_on_consistency),
this project [is so `DRY`](@/ramblings/the-dry-hoax.md) it could pass for [a
British comedy](https://en.wikipedia.org/wiki/The_Office_(British_TV_series)).

We struggle to bring the two worlds to parity.  In fact, we're nowhere near: we
have to start actually using it in its current state.  We can offer customers
(maybe the new ones?) to use that version while ensuring that the [Old
Faithful](https://en.wikipedia.org/wiki/Old_Faithful) still avails itself our
clientele deserving of the same epithet.

<div class="hi">

To help promote the new platform, we started building (on rare occasions, of
course) some features only there.  We figure that the most adequate way to
forcefully dedicate all our resources to the migration effort is indeed to
corner ourselves in a situation where there is strong, business-driven demand
for it.

Some teams decide to opt for the [Strangler Fig
Pattern](https://en.wikipedia.org/wiki/Strangler_fig_pattern),
some attempt to [Branch by
Abstraction](https://martinfowler.com/bliki/BranchByAbstraction.html), some
plan to [just do it](https://www.youtube.com/watch?v=ZXsQAXx_ao0).  Advancement
is sporadic, as it turns out that quite a few bits and bobs depend on other
odds and sods, and a few whatchamacallits are tangled up with some stray
thingamajigs.

Customers of either solution are overall somewhat satisfied with the experience,
but the whole IT department has somehow ground itself to a halt, for which an
innocuous explanation ends up becoming quite a gloomy revelation: **we do
maintain two separate solutions, after all**.

</div>

In a bitterly ironic twist of fate only [Randall Munroe could have
foreseen](https://www.xkcd.com/927/), we are starting to consider that maybe the
Second System (yes, we actually call it that) isn't the way to go.  It lacks
features, isn't widely adopted, and still demands much upkeep.

Suppose that we had a problem...  Now we have two.
