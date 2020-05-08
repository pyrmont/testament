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

Testament can be used like this::


```clojure
(import testament :prefix "" :exit true)

(deftest one-plus-one
  (is (= 2 (+ 1 1)) "1 + 1 = 2"))

(run-tests!)
```

Put your tests in the `test/` directory within your project and then run:

```console
$ jpm test
```

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/testament/issues

## Licence

Testament is licensed under the MIT Licence. See [LICENSE][] for more details.
details.

[LICENSE]: https://github.com/pyrmont/testament/blob/master/LICENSE
