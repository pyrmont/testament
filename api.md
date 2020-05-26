# Testament API

[testament/assert-equal](#testamentassert-equal)
, [testament/assert-expr](#testamentassert-expr)
, [testament/assert-thrown](#testamentassert-thrown)
, [testament/assert-thrown-message](#testamentassert-thrown-message)
, [testament/deftest](#testamentdeftest)
, [testament/is](#testamentis)
, [testament/reset-tests!](#testamentreset-tests)
, [testament/run-tests!](#testamentrun-tests)
, [testament/set-on-result-hook](#testamentset-on-result-hook)
, [testament/set-report-printer](#testamentset-report-printer)

## testament/assert-equal

**macro**  | [source][1]

```janet
(assert-equal expect actual &opt note)
```

Assert that `expect` is equal to `actual` (with an optional `note`)

The `assert-equal` macro provides a mechanism for creating an assertion that
an expected result is equal to the actual result. The forms of `expect` and
`actual` will be used in the output of any failure report.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form `(= expect actual)`
is used.

[1]: src/testament.janet#L259

## testament/assert-expr

**macro**  | [source][2]

```janet
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure result to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[2]: src/testament.janet#L246

## testament/assert-thrown

**macro**  | [source][3]

```janet
(assert-thrown expr &opt note)
```

Assert that an expression, `expr`, throws an error (with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression throws an error.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form `thrown? expr` is
used.

[3]: src/testament.janet#L275

## testament/assert-thrown-message

**macro**  | [source][4]

```janet
(assert-thrown-message expect expr &opt note)
```

Assert that the expression, `expr`, throws an error with the message `expect`
(with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression throws an error with the specified message.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form
`thrown? expect expr` is used.

[4]: src/testament.janet#L291

## testament/deftest

**macro**  | [source][5]

```janet
(deftest name & body)
```

Define a test, `name`, and register it in the suite

A test is just a function. The `body` is used as the body of the function
produced by this macro but with respective setup and teardown steps inserted
before and after the forms in `body` are called.

[5]: src/testament.janet#L360

## testament/is

**macro**  | [source][6]

```janet
(is assertion &opt note)
```

Assert that an `assertion` is true (with an optional `note`)

The `is` macro provides a succinct mechanism for creating assertions.
Testament includes support for four types of assertions:

1. a generic assertion that asserts the Boolean truth of an expression;
2. an equality assertion that asserts that an expected result and an actual
   result are equal;
3. a throwing assertion that asserts an error is thrown; and
4. a throwing assertion that asserts an error with a specific message is
   thrown.

`is` causes the appropriate assertion to be inserted based on the form of the
asserted expression.

An optional `note` can be included that will be used in any failure report to
identify the assertion.

See the documentation for each assertion type for details of the result
reported.

[6]: src/testament.janet#L311

## testament/reset-tests!

**function**  | [source][7]

```janet
(reset-tests!)
```

Reset all reporting variables

[7]: src/testament.janet#L399

## testament/run-tests!

**function**  | [source][8]

```janet
(run-tests! &keys {:exit-on-fail exit? :silent silent?})
```

Run the registered tests

This function will run the tests registered in the test suite via `deftest`.
It accepts two optional arguments:

1. `:silent` whether to omit the printing of reports (default: `false`); and
2. `:exit-on-fail` whether to exit if any of the tests fail (default: `true`).

[8]: src/testament.janet#L377

## testament/set-on-result-hook

**function**  | [source][9]

```janet
(set-on-result-hook f)
```

Set the `on-result-hook`

The function `f` will be invoked when a `result` becomes available. The
`result` is a struct with the following keys:

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

[9]: src/testament.janet#L25

## testament/set-report-printer

**function**  | [source][10]

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

[10]: src/testament.janet#L51

