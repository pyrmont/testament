# Testament

[![Build Status](https://github.com/pyrmont/testament/workflows/build/badge.svg)](https://github.com/pyrmont/testament/actions?query=workflow%3Abuild)

Testament is a testing library for Janet. It takes inspiration from Joy's
[Tester][] library and Clojure's [clojure.test][] library.

[Tester]: https://github.com/joy-framework/tester
[clojure.test]: https://clojure.github.io/clojure/clojure.test-api.html

## Installation

Add the dependency to your `project.janet` file:

```clojure
(declare-project
  :dependencies ["https://github.com/pyrmont/testament"])
```

## Usage

Testament can be used like this:


```clojure
(import testament :prefix "" :exit true)

(deftest one-plus-one
  (is (= 2 (+ 1 1)) "1 + 1 = 2"))

(deftest two-plus-two
  (is (= 5 (+ 2 2)) "2 + 2 = 5"))

(run-tests!)
```

Put your tests in the `test/` directory within your project and then run:

```console
$ jpm test
```

If you do the above with a file saved to `test/example.janet`, you should see:

```text
running test/example.janet ...

> Failed: two-plus-two
Assertion: 2 + 2 = 5
Expect: 5
Actual: 4

-----------------------------------
2 tests run containing 2 assertions
1 tests passed, 1 tests failed
-----------------------------------
```

### Note for REPL users

By default, Testament prevents defining two tests with the same name. If you're repeatedly evaluating a test file in REPL, this will cause your re-evaluated `deftest` to fail.

Set the dynamic variable `*testament-repl-mode*` to `true` to disable this check, e.g. with:
```
(setdyn *testament-repl-mode* true)
```

This will also stop Testament from exiting your REPL if a test fails.


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
