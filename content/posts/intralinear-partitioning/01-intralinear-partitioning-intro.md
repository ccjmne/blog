+++
title = 'Laying text out horizontally'
date = 2025-07-25
description = 'Laying text out horizontally'
taxonomies.tags = ['all']

[[extra.cited_tools]]
   name    = "vim"
   repo    = "https://github.com/vim/vim"
   package = "extra/x86_64/vim"
   manual  = "https://vimhelp.org/"
[[extra.cited_tools]]
   name    = "neovim"
   repo    = "https://github.com/neovim/neovim"
   package = "extra/x86_64/neovim"
   manual  = "https://neovim.io/doc/user/"
[[extra.cited_tools]]
   name    = "uni"
   repo    = "https://github.com/arp242/uni"
   package = "aur/uni"
   manual  = "https://github.com/arp242/uni/#usage"
+++

This 3-part article concerns itself with putting chunks of text side by side.

1. This first, rambly piece addresses the *what* and *why*,
2. [the second](@/posts/intralinear-partitioning-2.md) goes over the practical
   use of some <abbr title="Command Line Interface, where I dwell">`CLI`</abbr>
   tools indispensable to the task, and
3. [the third](@/posts/intralinear-partitioning-3.md) and final chapter will
   share some quite nifty <abbr title="The ubiquitous text editor">`Vim`</abbr>
   tricks to the same end.

## Introduction

   Professionally, I put code together. Intimately, I am compelled to make
it neat: I get closer to that goal by wielding non-printable characters like
monochrome photography uses light, with *purpose*.

   The current status quo regarding whitespace, in my line of work, limits our
stylistic expression:

- vertically to the linefeed[^esoteric-vertical-whitespace] (coalescing into
  blank lines), to pack together logical blocks of data or instructions, and
- horizontally to the beginning of the line (in the form of
  indentation), to delineate the hierarchy of our otherwise strictly
  vertically-topologically-laid-out content.

 But here's the thing: the taxonomy of text shouldn't be limited to paragraphs
and lines.<br>
   Let's go bidimensional!

