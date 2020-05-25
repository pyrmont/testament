### Testament

## A testing library for Janet

## by Michael Camilleri
## 8 May 2020

## Thanks to Sean Walker (for tester) and to Stuart Sierra (for clojure.test),
## both of which served as inspirations.


### Globals used by the reporting functions

(var- num-tests-run 0)
(var- num-asserts 0)
(var- num-tests-passed 0)
(var- tests @[])
(var- reports @[])
(var- print-reports nil)
(var- on-result-hook (fn [&]))


### Reporting functions

(defn set-on-result-hook
  ```
  Sets the `on-result-hook`. The function `f` will be invoked when a `result`
  becomes available. A result is a struct with the following keys:

  - `:passed?` whether an assertion succeeded (as boolean);
  - `:details` the details of the result (as string);
  - `:note` a description of the assertion (as string).

  The value of the string returned via `:details` will depend on the type of
  assertion made. Successful asssertions always result in the string "Passed"
  but failed assertions will result in a message relevant to the contents of
  the assertion (see the specific assertion for more details).
  ```
  [f]
  (if (= :function (type f))
    (set on-result-hook f)
    (error "argument not of type :function")))


(defn set-report-printer
  ```
  Sets the `print-reports` function. The function `f` will be applied with the
  following three arguments:

  1. the number of tests run (as integer);
  2. number of assertions (as integer); and
  3. number of tests passed (as integer).

  The function will not be called if `run-tests!` is called with `:silent` set
  to `true`.
  ```
  [f]
  (if (= :function (type f))
    (set print-reports f)
    (error "argument not of type :function")))


(defn- default-print-reports
  ```
  Print reports
  ```
  [num-tests-run num-asserts num-tests-passed]
  (each report reports
    (unless (empty? (report :failures))
      (do
        (print "\n> Failed: " (report :name))
        (each failure (report :failures)
          (print "Assertion: " (failure :note))
          (print (failure :details))))))
  (let [stats (string num-tests-run " tests run containing "
                      num-asserts " assertions\n"
                      num-tests-passed " tests passed, "
                      (- num-tests-run num-tests-passed) " tests failed")
        len   (->> (string/split "\n" stats) (map length) (splice) (max))]
    (print)
    (print (string/repeat "-" len))
    (print stats)
    (print (string/repeat "-" len))))


(defn- add-to-report
  ```
  Add result to the current report

  The current report is the last report created. Behaviour is undefined if tests
  are run in parallel or concurrently.
  ```
  [result]
  (let [latest (last reports)
        queue  (if (result :passed?) (latest :passes) (latest :failures))]
    (array/push queue result)))


(defn- compose-and-record-result
  ```
  Compose a result and record it if applicable
  ```
  [passed? details note]
  (++ num-asserts)
  (let [result {:passed? passed? :details details :note note}]
    (when (not (empty? reports))
        (on-result-hook result)
        (add-to-report result))
    result))


### Test utility functions

(defn- register-test
  ```
  Register a test with the test suite
  ```
  [t]
  (array/push tests t)
  t)


(defn- setup-test
  ```
  Perform tasks to setup the test, `name`
  ```
  [name]
  (++ num-tests-run)
  (array/push reports @{:name name :passes @[] :failures @[]}))


(defn- teardown-test
  ```
  Perform tasks to teardown the test, `name`
  ```
  [name]
  (if (-> (array/peek reports) (get :failures) length zero?)
    (++ num-tests-passed)))


### Utility function

