+++
title = "JavaScript's generator `function*`"
date = 2025-09-02
description = 'Returning *multiple times* from a single `function` in ECMAScript'
taxonomies.tags = ['all', 'javascript', 'es6']
+++

[ECMAScript](https://tc39.es/ecma262/) ("JavaScript" for the
uninitiated)[^ecmascript] catches quite a bit of flak for
numerous reasons online, but it can boast some truly spectacular
expressiveness, possibly somewhat unmatched when paired with savvy
[TypeScript](https://www.typescriptlang.org/) sauce that would make a <abbr
title="the Rust connoisseurs">Rustacean</abbr> blush.

[^ecmascript]: [ECMAScript](https://en.wikipedia.org/wiki/ECMAScript) is the
standard, the specification; JavaScript is the language built on that standard,
plus some extra features (such as Web `API`s, like the <abbr title="Document
Object Model">`DOM`</abbr>), for browsers.

You've no doubt come across the destructuring syntax to *effectively return
multiple values* from a single function, but we can do even better: we can
**return multiple times** from the same invocation.

Possibly mad yet patently beautiful, let's explore the **generator**.

<!--more-->

## Not just multiple values

Introduced in [ECMAScript 2015
(`ES6`)](https://262.ecma-international.org/6.0/), the generator `function*`
lets you yield values *on demand*, rather than computing them all at once.
It works with the introduction of a new keyword, `yield`, which **pauses and
resumes the function execution**.  The one practical difference between an
[`iterator` (what the generator constructs)](#under-the-hood) and a regular
collection (like an `Array`) is that values are only computed when they're
requested: you may generate an infinite sequence of values, for instance.

### Defining a generator

A generator function is declared using the `function*` syntax. Inside, the
`yield` keyword is used to emit values one at a time:

```javascript
function* countToThree() {
  yield 1
  yield 2
  yield 3
}
```

You may also use the `function*` expression:
```javascript
const countToThree = function* () {
  yield 1
  yield 2
  yield 3
}
```
Or even extract its constructor to create such functions dynamically:
```javascript
const GeneratorFunction = function* () {}.constructor;
const countToThree = new GeneratorFunction(`
  yield 1
  yield 2
  yield 3
`)
```
{{ note(msg="oh yeah, JavaScript has no problem (de)serialising *code* on the fly: [quine](https://en.wikipedia.org/wiki/Quine_(computing)) enthusiasts, take note!") }}

There is however **no equivalent arrow function syntax** for generators.

## Under the hood: an `iterable iterator` {#under-the-hood}

Calling a generator function returns an
[`iterator`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols)
object.  Well, it even is an *`iterable`*` iterator`, like most will be.

### The `iterator` protocol

An `iterator` is an instance providing a `next()` method that returns an object
with two properties:

- `value`, the yielded value, and
- `done`, a boolean indicating whether the generator has completed.

Technically, both properties are optional: you may very well yield `undefined`
at any time, and the omission of `done` is equivalent to having it be `false`.

An `iterator` is fairly simple to use: call its `next()` method to get the
subsequent value; when `done` is `true`, the `iterator` is exhausted.

In the case of a generator `function*`, the first call to `next()` executes the
function until the first `yield`.  Subsequent calls to `next()` will resume
execution until the next `yield` instruction, or until the function returns (or
finishes), at which point it'll systematically reply with `done` and no further
values are produced.


```javascript
const counter = countToThree()
console.log(counter.next()) // { value: 1,         done: false }
console.log(counter.next()) // { value: 2,         done: false }
console.log(counter.next()) // { value: 3,         done: false }
console.log(counter.next()) // { value: undefined, done: true }
// You may keep calling next() after completion:
console.log(counter.next()) // { value: undefined, done: true }
```

Note that the `value` after exhaustion is typically `undefined`, unless you
explicitly `return` a value from the generator; however, know that **this final
value is disregarded entirely by standard API constructs such as `for..of` loops
and the spread operator**:

```javascript
function* countToThreeAndReturn() {
  yield 1
  yield 2
  yield 3
  return 'tada'
}

const counter = countToThreeAndReturn()
console.log(counter.next()) // { value: 1,      done: false }
console.log(counter.next()) // { value: 2,      done: false }
console.log(counter.next()) // { value: 3,      done: false }
// Here, the final 'tada' is provided the first time *done* is true:
console.log(counter.next()) // { value: 'tada', done: true }
// Subsequent calls yield *undefined*:
console.log(counter.next()) // { value: undefined, done: true }

// The final 'tada' is *ignored*:
console.log(...countToThreeAndReturn()) // 1 2 3
```
{{ note(msg="the (oft left undefined) final `return` value is **ignored** by consumers of `iterable` ") }}

... Which makes for a neat segue into the next section.

### The `iterable` interface

An `iterable` is an instance providing a `[Symbol.iterator]()`[^symbols]
method that returns an `iterator`.  This is essentially JavaScript's take on
composition, a superior alternative to inheritance.

[^symbols]: `Symbol`s are special, unique identifiers in JavaScript, also
introduced in `ES6`: maybe they deserve an entry of their own sometime.

In practice, the `iterator` protocol is virtually never implemented without also
providing an `iterable` interface, as most (all?) standard syntaxes and `API`s
are designed to work with `iterable`s rather than raw `iterator`s.

Generator `function*`s return values that are `iterable`.  As such, you can (for
example) use them in `for..of` loops:

```javascript
for (const num of countToThree()) {
  console.log(num) // 1, then 2, then 3
}
```

Note that `Array`s, `String`s, `Map`s, `Set`s, and possibly other built-in
types also implement the `iterable` interface[^object-not-iterable].

[^object-not-iterable]: Note that plain `Object`s do **not** implement
the `iterable` interface, and are broken down with `Object.entries()`,
`Object.keys()`, or `Object.values()` instead.

```javascript
for (const num of [1, 2, 3]) {
  console.log(num) // 1, then 2, then 3
}

for (const char of 'abc') {
  console.log(char) // 'a', then 'b', then 'c'
}

for (const value of new Set([1, 2, 3])) {
  console.log(value) // 1, then 2, then 3
}

for (const [key, value] of new Map([['a', 1], ['b', 2], ['c', 3]])) {
  console.log(key, value) // 'a' 1, then 'b' 2, then 'c' 3
}
```
{{ note(msg="the last one also employs **array destructuring**, a fan-favourite from `ES6`") }}

## Not just `for..of`

With `ES6` also came a slew of new syntaxes and `API`s designed to work with
`iterable`s, including but not limited to:

- The *spread operator* (`...`), which expands an `iterable` into individual
elements.  You can use it to pass values as separate arguments to a `function`
or to create an `array literal` with it:

  ```javascript
  const numbers = [...countToThree()] // [1, 2, 3]

  (function sum(x, y, z) {
    return x + y + z
  })(...countToThree()) // 6
  ```

- The *assignment destructuring*, which also may work over `iterables` to
declare and initialise multiple values at once:

  ```javascript
  // a = 1, b = 2, c = 3
  const [a, b, c] = countToThree()
  ```

- The *rest parameter* syntax, which collects multiple values into an array:

  ```javascript
  function print(...args) {
    console.log(args)
  }

  print(1, 2) // [1, 2]
  print(...countToThree()) // [1, 2, 3]
  ```

There is still some more brought by `ES6` with regards to integration with
`iterable`s, as well as a *lot* more general, unrelated goodness that came with
it, but I should bring this article back on topic and to an end: how about the
practical use of generator functions in the wild?

## A practical example

Because their values are, as their name would heavily suggest, *generated* on
demand, you can use generators to create, for instance, infinite `iterator`s:

```javascript
function* infiniteCounter() {
  let i = 0
  while (true) {
    yield i++
  }
}
```

Alright, it's good to know, but I was only messing with you: I'm yet to develop
the need for an infinite sequence that isn't served just as well by a simple
mutable `number` counter or some other mechanism entirely.

There was however still [one
time](https://github.com/vJechsmayr/JavaScriptAlgorithms/pull/142) that I
figured would call for a generator `function*`.  It wasn't the code that ran the
fastest, but the most elegant[^elegant] one—though I welcome challenges to that
claim.

[^elegant]: Elegance is subjective, but 3 measly statements with no mutable
variables has got to beat alternatives!  In reality, these acrobatics could
otherwise be replaced by `Array#flat`, though that one only arrived with `ES10`.

It was implementing a solution to [Reshape the
Matrix](https://leetcode.com/problems/reshape-the-matrix), <abbr title="Online
coding challenges platform">LeetCode</abbr>'s challenge `#566`, despite the typo
in my PR referring to `#556`, which reads:

> In MATLAB, there is a handy function called `reshape` which can reshape an `m
> x n` matrix into a new one with a different size `r x c` keeping its original
> data.
>
> You are given an `m x n` matrix mat and two integers `r` and `c` representing
> the number of rows and the number of columns of the wanted reshaped matrix.
>
> The reshaped matrix should be filled with all the elements of the original
> matrix in the same row-traversing order as they were.
>
> If the `reshape` operation with given parameters is possible and legal, output
> the new reshaped matrix; Otherwise, output the original matrix.

Here's my generator-based solution (revisited for brevity and clarity):

```typescript
function reshape(matrix, r, c) {
  // bail out of illegal invocations
  if (matrix.length * matrix[0].length !== r * c) return matrix

  // yield cells in row-major order
  const traversal = (function*() {
    for (const row of matrix)
      for (const cell of row)
        yield cell;
  })()

  // build new matrix with the requested shape
  return [...Array(r)].map(() => [...Array(c)].map(() => traversal.next().value))
}
```

   Don't take my word for it: try for yourself to implement this solution;
chances are it's only then that you'll best appreciate the generator
`function*`.<br>
   Though nowadays, for this specific example, I might rather reach for
`Array#flat` instead which, contrary to a naive belief, actually performs
*better*.

And don't hesitate to share with me if you ever come across a legitimate use for
JavaScript's generators: I would love to know what you're tinkering with.
