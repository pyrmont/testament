# Testament API

## testament

[==](#testament)
, [assert-deep-equal](#testamentassert-deep-equal)
, [assert-equal](#testamentassert-equal)
, [assert-equivalent](#testamentassert-equivalent)
, [assert-expr](#testamentassert-expr)
, [assert-thrown](#testamentassert-thrown)
, [assert-thrown-message](#testamentassert-thrown-message)
, [deftest](#testamentdeftest)
, [is](#testamentis)
, [reset-tests!](#testamentreset-tests)
, [run-tests!](#testamentrun-tests)
, [set-on-result-hook](#testamentset-on-result-hook)
, [set-report-printer](#testamentset-report-printer)

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

[1]: src/testament.janet#L57

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

[2]: src/testament.janet#L371

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

[3]: src/testament.janet#L355

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

[4]: src/testament.janet#L387

## assert-expr

**macro**  | [source][5]

```janet
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[5]: src/testament.janet#L342

## assert-thrown

**macro**  | [source][6]

```janet
(assert-thrown expr &opt note)
```

Assert that an expression, `expr`, throws an error (with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression throws an error.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form `thrown? expr` is
used.

[6]: src/testament.janet#L406

## assert-thrown-message

**macro**  | [source][7]

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

[7]: src/testament.janet#L422

## deftest

**macro**  | [source][8]

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

[8]: src/testament.janet#L499

## is

**macro**  | [source][9]

```janet
(is assertion &opt note)
```

Assert that an `assertion` is true (with an optional `note`)

The `is` macro provides a succinct mechanism for creating assertions.
Testament includes support for six types of assertions:

1. a generic assertion that asserts the Boolean truth of an expression;
2. an equality assertion that asserts that an expected result and an actual
   result are equal;
3. a deep equality assertion that asserts that an expected result and an
   actual result are deeply equal;
4. an equivalence assertion that asserts that an expected result and an actual
   result are equivalent;
5. a throwing assertion that asserts an error is thrown; and
6. a throwing assertion that asserts an error with a specific message is
   thrown.

`is` causes the appropriate assertion to be inserted based on the form of the
asserted expression.

An optional `note` can be included that will be used in any failure result to
identify the assertion.

[9]: src/testament.janet#L442

## reset-tests!

**function**  | [source][10]

```janet
(reset-tests!)
```

Reset all reporting variables

[10]: src/testament.janet#L559

## run-tests!

**function**  | [source][11]

```janet
(run-tests! &keys {:exit-on-fail exit? :silent silent?})
```

Run the registered tests

This function will run the tests registered in the test suite via `deftest`.
It accepts two optional arguments:

1. `:silent` whether to omit the printing of reports (default: `false`); and
2. `:exit-on-fail` whether to exit if any of the tests fail (default: `true`).

[11]: src/testament.janet#L537

## set-on-result-hook

**function**  | [source][12]

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
- `:thrown` either `true` or `false`; and
- `:thrown-message` the error specified in the assertion.

[12]: src/testament.janet#L140

## set-report-printer

**function**  | [source][13]

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

[13]: src/testament.janet#L75

