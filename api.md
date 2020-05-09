# Testament API

[`testament/assert-equal`](#testamentassert-equal),
[`testament/assert-expr`](#testamentassert-expr),
[`testament/deftest`](#testamentdeftest),
[`testament/is`](#testamentis),
[`testament/reset-tests!`](#testamentreset-tests!),
[`testament/run-tests!`](#testamentrun-tests!)

## testament/assert-equal

**macro** | [source][s1]

```
(assert-equal expect actual &opt note)
```

Assert that `expect` is equal to `actual` (with an optional `note`)

The `assert-equal` macro provides a mechanism for creating an assertion that
an expected result is equal to the actual result. The forms of `expect` and
`actual` will be used in the output of any failure report.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form `(= expect actual)`
is used.

[s1]: https://github.com/pyrmont/testament/blob/master/src/testament.janet#L153


## testament/assert-expr

**macro** | [source][s2]

```
(assert-expr expr &opt note)
```

Assert that the expression, `expr`, is true (with an optional `note`)

The `assert-expr` macro provides a mechanism for creating a generic assertion.

An optional `note` can be included that will be used in any failure report to
identify the assertion. If no `note` is provided, the form of `expr` is used.

[s2]: https://github.com/pyrmont/testament/blob/master/src/testament.janet#L140


## testament/deftest

**macro** | [source][s3]

```
(deftest name & body)
```

Define a test, `name`, and register it in the suite

A test is just a function. The `body` is used as the body of the function
produced by this macro but with respective setup and teardown steps inserted
before and after the forms in `body` are called.

[s3]: https://github.com/pyrmont/testament/blob/master/src/testament.janet#L195


## testament/is

**macro** | [source][s4]

```
(is assertion &opt note)
```

Assert that an `assertion` is true (with an optional `note`)

The `is` macro provides a succinct mechanism for creating assertions.
Testament includes support for two types of assertions:

1. a generic assertion that asserts the Boolean truth of an expression; and
2. an equality assertion that asserts that an expected result and an actual
   result are equal.

`is` causes the appropriate assertion to be inserted based on the form of the
asserted expression.

An optional `note` can be included that will be used in any failure report to
identify the assertion.

[s4]: https://github.com/pyrmont/testament/blob/master/src/testament.janet#L169


## testament/reset-tests!

**function** | [source][s5]

```
(reset-tests!)
```

Reset all reporting variables

[s5]: https://github.com/pyrmont/testament/blob/master/src/testament.janet#L227


## testament/run-tests!

**function** | [source][s6]

```
(run-tests! &keys {:silent silent})
```

Run the registered tests

Acceptions an optional `:silent` argument that will omit any reports being
printed.

[s6]: https://github.com/pyrmont/testament/blob/master/src/testament.janet#L212
