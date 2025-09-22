### Testament

## A testing library for Janet

## Thanks to Sean Walker (for tester) and to Stuart Sierra (for clojure.test),
## both of which served as inspirations.

### Default values

(defn- default-result-hook [&])


### Globals used by the reporting functions

(var- num-tests-run 0)
(var- num-asserts 0)
(var- num-tests-passed 0)
(var- curr-test nil)
(var- tests @{})
(var- reports @{})
(var- print-reports-fn nil)
(var- print-results-fn nil)
(var- on-result-hook default-result-hook)


### Equivalence functions

(def- kind
  {:tuple  :list
   :array  :list
   :struct :dictionary
   :table  :dictionary
   :string :bytes
   :buffer :bytes
   :number :number})


(defn- types-equivalent?
  [tx ty]
  (or
    (= tx ty)
    (and (not (nil? (kind tx)))
         (= (kind tx) (kind ty)))))


(defn- not==
  [x y]
  (def tx (type x))
  (or
    (not (types-equivalent? tx (type y)))
    (case (kind tx)
      :list (or (not= (length x) (length y))
                (some identity (map not== x y)))
      :dictionary (or (not= (length (keys x)) (length (keys y)))
                      (some identity (seq [k :in (keys x)] (not== (get x k) (get y k)))))
      :bytes (not= (string x) (string y))
      :number (or (and (nan? x) (not (nan? y)))
                  (and (not (nan? x)) (not= x y)))
      (not= x y))))


(defn ==
  ```
  Returns true if the arguments are equivalent

  The arguments are considered equivalent for the purposes of this function if
  they are of equivalent types and have the same structure. Types are equivalent
  if they are the same or differ only in terms of mutability (e.g. arrays and
  tuples).

  Instances of `math/nan` are considered equivalent for the purposes of this
  function.
  ```
  [x y]
  (not (not== x y)))


### Reporting functions

(defn set-report-printer
  ```
  Sets the function to print reports during `run-tests!`

  The function `f` will be applied with the following three arguments:

  1. the number of tests run (as integer);
  2. number of assertions (as integer); and
  3. number of tests passed (as integer).

  A default printer function is used if no function has been set. In all cases,
  the function will not be called if `run-tests!` is called with `:silent` set
  to `true`.
  ```
  [f]
  (if (= :function (type f))
    (set print-reports-fn f)
    (error "argument not of type :function")))


(defn set-results-printer
  ```
  Sets the function to print test results

  The function `f` will be applied with the following one argument:

  1. test reports (as a table).

  A default printer function is used if no function has been set.
  ```
  [f]
  (if (= :function (type f))
    (set print-results-fn f)
    (error "argument not of type :function")))


(defn- colour
  [c text]
  (def colours {:green "\e[32m" :red "\e[31m"})
  (if (dyn :test/color?)
    (string (get colours c "\e[0m") text "\e[0m")
    text))


(defn- ruler
  ```
  Prints a dashed line as long as the longest line
  ```
  [lines &opt sym]
  (default sym "=")
  (def len (->> (string/split "\n" lines)
                (map length)
                (splice)
                (max)))
  (print (string/repeat sym len)))


(defn- stats
  []
  (string num-tests-run " tests run containing "
          num-asserts " assertions\n"
          num-tests-passed " tests passed, "
          (- num-tests-run num-tests-passed) " tests failed"))


(defn- failure-message
  ```
  Returns the appropriate failure message for the given result
  ```
  [result]
  (case (result :kind)
    :equal
    (string "Expect (L): " (string/format "%q" (result :expect)) "\n"
            "Actual (R): " (string/format "%q" (result :actual)))

    :matches
    (string "Expect (L): Structure " (string/format "%q" (result :expect)) "\n"
            "Actual (R): " (string/format "%q" (result :actual)))

    :thrown
    "Reason: No error thrown"

    :thrown-message
    (string "Expect (L): Error message " (string/format "%q" (result :expect)) "\n"
            "Actual (R): Error message " (string/format "%q" (result :actual)))

    :expr
    "Reason: Result is Boolean false"))