[^esoteric-vertical-whitespace]: Let's not talk of
the [CR](https://www.compart.com/en/unicode/U+000D),
[VT](https://www.compart.com/en/unicode/U+000B) or
[FF](https://www.compart.com/en/unicode/U+000C) here.

## The few forms of horizontal alignment

   In the wild, I identified four classes of occurrences itching for what I
shall refer to as *intralinear partitioning*.  In this article, I propose to
classify and appreciate them.

### The list in a grid

   Collections of items are quite happily organised in a grid, unless you're a
stock exchange ticker tape designer, of course.  As such, so long as you want to
*present* your data rather than have it seemingly scroll forever, the matrix is
a practical ally, Neo.

   For illustration, here's the output of <abbr title="List directory
contents">`ls`</abbr>, a specimen I'm sure you've come across before:

```sh
ls -F
ls --classify
```
```txt
node_modules/  compose.sh*  eslint.config.mjs  package.json    README.md
src/           Dockerfile   LICENSE            pnpm-lock.yaml  TODO
```
{{ note(msg="I use `--classify` to annotate various file types, like executables and directories") }}

### The tabular data

   This one needs no introduction, yet the only example that came to mind is
that of probing <abbr title="Query the Unicode database">`uni`</abbr> for
whatever fantastical sigil I last came across:

```sh
uni i ÉÉ🧉
uni identify É É 🧉
```
```txt
             Dec    UTF8        HTML       Name
'E'  U+0045  69     45          &#x45;     LATIN CAPITAL LETTER E
'◌́'  U+0301  769    cc 81       &#x301;    COMBINING ACUTE ACCENT
'É'  U+00C9  201    c3 89       &Eacute;   LATIN CAPITAL LETTER E WITH ACUTE
'🧉' U+1F9C9 129481 f0 9f a7 89 &#x1f9c9;  MATE DRINK
```
{{ note(msg="ah, so that's why I appear twice in <abbr title='Summarize &apos;git log&apos; output'>`git shortlog`</abbr>` --summary`...") }}

### The adjoined and annotated fragments

   Serving as our penultimate stop is data that's not quite tabular enough to be
called that; chunks of text laid out next to one another:

```sh
docker compose logs -t
docker compose logs --timestamps
```
```txt
postgres_1   2025-08-09 12:34:56 | LOG:  database system was shut down at 2025-08-09 12:30:00 UTC
postgres_1   2025-08-09 12:34:56 | LOG:  MultiXact member wraparound protections are now enabled
postgres_1   2025-08-09 12:35:01 | LOG:  autovacuum launcher started
postgres_1   2025-08-09 12:35:10 | LOG:  connection received: host=172.18.0.5 port=5432
postgres_1   2025-08-09 12:35:10 | LOG:  connection authorized: user=acme dbname=mydb application_name=psql
webserver_1  2025-08-09 12:35:11 | Starting myapp web server on http://0.0.0.0:8080
webserver_1  2025-08-09 12:35:11 | Listening for connections...
postgres_1   2025-08-09 12:35:12 | ERROR:  relation "employees" does not exist at character 15
postgres_1   2025-08-09 12:35:15 | STATEMENT:  SELECT * FROM employees;
postgres_1   2025-08-09 12:35:20 | LOG:  disconnection: session time: 9s user=acme database=mydb host=172.18.0.5 port=5432
webserver_1  2025-08-09 12:35:05 | GET /api/employees 200 15ms
```
{{ note(msg="here, `docker compose` annotates the concatenated logs with their provenance and timestamps") }}

The juxtaposition of pieces of content also routinely aids in visual comparison:

```sh
diff <(seq 1 5) <(seq 2 6 | sed s/3/-/) -y
diff <(seq 1 5) <(seq 2 6 | sed -e s/3/-/) --side-by-side
```
```txt
1   <
2       2
3   |   -
4       4
5       5
    >   6
```

   These may be rather rarely come across naturally, but quite neat to arrive to
while scripting: this goal will be the culmination of the second article.

### The zealous documents

   Here we are, the apotheosis of intralinear partitioning (I promise, it's
the last time I call it that): organised documents authored with intent and
finesse, text laid out in a semantic structure, meant to be *read* and possibly
maintained for a while.<br>
   In truth, that sounds a lot like what I and my professional peers do, in
composing instructions for machines to follow—"writing code", as we say.

   The horizontal alignment is ubiquitous, it's in every bit of text that's
centred, right-aligned or even justified, any padded value, wrapped sentence,
indented paragraph...  Have a look at the following examples:

```typescript,name=profile.ts
export const education = [{
  degree:    `Engineer's Degree`,
  field:     'Network Security',
  dates:     '2010 – 2013',
  highlight: 'Upskilled in the Java language by [Rémi FORAX](https://github.com/forax), major contributor to its expansion.\nAwarded with the greatest distinction. Graduated top of class.',
}, {
  degree:    'Licentiate Degree',
  field:     'Computer Science',
  dates:     '2008 – 2010',
  highlight: 'Awarded with the greatest dis-tinction. Graduated top of class.',
}, {
  degree:    'Baccalaureate',
  field:     'Applied Physics for Electronics',
  dates:     '2005 – 2008',
  highlight: 'Awarded with the greatest dis-tinction. Graduated top of class; top 0.4% nationwide.',
}]
```
<br>

```java,name=Adyen.java
private static final Map<String, String> PROPS_DEFAULTS = Collections.singletonMap("environment", "test");
private static final String              PROPS_FILE     = "creditcard/adyen-x.properties";
private static final String[]            PROPS_KEYS     =
    { "environment", "expire-after", "api-version", "api-key!", "client-key!", "hmac-key!", "merchant-account!", "theme-id!" };

private static final String  HMAC_ALGORITHM = "HmacSHA256";
private static final Charset CHARSET        = StandardCharsets.UTF_8;

private static final ObjectMapper JSON = new ObjectMapper();
private static final OkHttpClient HTTP = new OkHttpClient();

private final GeographicalArea shop;
private final Props            props;

public Adyen(final GeographicalArea shop) {
    this.shop = shop;
    this.props = Props
        .load(PROPS_KEYS)
        .withDefaults(PROPS_DEFAULTS)
        .withScope(shop.name())
        .from(Props.getFrom(PROPS_FILE));
}
```
{{ note(msg="bonus points for the serendipitously native alignment of the `JSON` and `HTTP` constants declaration") }}

<br>

```sql,name=queries.sql
SELECT CASE airport_code
       WHEN 'CDG' THEN 'Paris'
       WHEN 'ICN' THEN 'Seoul'
       END AS city
  FROM flight_schedules
 WHERE airline = 'Air Global'
   AND departure_hour BETWEEN 18 AND 20
   AND airport_code IN ('CDG', 'ICN', 'NRT', 'DXB');
```
<br>

```txt,name=delta-reports-exchange.txt
Status: DRAFT                DelTA Reports Exchange                 Éric NICOLAS
Revisions: 12                ======================           <ccjmne@gmail.com>
Latest: 2024-02-14
                       Retiring file-based communications
                           for DelTA reports analysis
                               -----------------

    The object of these reports is the discrepancy between expected and actual
delivery times.  DelTA is an acronym for [DEL]ivery [T]ime [A]nalysis, but is
also the Greek letter δ or ∆, often used in calculus for differential values:
How lovely!

                                -- CHANGELOG --

Revision 12 ......................................................... 2024-02-14

    - Address and rectify discrepancy between sections 2.1.1 and 5-C

Revision 11 ......................................................... 2024-02-13

    - Clarify usages of the 'deliverytime' module in section 3
    - Introduce section 5, Accidental Complexity vs Obsolescence

Revision 10 ......................................................... 2024-02-06

    - Explain the "crashing" allusion made in article 2.1.7

Revision 9 .......................................................... 2024-02-05

    - Introduce CHANGELOG
    - Introduce article 2.3.2, on the reduced testability
    - Fix a few typographic errors and blurts here and there

Revisions 1 through 8 ............................ 2024-01-30 through 2024-02-04

    Irrelevant (unpublished) and/or lost to time.
```

## What to do about these

   I suppose this would be the place for the rhetorical question regarding the
virtues of this fastidiousness, but I'll only grace you with the broad strokes
of its answer instead: yes, it is more beautiful, it aids in visual grepping, in
contextual parsing, and it shows that you care.

  However, as the saying goes: "ain't nobody got time for that" is sure to be
the most ready retort to my proposition, together with "the auto-formatter would
thrash it" and "no linting rules would account for that".  I hear you, and
you're indeed making valid arguments... in disfavour of generic auto-formatters
and misguided stylistic linting tools!

Here's the whole truth:

### You have time for this

   If you're making adept, skilful contributions to meaningful software, you're
meant to be spending your time investigating and exploring.  Jotting down
legible documents that procure workable instructions to the machine, any fool
can do: every fool does.  If you're tasked with authoring code, you're assumed
to have mastered the putting-text-together aspect of it already: [we are typists
first](https://blog.codinghorror.com/we-are-typists-first-programmers-second/).

### Use tools that help

   If your tools are either not assisting or outright hindering you in some
aspects of your goals, *do not blame or forsake the goal*.  You may simply
need—or get!—to use them differently.

   If you find neat documents desirable but the baseline auto-formatter will
squash your style, it may be time to ask yourself whether you and your team are
such purposeful pigs that a generic, one-size-fits-all crutch is the preferred
cure-all elixir to your systematic, inescapable blurts.

   The formatter and linter help, but in no way should dictate prescriptive
style over the learned tastes of your experienced discernment: do review code.

### You have the go-ahead

   You do not have to make your code look pretty beyond mere logical
structure, but you *do have to* read it, every now and again.  This is just
an encouragement, a call for you to assume your style and not shy away from
crafting text with as much care as you wish.

## Next

   Find out how simple tools can help you lay out text with polish
in parts 2 and 3 of this article series, pertaining to [horizontal
alignment on the CLI](@/posts/intralinear-partitioning-2.md) and [inside
Vim](@/posts/intralinear-partitioning-3.md), respectively.

talk about moreutil/ln, moreutil/ts

IN PART 3, TALK ABOUT VIRTUALEDIT!!!!!!!!!!!!!!!!!!!!!!!!! :help 'virtualedit'
set ve=all cuc cc=80
set ve& cuc& cc&
