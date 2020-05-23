# Testament API

[testament/assert-equal](#testamentassert-equal)
, [testament/assert-expr](#testamentassert-expr)
, [testament/assert-thrown](#testamentassert-thrown)
, [testament/assert-thrown-message](#testamentassert-thrown-message)
, [testament/deftest](#testamentdeftest)
, [testament/is](#testamentis)
, [testament/reset-tests!](#testamentreset-tests)
, [testament/run-tests!](#testamentrun-tests)
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

[1]: src/testament.janet#L203

## testament/assert-expr

**macro**  | [source][2]

```janet
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[2]: src/testament.janet#L190

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

[3]: src/testament.janet#L219

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

[4]: src/testament.janet#L235

## testament/deftest

**macro**  | [source][5]

```janet
(deftest name & body)
```

Define a test, `name`, and register it in the suite

A test is just a function. The `body` is used as the body of the function
produced by this macro but with respective setup and teardown steps inserted
before and after the forms in `body` are called.

[5]: src/testament.janet#L301

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

[6]: src/testament.janet#L255

## testament/reset-tests!

**function**  | [source][7]

```janet
(reset-tests!)
```

Reset all reporting variables

[7]: src/testament.janet#L335

## testament/run-tests!

**function**  | [source][8]

```janet
(run-tests! &keys {:silent silent})
```

Run the registered tests

Accepts an optional `:silent` argument that will omit any reports being
printed.

[8]: src/testament.janet#L318

## testament/set-report-printer

**function**  | [source][9]

```janet
(set-report-printer f)
```

Sets the `print-reports` function. The function `f` will be applied with the
following three arguments:

1. the number of tests run (as integer);
2. number of assertions (as integer); and
3. number of tests passed (as integer).

The function will not be called if `run-tests!` is called with `:silent` set
to `true`.

[9]: src/testament.janet#L24

