# Testament API

[testament/==](#testament==)
, [testament/assert-equal](#testamentassert-equal)
, [testament/assert-equivalent](#testamentassert-equivalent)
, [testament/assert-expr](#testamentassert-expr)
, [testament/assert-thrown](#testamentassert-thrown)
, [testament/assert-thrown-message](#testamentassert-thrown-message)
, [testament/deftest](#testamentdeftest)
, [testament/is](#testamentis)
, [testament/reset-tests!](#testamentreset-tests)
, [testament/run-tests!](#testamentrun-tests)
, [testament/set-on-result-hook](#testamentset-on-result-hook)
, [testament/set-report-printer](#testamentset-report-printer)

## testament/==

**function**  | [source][1]

```janet
(== x y)
```

Return true if the arguments are equivalent

The arguments are considered equivalent for the purposes of this function if
they are of equivalent types and have the same structure. Types are equivalent
if they are the same or differ only in terms of mutability (e.g. arrays and
tuples).

[1]: src/testament.janet#L50

## testament/assert-equal

**macro**  | [source][2]

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

[2]: src/testament.janet#L328

## testament/assert-equivalent

**macro**  | [source][3]

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

[3]: src/testament.janet#L344

## testament/assert-expr

**macro**  | [source][4]

```janet
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[4]: src/testament.janet#L315

## testament/assert-thrown

**macro**  | [source][5]

```janet
(assert-thrown expr &opt note)
```

Assert that an expression, `expr`, throws an error (with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression throws an error.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form `thrown? expr` is
used.

[5]: src/testament.janet#L363

## testament/assert-thrown-message

**macro**  | [source][6]

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

[6]: src/testament.janet#L379

## testament/deftest

**macro**  | [source][7]

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

[7]: src/testament.janet#L450

## testament/is

**macro**  | [source][8]

```janet
(is assertion &opt note)
```

Assert that an `assertion` is true (with an optional `note`)

The `is` macro provides a succinct mechanism for creating assertions.
Testament includes support for five types of assertions:

1. a generic assertion that asserts the Boolean truth of an expression;
2. an equality assertion that asserts that an expected result and an actual
   result are equal;
3. an equivalence assertion that asserts that an expected result and an actual
   result are equivalent;
4. a throwing assertion that asserts an error is thrown; and
5. a throwing assertion that asserts an error with a specific message is
   thrown.

`is` causes the appropriate assertion to be inserted based on the form of the
asserted expression.

An optional `note` can be included that will be used in any failure result to
identify the assertion.

[8]: src/testament.janet#L399

## testament/reset-tests!

**function**  | [source][9]

```janet
(reset-tests!)
```

Reset all reporting variables

[9]: src/testament.janet#L510

## testament/run-tests!

**function**  | [source][10]

```janet
(run-tests! &keys {:exit-on-fail exit? :silent silent?})
```

Run the registered tests

This function will run the tests registered in the test suite via `deftest`.
It accepts two optional arguments:

1. `:silent` whether to omit the printing of reports (default: `false`); and
2. `:exit-on-fail` whether to exit if any of the tests fail (default: `true`).

[10]: src/testament.janet#L488

## testament/set-on-result-hook

**function**  | [source][11]

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

[11]: src/testament.janet#L130

## testament/set-report-printer

**function**  | [source][12]

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

[12]: src/testament.janet#L65