(defn- default-print-results
  [reports]
  (def s (stats))
  (each report reports
    (unless (empty? (report :failures))
      (ruler s "-")
      (print "> " (colour :red "Failed") ": " (report :test))
      (each failure (report :failures)
        (print "Assertion: " (failure :note))
        (print (failure-message failure))))))


(defn- print-results
  ```
  Prints results
  ```
  []
  (def printer (or print-results-fn default-print-results))
  (printer reports))


(defn- default-print-reports
  [num-tests-run num-asserts num-tests-passed]
  (def s (stats))
  (print-results)
  (ruler s)
  (print s)
  (ruler s))


(defn- print-reports
  ```
  Prints reports
  ```
  []
  (def printer (or print-reports-fn default-print-reports))
  (printer num-tests-run num-asserts num-tests-passed))


### Recording functions

(defn set-on-result-hook
  ```
  Sets the `on-result-hook`

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
  ```
  [f]
  (if (= :function (type f))
    (set on-result-hook f)
    (error "argument not of type :function")))


(defn- add-to-report
  ```
  Adds `result` to the report for test `name`
  ```
  [result]
  (if-let [name   (result :test)
           report (reports name)
           queue  (if (result :passed?) (report :passes) (report :failures))]
    (array/push queue result)))


(defn- compose-and-record-result
  ```
  Composes a result and records it if applicable
  ```
  [result]
  (++ num-asserts)
  (on-result-hook result)
  (add-to-report result)
  result)


### Test utility functions

(defn- register-test
  ```
  Registers a test `t` with a `name `in the test suite

  This function will print a warning to `:err` if a test with the same `name`
  has already been registered in the test suite.
  ```
  [name t]
  (unless (nil? (tests name))
    (eprint "[testament] registered multiple tests with the same name"))
  (set (tests name) t))


(defn- setup-test
  ```
  Performs tasks to setup the test, `name`
  ```
  [name]
  (set curr-test name)
  (put reports name @{:test name :passes @[] :failures @[]}))


(defn- teardown-test
  ```
  Performs tasks to teardown the test, `name`
  ```
  [name]
  (++ num-tests-run)
  (if (-> (reports name) (get :failures) length zero?)
    (++ num-tests-passed))
  (set curr-test nil))


### Utility function

