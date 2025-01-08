# Testament API


[==](#), [assert-deep-equal](#assert-deep-equal), [assert-equal](#assert-equal), [assert-equivalent](#assert-equivalent), [assert-expr](#assert-expr), [assert-matches](#assert-matches), [assert-thrown](#assert-thrown), [assert-thrown-message](#assert-thrown-message), [deftest](#deftest), [exercise!](#exercise), [is](#is), [reset-tests!](#reset-tests), [review](#review), [run-tests!](#run-tests), [set-on-result-hook](#set-on-result-hook), [set-report-printer](#set-report-printer)

## ==

**function**  | [source][1]

```janet
(== x y)
```

Return true if the arguments are equivalent

The arguments are considered equivalent for the purposes of this function if
they are of equivalent types and have the same structure. Types are equivalent
if they are the same or differ only in terms of mutability (e.g. arrays and
tuples).

Instances of `math/nan` are considered equivalent for the purposes of this
function.

[1]: lib/testament.janet#L57

## assert-deep-equal

**macro**  | [source][2]

```janet
(assert-deep-equal expect actual &opt note)
```

Assert that `expect` is deeply equal to `actual` (with an optional `note`)

The `assert-deep-equal` macro provides a mechanism for creating an assertion
that an expected result is deeply equal to the actual result. The forms of
`expect` and `actual` will be used in the output of any failure report.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form
`(deep= expect actual)` is used.

[2]: lib/testament.janet#L393

## assert-equal

**macro**  | [source][3]

```janet
(assert-equal expect actual &opt note)
```

Assert that `expect` is equal to `actual` (with an optional `note`)

The `assert-equal` macro provides a mechanism for creating an assertion that
an expected result is equal to the actual result. The forms of `expect` and
`actual` will be used in the output of any failure report.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form `(= expect actual)`
is used.

[3]: lib/testament.janet#L377

## assert-equivalent

**macro**  | [source][4]

```janet
(assert-equivalent expect actual &opt note)
```

Assert that `expect` is equivalent to `actual` (with an optional `note`)

The `assert-equivalent` macro provides a mechanism for creating an assertion
that an expected result is equivalent to the actual result. Testament
considers forms to be equivalent if the types are 'equivalent' (that is, they
are the same or differ only in terms of mutability) and the structure is
equivalent.  The forms of `expect` and `actual` will be used in the output of
any failure report.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form `(== expect actual)`
is used.

[4]: lib/testament.janet#L409

## assert-expr

**macro**  | [source][5]

```janet
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[5]: lib/testament.janet#L364

## assert-matches

**macro**  | [source][6]

```janet
(assert-matches structure actual &opt note)
```

Assert that `structure` matches `actual` (with an optional `note`)

The `assert-matches` macro provides a mechanism for creating an assertion that
an expression matches a particular structure (at least in part).

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form
`(matches structure actual)` is used.

[6]: lib/testament.janet#L428

## assert-thrown

**macro**  | [source][7]

```janet
(assert-thrown expr &opt note)
```

Assert that an expression, `expr`, throws an error (with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression throws an error.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form `thrown? expr` is
used.

[7]: lib/testament.janet#L443

## assert-thrown-message

**macro**  | [source][8]

```janet
(assert-thrown-message expect expr &opt note)
```

Assert that the expression, `expr`, throws an error with the message `expect`
(with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression throws an error with the specified message.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form
`thrown? expect expr` is used.

[8]: lib/testament.janet#L459

## deftest

**macro**  | [source][9]

```janet
(deftest & args)
```

Define a test and register it in the test suite

The `deftest` macro can be used to create named tests and anonymous tests. If
the first argument is a symbol, that argument is treated as the name of the
test. Otherwise, Testament uses `gensym` to generate a unique symbol to name
the test. If a test with the same name has already been defined, `deftest`
will raise an error.

A test is just a function. `args` (excluding the first argument if that
argument is a symbol) is used as the body of the function. Testament adds
respective calls to a setup function and a teardown function before and after
the forms in the body.

In addition to creating a function, `deftest` registers the test in the 'test
suite'. Testament's test suite is a global table of tests that have been
registered by `deftest`. When a user calls `run-tests!`, each test in the
test suite is called. The order in which each test is called is not
guaranteed.

If `deftest` is called with no arguments or if the only argument is a symbol,
an arity error is raised.

[9]: lib/testament.janet#L542

## exercise!

**macro**  | [source][10]

```janet
(exercise! args & body)
```

Define, run and reset the tests provided in the macro body

This macro will run the forms in `body`, call `run-test!`, call `reset-tests!`
and then return the value of `run-tests!`.

The user can specify the arguments to be passed to `run-tests!` by providing a
tuple as `args`. If no arguments are necessary, `args` should be an empty
tuple.

Please note that, like `run-tests!`, `exercise!` calls `os/exit` when there
are failing tests unless the argument `:exit-on-fail` is set to `false`.

[10]: lib/testament.janet#L649

## is

**macro**  | [source][11]

```janet
(is assertion &opt note)
```

Assert that an `assertion` is true (with an optional `note`)

The `is` macro provides a succinct mechanism for creating assertions.
Testament includes support for seven types of assertions:

1. a generic assertion that asserts the Boolean truth of an expression;
2. an equality assertion that asserts that an expected result and an actual
   result are equal;
3. a deep equality assertion that asserts that an expected result and an
   actual result are deeply equal;
4. an equivalence assertion that asserts that an expected result and an actual
   result are equivalent;
5. a matches assertion that asserts that an expected result matches a
   particular structure (at least in part);
6. a throwing assertion that asserts an error is thrown; and
7. a throwing assertion that asserts an error with a specific message is
   thrown.

`is` causes the appropriate assertion to be inserted based on the form of the
asserted expression.

An optional `note` can be included that will be used in any failure result to
identify the assertion.

[11]: lib/testament.janet#L479

## reset-tests!

**function**  | [source][12]

```janet
(reset-tests!)
```

Reset all reporting variables

[12]: lib/testament.janet#L588

## review

**macro**  | [source][13]

```janet
(review path & args)
```

Import all bindings as public in the specified module

This macro performs similarly to `import`. The difference is that it sets all
the bindings as public. This is intended for situations where it is not
desirable to make bindings public but the user would still like to be able to
subject the bindings to testing.

[13]: lib/testament.janet#L695

## run-tests!

**function**  | [source][14]

```janet
(run-tests! &keys {:silent silent? :exit-on-fail exit?})
```

Run the registered tests

This function will run the tests registered in the test suite via `deftest`.
It accepts two optional arguments:

1. `:silent` whether to omit the printing of reports (default: `false`); and
2. `:exit-on-fail` whether to exit if any of the tests fail (default: `true`).

Please note that `run-tests!` calls `os/exit` when there are failing tests
unless the argument `:exit-on-fail` is set to `false` or the
`:testament-repl?` dynamic variable is set to `true`.

In all other cases, the function returns an indexed collection of test
reports. Each report in the collection is a dictionary collection containing
three keys: `:test`, `:passes` and `:failures`. `:test` is the name of the
test while `:passes` and `:failures` contain the results of each respective
passed and failed assertion. Each result is a data structure of the kind
described in the docstring for `set-on-result-hook`.

When the dynamic variable `:testament-repl?` is set to `true`, this will
also reset the test reports and empty the module/cache to provide a fresh run
with the most up-to-date code.

[14]: lib/testament.janet#L603

## set-on-result-hook

**function**  | [source][15]

```janet
(set-on-result-hook f)
```

Set the `on-result-hook`

The function `f` will be invoked when a result becomes available. The
function is called with a single argument, the `result`. The `result` is a
struct with the following keys:

- `:test` the name of the test to which the assertion belongs (as `nil` or
  symbol);
- `:kind` the kind of assertion (as keyword);
- `:passed?` whether an assertion succeeded (as boolean);
- `:expect` the expected value of the assertion;
- `:actual` the actual value of the assertion; and
- `:note` a description of the assertion (as string).

The 'value' of the assertion depends on the kind of assertion:

- `:expr` either `true` or `false`;
- `:equal` the value specified in the assertion;
- `:matches` the structure of the value in the assertion;
- `:thrown` either `true` or `false`; and
- `:thrown-message` the error specified in the assertion.

[15]: lib/testament.janet#L144

## set-report-printer

**function**  | [source][16]

```janet
(set-report-printer f)
```

Set the `print-reports` function

The function `f` will be applied with the following three arguments:

1. the number of tests run (as integer);
2. number of assertions (as integer); and
3. number of tests passed (as integer).

The function will not be called if `run-tests!` is called with `:silent` set
to `true`.

[16]: lib/testament.janet#L75

