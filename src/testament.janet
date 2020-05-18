### testament: a testing library for Janet

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


### Reporting functions

(defn- print-reports
  ```
  Print reports
  ```
  []
  (each report reports
    (unless (empty? (report :failures))
      (do
        (print "\n> Failed: " (report :name))
        (each failure (report :failures)
          (print "Assertion: " (failure :note))
          (print (failure :report))))))
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
  [passed? report note]
  (++ num-asserts)
  (let [result {:passed? passed? :report report :note note}]
    (when (not (empty? reports))
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
  (let [expr   (not (not expr))
        report (if expr "Passed" "Reason: Result is Boolean false")
        note   (or note (string/format "%q" form))]
   (compose-and-record-result expr report note)))


(defn- assert-equal*
  ```
  Function form of assert-equal
  ```
  [expect expect-form actual actual-form note]
  (let [result (= expect actual)
        report (if result "Passed"
                          (string "Expected: " (string/format "%q\n" expect)
                                  "Actual: " (string/format "%q" actual)))
        note   (or note (string/format "(= %q %q)" expect-form actual-form))]
    (compose-and-record-result result report note)))


(defn- assert-thrown*
  ```
  Function form of assert-thrown
  ```
  [thrown? form note]
  (let [report (if thrown? "Passed" "Reason: No error thrown")
        note   (or note (string/format "thrown? %q" form))]
    (compose-and-record-result thrown? report note)))


(defn- assert-thrown-message*
  ```
  Function form of assert-thrown-message
  ```
  [thrown? form actual expect note]
  (let [report (if thrown? "Passed"
                           (string "Expected: Error with message " (string/format "%q\n" expect)
                                   "Actual: Error with message " (string/format "%q" actual)))
        note   (or note (string/format "thrown? %q %q" expect form))]
    (compose-and-record-result thrown? report note)))


### Assertion macros

(defmacro assert-expr
  ```
  Assert that the expression, `expr`, is true (with an optional `note`)

  The `assert-expr` macro provides a mechanism for creating a generic assertion.

  An optional `note` can be included that will be used in any failure report to
  identify the assertion. If no `note` is provided, the form of `expr` is used.
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
  ```
  [expect actual &opt note]
  ~(,assert-equal* ,expect ',expect ,actual ',actual ,note))


(defmacro assert-thrown
  ```
  Assert that the expression, `expr`, threw an error (with an optional `note`)

  The `assert-thrown` macro provides a mechanism for creating an assertion that
  an expression threw an error.

  An optional `note` can be included that will be used in any failure report to
  identify the assertion. If no `note` is provided, the form `thrown? form` is
  used.
  ```
  [form &opt note]
  (let [errsym (keyword (gensym))]
    ~(,assert-thrown* (= ,errsym (try ,form ([_] ,errsym))) ',form ,note)))


(defmacro assert-thrown-message
  ```
  Assert that the expression, `expr`, threw an error with the message `expect`
  (with an optional `note`)

  The `assert-thrown` macro provides a mechanism for creating an assertion that
  an expression threw an error with the specified message.

  An optional `note` can be included that will be used in any failure report to
  identify the assertion. If no `note` is provided, the form
  `thrown? expect form` is used.
  ```
  [expect form &opt note]
  (let [errsym   (keyword (gensym))
        sentinel (gensym)
        actual   (gensym)]
    ~(let [[,sentinel ,actual] (try (do ,form [nil nil]) ([err] [,errsym err]))]
      (,assert-thrown-message* (and (= ,sentinel ,errsym) (= ,expect ,actual )) ',form ,expect ,actual ,note))))


(defmacro is
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
        (,assert-thrown-message* (and (= ,sentinel ,errsym) (= ,expect ,actual )) ',form ,expect ,actual ,note)))


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

  Accepts an optional `:silent` argument that will omit any reports being
  printed.
  ```
  [&keys {:silent silent}]
  (each test tests (test))
  (unless silent
    (print-reports))
  (unless (= num-tests-run num-tests-passed)
    (os/exit 1)))


(defn reset-tests!
  ```
  Reset all reporting variables
  ```
  []
  (set num-tests-run 0)
  (set num-asserts 0)
  (set num-tests-passed 0)
  (set tests @[])
  (set reports @[]))