(defn- which
  ```
  Determines the type of assertion being performed
  ```
  [assertion]
  (cond
    (and (tuple? assertion) (= 3 (length assertion)) (= '= (first assertion)))
    :equal

    (and (tuple? assertion) (= 3 (length assertion)) (= 'deep= (first assertion)))
    :deep-equal

    (and (tuple? assertion) (= 3 (length assertion)) (= '== (first assertion)))
    :equivalent

    (and (tuple? assertion) (= 3 (length assertion)) (= 'matches (first assertion)))
    :matches

    (and (tuple? assertion) (= 2 (length assertion)) (= 'thrown? (first assertion)))
    :thrown

    (and (tuple? assertion) (= 3 (length assertion)) (= 'thrown? (first assertion)))
    :thrown-message

    :else
    :expr))


### Function form of assertion macros

(defn- assert-expr*
  ```
  Functional form of assert-expr
  ```
  [expr form note]
  (let [passed? (not (not expr))
        result  {:test    curr-test
                 :kind    :expr
                 :passed? passed?
                 :expect  true
                 :actual  passed?
                 :note    (or note (string/format "%q" form))}]
   (compose-and-record-result result)))


(defn- assert-equal*
  ```
  Functional form of assert-equal
  ```
  [expect expect-form actual actual-form note]
  (let [result {:test    curr-test
                :kind    :equal
                :passed? (= expect actual)
                :expect  expect
                :actual  actual
                :note    (or note (string/format "(= %q %q)" expect-form actual-form))}]
    (compose-and-record-result result)))


(defn- assert-deep-equal*
  ```
  Functional form of assert-deep-equal
  ```
  [expect expect-form actual actual-form note]
  (let [result {:test    curr-test
                :kind    :equal
                :passed? (deep= expect actual)
                :expect  expect
                :actual  actual
                :note    (or note (string/format "(deep= %q %q)" expect-form actual-form))}]
    (compose-and-record-result result)))


(defn- assert-equivalent*
  ```
  Functional form of assert-equivalent
  ```
  [expect expect-form actual actual-form note]
  (let [result {:test    curr-test
                :kind    :equal
                :passed? (== expect actual)
                :expect  expect
                :actual  actual
                :note    (or note (string/format "(== %q %q)" expect-form actual-form))}]
    (compose-and-record-result result)))


(defn- assert-matches*
  ```
  Functional form of assert-matches
  ```
  [structure actual actual-form note]
  (let [result {:test    curr-test
                :kind    :matches
                :passed? (not (nil? (eval (apply match [actual structure true]))))
                :expect  structure
                :actual  actual
                :note    (or note (string/format "(matches %q %q)" structure actual-form))}]
    (compose-and-record-result result)))


(defn- assert-thrown*
  ```
  Functional form of assert-thrown
  ```
  [thrown? form note]
  (let [result {:test    curr-test
                :kind    :thrown
                :passed? thrown?
                :expect  true
                :actual  thrown?
                :note    (or note (string/format "thrown? %q" form))}]
    (compose-and-record-result result)))


(defn- assert-thrown-message*
  ```
  Functional form of assert-thrown-message
  ```
  [thrown? form expect-message expect-form actual-message note]
  (let [result {:test    curr-test
                :kind    :thrown-message
                :passed? thrown?
                :expect  expect-message
                :actual  actual-message
                :note    (or note (string/format "thrown? %q %q" expect-form form))}]
    (compose-and-record-result result)))


### Assertion macros

(defmacro assert-expr
  ```
  Asserts that the expression, `expr`, is true (with an optional `note`)

  The `assert-expr` macro provides a mechanism for creating a generic assertion.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form of `expr` is used.
  ```
  [expr &opt note]
  ~(,assert-expr* ,expr ',expr ,note))


(defmacro assert-equal
  ```
  Asserts that `expect` is equal to `actual` (with an optional `note`)

  The `assert-equal` macro provides a mechanism for creating an assertion that
  an expected result is equal to the actual result. The forms of `expect` and
  `actual` will be used in the output of any failure report.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form `(= expect actual)`
  is used.
  ```
  [expect actual &opt note]
  ~(,assert-equal* ,expect ',expect ,actual ',actual ,note))


(defmacro assert-deep-equal
  ```
  Asserts that `expect` is deeply equal to `actual` (with an optional `note`)

  The `assert-deep-equal` macro provides a mechanism for creating an assertion
  that an expected result is deeply equal to the actual result. The forms of
  `expect` and `actual` will be used in the output of any failure report.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form
  `(deep= expect actual)` is used.
  ```
  [expect actual &opt note]
  ~(,assert-deep-equal* ,expect ',expect ,actual ',actual ,note))


(defmacro assert-equivalent
  ```
  Asserts that `expect` is equivalent to `actual` (with an optional `note`)

  The `assert-equivalent` macro provides a mechanism for creating an assertion
  that an expected result is equivalent to the actual result. Testament
  considers forms to be equivalent if the types are 'equivalent' (that is, they
  are the same or differ only in terms of mutability) and the structure is
  equivalent.  The forms of `expect` and `actual` will be used in the output of
  any failure report.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form `(== expect actual)`
  is used.
  ```
  [expect actual &opt note]
  ~(,assert-equivalent* ,expect ',expect ,actual ',actual ,note))


(defmacro assert-matches
  ```
  Asserts that `structure` matches `actual` (with an optional `note`)

  The `assert-matches` macro provides a mechanism for creating an assertion that
  an expression matches a particular structure (at least in part).

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form
  `(matches structure actual)` is used.
  ```
  [structure actual &opt note]
  ~(,assert-matches* ',structure ,actual ',actual ,note))


(defmacro assert-thrown
  ```
  Asserts that an expression, `expr`, throws an error (with an optional `note`)

  The `assert-thrown` macro provides a mechanism for creating an assertion that
  an expression throws an error.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form `thrown? expr` is
  used.
  ```
  [expr &opt note]
  (let [errsym (keyword (gensym))]
    ~(,assert-thrown* (= ,errsym (try ,expr ([_] ,errsym))) ',expr ,note)))


(defmacro assert-thrown-message
  ```
  Asserts that the expression, `expr`, throws an error with the message `expect`
  (with an optional `note`)

  The `assert-thrown` macro provides a mechanism for creating an assertion that
  an expression throws an error with the specified message.

  An optional `note` can be included that will be used in any failure result to
  identify the assertion. If no `note` is provided, the form
  `thrown? expect expr` is used.
  ```
  [expect expr &opt note]
  (let [errsym   (keyword (gensym))
        sentinel (gensym)
        actual   (gensym)]
    ~(let [[,sentinel ,actual] (try (do ,expr [nil nil]) ([err] [,errsym err]))]
      (,assert-thrown-message* (and (= ,sentinel ,errsym) (= ,expect ,actual )) ',expr ,expect ',expect ,actual ,note))))


(defmacro is
  ```
  Asserts that an `assertion` is true (with an optional `note`)

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
  ```
  [assertion &opt note]
  (case (which assertion)
    :equal
    (let [[_ expect actual] assertion]
      ~(,assert-equal* ,expect ',expect ,actual ',actual ,note))

    :deep-equal
    (let [[_ expect actual] assertion]
      ~(,assert-deep-equal* ,expect ',expect ,actual ',actual ,note))

    :equivalent
    (let [[_ expect actual] assertion]
      ~(,assert-equivalent* ,expect ',expect ,actual ',actual ,note))

    :matches
    (let [[_ structure actual] assertion]
      ~(,assert-matches* ',structure ,actual ',actual ,note))

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


(defmacro each-is
  ```
  Asserts that each element in `assertions` is true (with an optional `note`)

  This effectively calls `is` on each element in `assertions` using the optional note.
  ```
  [assertions &opt note]
  ~(do
     ,(seq [a :in assertions] (apply is [a note]))
     nil))


### Test resets

(defn- empty-module-cache! []
  ```
  Empties module/cache to prevent caching between test runs in the same process
  ```
  (each key (keys module/cache)
    (put module/cache key nil)))


(defn reset-tests!
  ```
  Resets all reporting variables
  ```
  []
  (set num-tests-run 0)
  (set num-asserts 0)
  (set num-tests-passed 0)
  (set curr-test nil)
  (set tests @{})
  (set reports @{})
  nil)


(defn reset-all!
  ```
  Resets all reporting variables and settings
  ```
  []
  (reset-tests!)
  (set print-reports-fn nil)
  (set print-results-fn nil)
  (set on-result-hook default-result-hook)
  nil)


### Test definition macro

(defmacro deftest
  ```
  Defines a test and registers it in the test suite

  The `deftest` macro can be used to create named tests and anonymous tests. If
  the first argument is a symbol, that argument is treated as the name of the
  test. Otherwise, Testament uses `gensym` to generate a unique symbol to name
  the test. If a test with the same name has already been defined, `deftest`
  will print a warning.

  A test is just a function. `args` (excluding the first argument if that
  argument is a symbol) is used as the body of the function. Testament adds
  respective calls to a setup function and a teardown function before and after
  the forms in the body.

  The function can be called by itself and will use the function set with
  `set-results-printer` to print the result of running the test if there is a
  failure (a default printing function will be called if no function has been
  set). If the test is successful, no result is printed.

  In addition to creating a function, `deftest` registers the test in the _test
  suite_. Testament's test suite is a global table of tests that have been
  registered by `deftest`. When a user calls `run-tests!` without specifying any
  tests to run, each test in the test suite is called. The order in which each
  test is called is not guaranteed.

  If `deftest` is called with no arguments or if the only argument is a symbol,
  an arity error is raised.
  ```
  [& args]
  (when (or (zero? (length args))
            (and (one? (length args)) (= :symbol (type (first args)))))
    (error "arity mismatch"))
  (let [[name body] (if (= :symbol (type (first args)))
                      [(first args) (slice args 1)]
                      [(symbol "test" (gensym)) args])
        nameg (gensym)
        namek (keyword name)]
    ~(def ,name
       (do
         (def ,nameg (fn ,namek []
                          (,setup-test ',name)
                          ,;body
                          (,teardown-test ',name)))
         (,register-test ',name ,nameg)
         (fn ,namek [&named silent?]
           (,nameg)
           (unless silent?
             (,print-results))
           (,reset-tests!)
           nil)))))


### Test suite functions

(defn run-tests!
  ```
  Runs the registered tests

  This function will run the tests registered in the test suite via `deftest`.
  It accepts two optional arguments:

  1. `:silent?` whether to omit the printing of reports (default: `false`); and
  2. `:no-exit?` whether to exit if any of the tests fail (default: `false`).

  The `run-tests!` function will print the reports unless called with
  `:silent?`. The default report printing function will colourize the output if
  the `:test/colour?` dynamic binding is set to `true`.

  The `run-tests!` function calls `os/exit` when there are failing tests unless
  the argument `:no-exit?` is set to `false` or the `:testament/repl?` dynamic
  binding is set to `true`.

  If `:no-exit?` is set to `true`, the `run-tests!` function returns an indexed
  collection of test reports. Each report in the collection is a dictionary
  collection containing three keys: `:test`, `:passes` and `:failures`. `:test`
  is the name of the test while `:passes` and `:failures` contain the results
  of each respective passed and failed assertion. Each result is a data
  structure of the kind described in the docstring for `set-on-result-hook`.

  A user can specify tests to run or skip using the `:test/tests` and
  `:test/skips` dynamic bindings. Each should be an array/tuple that contains
  symbols matching the names of the tests to run or skip.

  Finally, if the dynamic binding `:testament/repl?` is set to `true`, this
  will also reset the test reports and empty the module/cache to provide a
  fresh run with the most up-to-date code.
  ```
  [&named no-exit? silent?]
  (each [name test] (pairs tests)
    (cond
      # if specific tests to run, run test if specified
      (dyn :test/tests)
      (when (has-value? (dyn :test/tests) name)
        (test))
      # if specific tests to skip, run test unless specified
      (dyn :test/skips)
      (unless (has-value? (dyn :test/skips) name)
        (test))
      # otherwise always run test
      (test)))
  # print reports
  (unless silent?
    (print-reports))
  # report values
  (def in-repl? (or (dyn :testament/repl?)
                    (dyn :testament-repl?)))
  (def report-values (values reports))
  (when (and (not no-exit?)
             (not in-repl?)
             (not (= num-tests-run num-tests-passed)))
    (os/exit 1))
  (when in-repl?
    (reset-tests!)
    (empty-module-cache!))
  report-values)


(defmacro exercise!
  ```
  Defines, runs and resets the tests provided in the macro body

  This macro will run the forms in `body`, call `run-test!`, call `reset-tests!`
  and then return the value of `run-tests!`.

  The user can specify the arguments to be passed to `run-tests!` by providing a
  tuple as `args`. If no arguments are necessary, `args` should be an empty
  tuple.

  Please note that, like `run-tests!`, `exercise!` calls `os/exit` when there
  are failing tests unless the argument `:no-exit?` is set to `true`.
  ```
  [args & body]
  (let [ret-val (gensym)]
    ~(do
       ,;body
       (def ,ret-val (,run-tests! ,;args))
       (,reset-tests!)
       ,ret-val)))


# Review macro

(defn- review-1
  ```
  Functional form of the review macro
  ```
  [path & args]
  (def env (curenv))
  (def kargs (table ;args))
  (def {:as as
        :prefix pfx
        :export ep} kargs)
  (def newenv (require path ;args))
  (each [k v] (pairs newenv)
    (when (dictionary? v)
      (put v :private nil)))
  (def prefix (or
                (and as (string as "/"))
                pfx
                (string (last (string/split "/" path)) "/")))
  (merge-module env newenv prefix))


(defmacro review
  ```
  Imports all bindings as public in the specified module

  This macro performs similarly to `import`. The difference is that it sets all
  the bindings as public. This is intended for situations where it is not
  desirable to make bindings public but the user would still like to be able to
  subject the bindings to testing.
  ```
  [path & args]
  (def path (string path))
  (def ps (partition 2 args))
  (def argm (mapcat (fn [[k v]] [k (if (= k :as) (string v) v)]) ps))
  (tuple review-1 (string path) ;argm))
