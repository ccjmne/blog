+++
title = 'The `DRY` hoax'
date = 2025-11-11
description = 'Prefer duplication over the wrong abstraction'
taxonomies.section = ['ramblings']
taxonomies.tags = ['all']
+++

Ah, here we are.  The opiate of the eager neophyte, which, like all things, is
better consumed with moderation.

Indeed, <abbr title="DRY" font="mono">**Don't Repeat Yourself**</abbr>—when
providing instructions to the machine, that is.  I quite like refactoring
code, and very much understand that this word originates from the world of
mathematics, where we can simplify equations by combining **factors**.

I stand behind the process, the whole ideal in principle: yes, a thousand times
yes, strive to identify units of work that are one and the same **logically**,
and make them effectively, **technically** one and the same as well.

<div class="hi">

The debilitating disfigurement of an otherwise sound principle starts to show
as soon as the healthy habit [moults](https://en.wikipedia.org/wiki/Moulting)
and sheds its reasoned skin, to change—as sadly quite a few
do—into a helpless automatism, and further as it insidiously
transmutes into a **tenet of your newly, tacitly established [cargo
cult](https://en.wikipedia.org/wiki/Cargo_cult)**.

Not everything, everybody, every time, everywhere, demands the conception and
curation of a uniform abstraction.

Having a few of your purportedly autonomous, vaguely[^manifesto-agile]
["Agile"](https://en.wikipedia.org/wiki/Agile_software_development) teams
using containerised services in a similar way, doesn't necessarily call for
the creation of an internal, bastardised library, framework, infrastructure,
platform, or whatever else sounds legitimate enough to tout **your proposed
oblivious commitment to maintaining**, in perpetuity, yet another abstraction
**in the way of using the tool you need**, as if it were an achievement.

[^manifesto-agile]: I say "vaguely Agile", because, as [Ron
Jeffries](https://en.wikipedia.org/wiki/Ron_Jeffries), a vocal **original
author of [the one Agile Manifesto](https://agilemanifesto.org/)** explains
[in his rant](https://ronjeffries.com/articles/018-01ff/abandon-1/), the
collection of principles that should be conductive to nimble, accurate,
iterative software development has seen its name hijacked and repurposed
into a corporate buzzword to support instead the **institutionalisation
of a process-heavy framework** primarily shaped by the [_Scrum
Alliance_'s thriving business in providing _"Certified ScrumMaster"_
trainings](https://www.scrumalliance.org/get-certified/scrum-master-track/) and
certifications.

</div>

Not even at a smaller scale does every piece of code need have no sibling, twin
or cousin.

I won't draw the analogy to the fate of [Meursault in Camus'
_L'Étranger_](https://en.wikipedia.org/wiki/The_Stranger_(Camus_novel)) here,
for **competent software is frugal and cut-throat**, and attachment to fragments
of code is largely detrimental to moulding it into a sharp, lean performer.
I'll have you instead consider the real-life example of some well-meaning _"Web
developer's"_[^are-you-a-web-developer] stunning implementation of the familiar
sign-in and sign-up forms:

You see, in terms of business logic, both forms encapsulate vastly
different functions.  But in their infinite wisdom, the `DRY` priest
(drinking neither wine nor water?) would soon recognise that amidst
the differences, two input fields (`email` and `password`) are notably
[double-dipping](https://www.merriam-webster.com/dictionary/double-dip) in the
blessed halo that is **the sanctimonious, exclusive one-million-lines-of-code
repository**.  Hell, squint a little, and even the `submit` button appears to
bask in undue warmth.

Duplication!  Duplicitous duplication!  Quick, there's a pagan civilisation in
need of divine enlightenment and no time to explain (or reason); erect the holy
temples and subsume their society under ours; the scripture calls for lines of
code to be universally unique, and:

> All problems in computer science can be solved by another level of indirection
> [...]

<div class="hi">

Here, extract the two `<input>` in their own template.  There, muster a model
and its controller, complete with two-way bindings.  Ah, but the password entry
validation logic must be provided by the consumer component: in one case, it
must contort to fit to **whatever comprises an acceptable password—I'm sure
whitespaces will be rejected**, and in the other, it must dynamically correspond
to the value of a identical "confirmation" twin separated at birth.

Fret not, for the `DRY` apostle's propensity for <abbr title='"extreme
dryness"'>dessication</abbr> comes second only to [Moses parting the Red
Sea](https://en.wikipedia.org/wiki/Parting_of_the_Red_Sea): they are
well-acquainted to all [`SOLID`](https://en.wikipedia.org/wiki/SOLID) matters as
well.  Here the _Single Responsibility_, there the _Dependency Inversion_.

This isn't _work_ any longer.  Provided it still belongs to the realm of the
mortals, this is _art_.  In fact, **the application doesn't need to work, it
needs _to scale_—to the heavens!**  We have grand plans, and the vertiginous
heights from which we look down on the naive implementation is reflected in the
staggering depth of our directory structure.  **Mission justly re-appropriated
and accomplished.**

But here's my truth: our new sprawling collection of interdependent
components used to consist of **two lines**, albeit in two places.
The grand plans I was alluding to?  Grand delusions.  All we've
accomplished is to make the codebase impenetrable; its only
**indisputably divine quality is to [move in just as mysterious a
way](https://en.wikipedia.org/wiki/God_Moves_in_a_Mysterious_Way)**.

</div>

I'd be remiss if I failed to end on the corollary continuation to my earlier
citing of the [fundamental theorem of software
engineering](https://en.wikipedia.org/wiki/Fundamental_theorem_of_software_engineering):

> [...] except for the problem of too many layers of indirection.

{% attribution() %} — David Wheeler's [aphorism on indirection](https://en.wikipedia.org/wiki/Indirection) {% end %}

<!-- (@/ramblings/youre-no-web-developer). TODO: LINKME -->

[^are-you-a-web-developer]: You're not a _Web developer_ just because you
cobbled together some barely idiomatic [React](https://react.dev/) garbage,
without having familiarised yourself with _any_ the internal workings of
[Custom Elements](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements),
[the `DOM`](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model),
[the Shadow `DOM`](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_shadow_DOM),
[JavaScript's Event Loop](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Execution_model),
[the browser's rendering pipeline](https://developer.mozilla.org/en-US/docs/Web/Performance/Guides/Critical_rendering_path),
[accessibility `API`s and practices](https://www.w3.org/WAI/standards-guidelines/wcag/),
[internationalisation `API`s and practices](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl) ([`LTR`, anybody?](https://developer.mozilla.org/en-US/docs/Glossary/LTR)),
[security considerations](https://owasp.org/www-project-top-ten/),
[data governance](https://en.wikipedia.org/wiki/Data_governance),
[network protocols](https://en.wikipedia.org/wiki/Internet_protocol_suite),
[streaming (not only for media!)](https://en.wikipedia.org/wiki/Streaming_data),
[_WebSockets_](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API),
[_WebAssembly_](https://developer.mozilla.org/en-US/docs/WebAssembly)...

    If you couldn't begin to contemplate how to implement the mechanics of
    an <abbr title="Single Page Application">`SPA`</abbr> yourself, with
    nothing but your hand-rolled **~25 lines of JavaScript** (seriously),
    then **you aren't all that much ahead of the litany of React-kiddies**
    wondering how to [_"make an `HTTP` query with my front-end framework of
    choice"_](https://stackoverflow.com/q/38510640/2427596).

    If you conflate `REST` with `HTTP` and cannot describe in what way `AJAX`
    relates to either and both, **you're not a Web developer**.