(defn- which
  ```
  Determine the type of assertion being performed
  ```
  [assertion]
  (cond
    (and (tuple? assertion) (= 3 (length assertion)) (= '= (first assertion)))
    :equal

    (and (tuple? assertion) (= 2 (length assertion)) (= 'thrown? (first assertion)))
    :thrown

    (and (tuple? assertion) (= 3 (length assertion)) (= 'thrown? (first assertion)))
    :thrown-message

    :else
    :expr))


### Function form of assertion macros

(defn- assert-expr*
  ```
  Function form of assert-expr
  ```
  [expr form note]
  (let [expr    (not (not expr))
        details (if expr "Passed" "Reason: Result is Boolean false")
        note    (or note (string/format "%q" form))]
   (compose-and-record-result expr details note)))


(defn- assert-equal*
  ```
  Function form of assert-equal
  ```
  [expect expect-form actual actual-form note]
  (let [result  (= expect actual)
        details (if result "Passed"
                           (string "Expect: " (string/format "%q\n" expect)
                                   "Actual: " (string/format "%q" actual)))
        note    (or note (string/format "(= %q %q)" expect-form actual-form))]
    (compose-and-record-result result details note)))


(defn- assert-thrown*
  ```
  Function form of assert-thrown
  ```
  [thrown? form note]
  (let [details (if thrown? "Passed" "Reason: No error thrown")
        note    (or note (string/format "thrown? %q" form))]
    (compose-and-record-result thrown? details  note)))


(defn- assert-thrown-message*
  ```
  Function form of assert-thrown-message
  ```
  [thrown? form expect-message expect-form actual-message note]
  (let [details (if thrown? "Passed"
                            (string "Expect: Error message " (string/format "%q\n" expect-message)
                                    "Actual: Error message " (string/format "%q" actual-message)))
        note    (or note (string/format "thrown? %q %q" expect-form form))]
    (compose-and-record-result thrown? details note)))


### Assertion macros

(defmacro assert-expr
  ```
  Assert that the expression, `expr`, is true (with an optional `note`)

  The `assert-expr` macro provides a mechanism for creating a generic assertion.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form of `expr` is used.

  When an assertion is run as part of a test, the result is saved in the test's
  report. The result of an assertion is a struct with 3 keys: (1) `:passed?` (a
  boolean), (2) `:details` (a string) and (3) `:note` (a string). If the
  assertion succeeds, the value of `:details` will be "Passed". If the
  assertion fails, the value of `:details` will be "Reason: Result is Boolean
  false".
  ```
  [expr &opt note]
  ~(,assert-expr* ,expr ',expr ,note))


(defmacro assert-equal
  ```
  Assert that `expect` is equal to `actual` (with an optional `note`)

  The `assert-equal` macro provides a mechanism for creating an assertion that
  an expected result is equal to the actual result. The forms of `expect` and
  `actual` will be used in the output of any failure report.

  An optional `note` can be included that will be used in any failure report to
  identify the assertion. If no `note` is provided, the form `(= expect actual)`
  is used.

  When an assertion is run as part of a test, the result is saved in the test's
  report. The result of an assertion is a struct with 3 keys: (1) `:passed?` (a
  boolean), (2) `:details` (a string) and (3) `:note` (a string). If the
  assertion succeeds, the value of `:details` will be "Passed". If the
  assertion fails, the value of `:details` will be "Expect:
  <expected evaluation>\nActual: <actual evaluation>".
  ```
  [expect actual &opt note]
  ~(,assert-equal* ,expect ',expect ,actual ',actual ,note))


(defmacro assert-thrown
  ```
  Assert that an expression, `expr`, throws an error (with an optional `note`)

  The `assert-thrown` macro provides a mechanism for creating an assertion that
  an expression throws an error.

  An optional `note` can be included that will be used in any failure report to
  identify the assertion. If no `note` is provided, the form `thrown? expr` is
  used.

  When an assertion is run as part of a test, the result is saved in the test's
  report. The result of an assertion is a struct with 3 keys: (1) `:passed?` (a
  boolean), (2) `:details` (a string) and (3) `:note` (a string). If the
  assertion succeeds, the value of `:details` will be "Passed". If the
  assertion fails, the value of `:details` will be "Reason: No error thrown".
  ```
  [expr &opt note]
  (let [errsym (keyword (gensym))]
    ~(,assert-thrown* (= ,errsym (try ,expr ([_] ,errsym))) ',expr ,note)))


(defmacro assert-thrown-message
  ```
  Assert that the expression, `expr`, throws an error with the message `expect`
  (with an optional `note`)

  The `assert-thrown` macro provides a mechanism for creating an assertion that
  an expression throws an error with the specified message.

  An optional `note` can be included that will be used in any failure report to
  identify the assertion. If no `note` is provided, the form
  `thrown? expect expr` is used.

  When an assertion is run as part of a test, the result is saved in the test's
  report. The result of an assertion is a struct with 3 keys: (1) `:passed?` (a
  boolean), (2) `:details` (a string) and (3) `:note` (a string). If the
  assertion succeeds, the value of `:details` will be "Passed". If the
  assertion fails, the value of `:details` will be "Expect: Error message
  <expected message>\nActual: Error message <actual message>".
  ```
  [expect expr &opt note]
  (let [errsym   (keyword (gensym))
        sentinel (gensym)
        actual   (gensym)]
    ~(let [[,sentinel ,actual] (try (do ,expr [nil nil]) ([err] [,errsym err]))]
      (,assert-thrown-message* (and (= ,sentinel ,errsym) (= ,expect ,actual )) ',expr ,expect ',expect ,actual ,note))))


(defmacro is
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
  ```
  [assertion &opt note]
  (case (which assertion)
    :equal
    (let [[_ expect actual] assertion]
      ~(,assert-equal* ,expect ',expect ,actual ',actual ,note))

    :thrown
    (let [[_ form] assertion
          errsym   (keyword (gensym))]
      ~(,assert-thrown* (= ,errsym (try ,form ([_] ,errsym))) ',form ,note))

    :thrown-message
    (let [[_ expect form] assertion
          errsym   (keyword (gensym))
          sentinel (gensym)
          actual   (gensym)]
      ~(let [[,sentinel ,actual] (try (do ,form [nil nil]) ([err] [,errsym err]))]
        (,assert-thrown-message* (and (= ,sentinel ,errsym) (= ,expect ,actual )) ',form ,expect ',expect ,actual ,note)))


    :expr
    ~(,assert-expr* ,assertion ',assertion ,note)))


### Test definition macro

(defmacro deftest
  ```
  Define a test, `name`, and register it in the suite

  A test is just a function. The `body` is used as the body of the function
  produced by this macro but with respective setup and teardown steps inserted
  before and after the forms in `body` are called.
  ```
  [name & body]
  ~(def ,name (,register-test (fn []
                                (,setup-test ',name)
                                ,;body
                                (,teardown-test ',name)))))


### Test suite functions

(defn run-tests!
  ```
  Run the registered tests

  This function will run the tests registered in the test suite via `deftest`.
  It accepts two optional arguments:

  1. `:silent` whether to omit the printing of reports (default: `false`); and
  2. `:exit-on-fail` whether to exit if any of the tests fail (default: `true`).
  ```
  [&keys {:silent silent? :exit-on-fail exit?}]
  (default exit? true)
  (each test tests (test))
  (unless silent?
    (when (nil? print-reports)
      (set-report-printer default-print-reports))
    (print-reports num-tests-run num-asserts num-tests-passed))
  (when exit?
    (unless  (= num-tests-run num-tests-passed)
      (os/exit 1))))


(defn reset-tests!
  ```
  Reset all reporting variables
  ```
  []
  (set num-tests-run 0)
  (set num-asserts 0)
  (set num-tests-passed 0)
  (set tests @[])
  (set reports @[])
  (set print-reports nil)
  (set on-result-hook (fn [&])))
