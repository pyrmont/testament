# Testament

[![Test Status][icon]][status]

[icon]: https://github.com/pyrmont/testament/workflows/test/badge.svg
[status]: https://github.com/pyrmont/testament/actions?query=workflow%3Atest

Testament is a testing library for Janet. It takes inspiration Clojure's [clojure.test][] library.

[clojure.test]: https://clojure.github.io/clojure/clojure.test-api.html

## Installation

Add the dependency to your `info.jdn` file:

```janet
  :dependencies ["https://github.com/pyrmont/testament"]
```

## Usage

Testament can be used like this:


```janet
(use testament)

(deftest one-plus-one
  (is (= 2 (+ 1 1)) "1 + 1 = 2"))

(deftest two-plus-two
  (is (= 5 (+ 2 2)) "2 + 2 = 5"))

(run-tests!)
```

Put your tests in the `test/` directory within your project and then use a
bundle manager like [Jeep][]:

```console
$ jeep test -R
```

[Jeep]: https://github.com/pyrmont/jeep "Visit the Jeep repository on GitHub"

Or if you walk to school through the snow uphill both ways:

```console
$ for f in test/*.janet; do janet "$f" || { rc=$?; break; }; done; (exit ${rc:-0})
```

If you use Jeep, with a file saved to `test/example.janet`, you should see:

```text
running ./test/example.janet...
-----------------------------------
> Failed: two-plus-two
Assertion: 2 + 2 = 5
Expect (L): 5
Actual (R): 4
===================================
2 tests run containing 2 assertions
1 tests passed, 1 tests failed
===================================
1 of 1 scripts failed:
  ./test/example.janet
```

### In REPLs

To use Testament in a REPL, set the dynamic variable `:testament/repl?` to
`true`:

```janet
(setdyn :testament/repl? true)
```

This will (a) stop Testament from exiting your REPL if a test fails, (b) reset
the reports between runs and (c) empty the `module/cache` to prevent old code
from running.


## API

Documentation for Testament's API is in [api.md][api].

[api]: https://github.com/pyrmont/testament/blob/master/api.md

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/testament/issues

## Licence

Testament is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/testament/blob/master/LICENSE
