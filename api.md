# Testament API

[testament/assert-equal](#testamentassert-equal)
, [testament/assert-expr](#testamentassert-expr)
, [testament/assert-thrown](#testamentassert-thrown)
, [testament/assert-thrown-message](#testamentassert-thrown-message)
, [testament/deftest](#testamentdeftest)
, [testament/is](#testamentis)
, [testament/reset-tests!](#testamentreset-tests)
, [testament/run-tests!](#testamentrun-tests)


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

[1]: src/testament.janet#L182


## testament/assert-expr

**macro**  | [source][2]

```janet
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[2]: src/testament.janet#L169


## testament/assert-thrown

**macro**  | [source][3]

```janet
(assert-thrown form &opt note)
```

Assert that the expression, `expr`, threw an error (with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression threw an error.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form `thrown? form` is
used.

[3]: src/testament.janet#L198


## testament/assert-thrown-message

**macro**  | [source][4]

```janet
(assert-thrown-message expect form &opt note)
```

Assert that the expression, `expr`, threw an error with the message `expect`
(with an optional `note`)

The `assert-thrown` macro provides a mechanism for creating an assertion that
an expression threw an error with the specified message.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form
`thrown? expect form` is used.

[4]: src/testament.janet#L214


## testament/deftest

**macro**  | [source][5]

```janet
(deftest name & body)
```

Define a test, `name`, and register it in the suite

A test is just a function. The `body` is used as the body of the function
produced by this macro but with respective setup and teardown steps inserted
before and after the forms in `body` are called.

[5]: src/testament.janet#L278


## testament/is

**macro**  | [source][6]

```janet
(is assertion &opt note)
```

Assert that an `assertion` is true (with an optional `note`)

The `is` macro provides a succinct mechanism for creating assertions.
Testament includes support for three types of assertions:

1. a generic assertion that asserts the Boolean truth of an expression;
2. an equality assertion that asserts that an expected result and an actual
   result are equal;
3. an assertion that an error will be thrown.

`is` causes the appropriate assertion to be inserted based on the form of the
asserted expression.

An optional `note` can be included that will be used in any failure report to
identify the assertion.

[6]: src/testament.janet#L234


## testament/reset-tests!

**function**  | [source][7]

```janet
(reset-tests!)
```

Reset all reporting variables

[7]: src/testament.janet#L310


## testament/run-tests!

**function**  | [source][8]

```janet
(run-tests! &keys {:silent silent})
```

Run the registered tests

Accepts an optional `:silent` argument that will omit any reports being
printed.

[8]: src/testament.janet#L295


